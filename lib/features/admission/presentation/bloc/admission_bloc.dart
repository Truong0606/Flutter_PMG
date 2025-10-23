import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/admission_term.dart';
import '../../domain/repositories/admission_repository.dart';
import '../../domain/errors.dart';

// Events
abstract class AdmissionEvent {}
class LoadActiveTerm extends AdmissionEvent {}
class SelectStudentAndRecheck extends AdmissionEvent {
  final int studentId;
  final int? currentClassId; // can be null if currently not in a class
  final List<int> checkedClassIds;
  SelectStudentAndRecheck({
    required this.studentId,
    this.currentClassId,
    this.checkedClassIds = const [],
  });
}
class UpdateCheckedClasses extends AdmissionEvent {
  final List<int> checkedClassIds;
  UpdateCheckedClasses(this.checkedClassIds);
}
class SetSelectedForForm extends AdmissionEvent {
  final List<int> classIds; // override selection for the upcoming form
  SetSelectedForForm(this.classIds);
}
class ToggleSelectedForForm extends AdmissionEvent {
  final int classId;
  ToggleSelectedForForm(this.classId);
}
class SubmitAdmissionForm extends AdmissionEvent {}

// States
abstract class AdmissionState {}
class AdmissionInitial extends AdmissionState {}
class AdmissionLoading extends AdmissionState {}
class AdmissionSubmitSuccess extends AdmissionState {
  final Map<String, dynamic> response;
  AdmissionSubmitSuccess(this.response);
}
class AdmissionLoaded extends AdmissionState {
  final AdmissionTerm term;
  final int? selectedStudentId;
  final int? currentClassId;
  final List<int> checkedClassIds;
  final Map<String, dynamic>? lastAvailabilityResult;
  final List<int> selectedForForm;
  AdmissionLoaded({
    required this.term,
    this.selectedStudentId,
    this.currentClassId,
    this.checkedClassIds = const [],
    this.lastAvailabilityResult,
    this.selectedForForm = const [],
  });

  AdmissionLoaded copyWith({
    AdmissionTerm? term,
    int? selectedStudentId,
    int? currentClassId,
    List<int>? checkedClassIds,
    Map<String, dynamic>? lastAvailabilityResult,
    List<int>? selectedForForm,
  }) => AdmissionLoaded(
        term: term ?? this.term,
        selectedStudentId: selectedStudentId ?? this.selectedStudentId,
        currentClassId: currentClassId ?? this.currentClassId,
        checkedClassIds: checkedClassIds ?? this.checkedClassIds,
        lastAvailabilityResult: lastAvailabilityResult ?? this.lastAvailabilityResult,
        selectedForForm: selectedForForm ?? this.selectedForForm,
      );
}
class AdmissionError extends AdmissionState { final String message; AdmissionError(this.message); }

class AdmissionBloc extends Bloc<AdmissionEvent, AdmissionState> {
  final AdmissionRepository repository;
  AdmissionBloc(this.repository) : super(AdmissionInitial()) {
    on<LoadActiveTerm>((event, emit) async {
      emit(AdmissionLoading());
      try {
        final term = await repository.getActiveTerm();
        emit(AdmissionLoaded(term: term));
      } catch (e) {
        if (e is AdmissionNotAvailableException) {
          emit(AdmissionError(e.toString()));
        } else {
          emit(AdmissionError(e.toString()));
        }
      }
    });

    on<SelectStudentAndRecheck>((event, emit) async {
      final current = state;
      if (current is AdmissionLoaded) {
        emit(AdmissionLoading());
        try {
          final result = await repository.checkAvailabilityClasses(
            studentId: event.studentId,
            currentClassId: event.currentClassId ?? 0,
            checkedClassIds: event.checkedClassIds,
          );
          emit(current.copyWith(
            selectedStudentId: event.studentId,
            currentClassId: event.currentClassId ?? 0,
            checkedClassIds: List<int>.from(event.checkedClassIds),
            lastAvailabilityResult: result,
            // By default, set selectedForForm = newly checked classes
            selectedForForm: List<int>.from(event.checkedClassIds),
          ));
        } catch (e) {
          // Keep the form on screen; surface error inline in the result box
          emit(current.copyWith(
            selectedStudentId: event.studentId,
            currentClassId: event.currentClassId ?? 0,
            checkedClassIds: List<int>.from(event.checkedClassIds),
            lastAvailabilityResult: {
              'error': e.toString(),
            },
          ));
        }
      }
    });

    on<UpdateCheckedClasses>((event, emit) async {
      final current = state;
      if (current is AdmissionLoaded) {
        emit(current.copyWith(checkedClassIds: List<int>.from(event.checkedClassIds)));
      }
    });

    on<SetSelectedForForm>((event, emit) async {
      final current = state;
      if (current is AdmissionLoaded) {
        emit(current.copyWith(selectedForForm: List<int>.from(event.classIds)));
      }
    });

    on<ToggleSelectedForForm>((event, emit) async {
      final current = state;
      if (current is AdmissionLoaded) {
        final sel = List<int>.from(current.selectedForForm);
        if (sel.contains(event.classId)) {
          sel.remove(event.classId);
        } else {
          sel.add(event.classId);
        }
        emit(current.copyWith(selectedForForm: sel));
      }
    });

    on<SubmitAdmissionForm>((event, emit) async {
      final current = state;
      if (current is AdmissionLoaded) {
        if (current.selectedStudentId == null || current.selectedStudentId == 0) {
          emit(AdmissionError('Please select a child first'));
          return;
        }
        if (current.selectedForForm.isEmpty) {
          emit(AdmissionError('Please select at least one class'));
          return;
        }
        emit(AdmissionLoading());
        try {
          final res = await repository.createAdmissionForm(
            studentId: current.selectedStudentId!,
            admissionTermId: current.term.id,
            classIds: current.selectedForForm,
          );
          // Announce success via a dedicated state so UI can show a popup and redirect
          emit(AdmissionSubmitSuccess(res));
        } catch (e) {
          emit(AdmissionError(e.toString()));
        }
      }
    });
  }
}
