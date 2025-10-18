import 'package:first_app/features/teacher/domain/entities/classes.dart';
import 'package:first_app/features/teacher/domain/entities/schedule.dart';
import 'package:first_app/features/teacher/domain/repositories/teacher_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ==== EVENTS ====

abstract class TeacherEvent {}

/// Event lấy danh sách lớp
class LoadTeacherClasses extends TeacherEvent {}

/// Event lấy tất cả schedule (KHÔNG truyền teacherId)
class LoadSchedules extends TeacherEvent {}

/// Event lấy lịch tuần theo weekName (KHÔNG truyền teacherId)
class LoadWeeklySchedule extends TeacherEvent {
  final String weekName;
  LoadWeeklySchedule(this.weekName);
}

// ==== STATES ====

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

// ==== BLOC ====

class TeacherBloc extends Bloc<TeacherEvent, TeacherState> {
  final TeacherActionRepository repository;

  TeacherBloc(this.repository) : super(TeacherInitial()) {
    // Event lấy danh sách lớp
    on<LoadTeacherClasses>((event, emit) async {
      emit(TeacherLoading());
      try {
        final classes = await repository.getClassList();
        emit(TeacherLoadedClasses(classes));
      } catch (e) {
        emit(TeacherError(e.toString()));
      }
    });

    // Event lấy danh sách schedule (KHÔNG truyền teacherId)
    on<LoadSchedules>((event, emit) async {
      emit(TeacherLoading());
      try {
        final schedules = await repository.getScheduleList();
        emit(TeacherLoadedSchedules(schedules));
      } catch (e) {
        emit(TeacherError(e.toString()));
      }
    });

    // Event lấy lịch theo tuần (truyền weekName, KHÔNG truyền teacherId)
    on<LoadWeeklySchedule>((event, emit) async {
      emit(TeacherLoading());
      try {
        final schedules = await repository.getWeeklySchedule(event.weekName);
        emit(TeacherLoadedWeeklySchedules(schedules));
      } catch (e) {
        emit(TeacherError(e.toString()));
      }
    });
  }
}
