import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/entities/student.dart';

abstract class StudentEvent {}
class LoadStudents extends StudentEvent {}
class CreateStudent extends StudentEvent {
  final String name;
  final String gender;
  final String dateOfBirth; // yyyy-MM-dd
  final String? placeOfBirth;
  final String? profileImage;
  final String? householdRegistrationImg;
  final String? birthCertificateImg;
  CreateStudent({
    required this.name,
    required this.gender,
    required this.dateOfBirth,
    this.placeOfBirth,
    this.profileImage,
    this.householdRegistrationImg,
    this.birthCertificateImg,
  });
}

abstract class StudentState {}
class StudentInitial extends StudentState {}
class StudentLoading extends StudentState {}
class StudentLoaded extends StudentState { final List<Student> students; StudentLoaded(this.students); }
class StudentError extends StudentState { final String message; StudentError(this.message); }
class StudentCreated extends StudentState { final Student student; StudentCreated(this.student); }

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentRepository repository;
  StudentBloc(this.repository) : super(StudentInitial()) {
    on<LoadStudents>((event, emit) async {
      emit(StudentLoading());
      try {
        final list = await repository.getStudents();
        emit(StudentLoaded(list));
      } catch (e) {
        emit(StudentError(e.toString()));
      }
    });

    on<CreateStudent>((event, emit) async {
      emit(StudentLoading());
      try {
        final student = await repository.createStudent(
          name: event.name,
          gender: event.gender,
          dateOfBirth: event.dateOfBirth,
          placeOfBirth: event.placeOfBirth,
          profileImage: event.profileImage,
          householdRegistrationImg: event.householdRegistrationImg,
          birthCertificateImg: event.birthCertificateImg,
        );
        emit(StudentCreated(student));
      } catch (e) {
        emit(StudentError(e.toString()));
      }
    });
  }
}
