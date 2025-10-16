import 'package:first_app/features/teacher/domain/entities/classes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/schedule.dart';
import '../../domain/repositories/teacher_repository.dart';

abstract class TeacherEvent {}

class LoadClassesByTeacher extends TeacherEvent {
  final int teacherId;

  LoadClassesByTeacher(this.teacherId);
}

class LoadSchedulesByTeacher extends TeacherEvent {
  final int teacherId;

  LoadSchedulesByTeacher(this.teacherId);
}

class LoadWeeklyScheduleByTeacher extends TeacherEvent {
  final int teacherId;
  final String weekName;

  LoadWeeklyScheduleByTeacher(this.teacherId, this.weekName);
}

abstract class TeacherState {}

class TeacherInitial extends TeacherState {}

class TeacherLoading extends TeacherState {}

class TeacherLoadedClasses extends TeacherState {
  final List<Classes> classes;

  TeacherLoadedClasses(this.classes);
}

class TeacherLoadedSchedules extends TeacherState {
  final List<Schedule> schedules;

  TeacherLoadedSchedules(this.schedules);
}

class TeacherLoadedWeeklySchedules extends TeacherState {
  final List<Schedule> schedules;

  TeacherLoadedWeeklySchedules(this.schedules);
}

class TeacherError extends TeacherState {
  final String message;

  TeacherError(this.message);
}

class TeacherBloc extends Bloc<TeacherEvent, TeacherState> {
  final TeacherActionRepository repository;

  TeacherBloc(this.repository) : super(TeacherInitial()) {
    on<LoadClassesByTeacher>((event, emit) async {
      emit(TeacherLoading());
      try {
        final classes = await repository.getClassesByTeacherId(event.teacherId);
        emit(TeacherLoadedClasses(classes));
      } catch (e) {
        emit(TeacherError(e.toString()));
      }
    });

    on<LoadSchedulesByTeacher>((event, emit) async {
      emit(TeacherLoading());
      try {
        final schedules = await repository.getSchedulesByTeacherId(
          event.teacherId,
        );
        emit(TeacherLoadedSchedules(schedules));
      } catch (e) {
        emit(TeacherError(e.toString()));
      }
    });

    on<LoadWeeklyScheduleByTeacher>((event, emit) async {
      emit(TeacherLoading());
      try {
        final schedules = await repository.getWeeklySchedule(
          event.teacherId,
          event.weekName,
        );
        emit(TeacherLoadedWeeklySchedules(schedules));
      } catch (e) {
        emit(TeacherError(e.toString()));
      }
    });
  }
}
