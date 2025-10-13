import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/admission_term.dart';
import '../../domain/repositories/admission_repository.dart';

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

// States
abstract class AdmissionState {}
class AdmissionInitial extends AdmissionState {}
class AdmissionLoading extends AdmissionState {}
class AdmissionLoaded extends AdmissionState {
  final AdmissionTerm term;
  final int? selectedStudentId;
  final int? currentClassId;
  final List<int> checkedClassIds;
  final Map<String, dynamic>? lastAvailabilityResult;
  AdmissionLoaded({
    required this.term,
    this.selectedStudentId,
    this.currentClassId,
    this.checkedClassIds = const [],
    this.lastAvailabilityResult,
  });

  AdmissionLoaded copyWith({
    AdmissionTerm? term,
    int? selectedStudentId,
    int? currentClassId,
    List<int>? checkedClassIds,
    Map<String, dynamic>? lastAvailabilityResult,
  }) => AdmissionLoaded(
        term: term ?? this.term,
        selectedStudentId: selectedStudentId ?? this.selectedStudentId,
        currentClassId: currentClassId ?? this.currentClassId,
        checkedClassIds: checkedClassIds ?? this.checkedClassIds,
        lastAvailabilityResult: lastAvailabilityResult ?? this.lastAvailabilityResult,
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
        emit(AdmissionError(e.toString()));
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
  }
}
