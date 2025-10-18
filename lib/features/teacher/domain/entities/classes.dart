import 'package:equatable/equatable.dart';
import 'package:first_app/features/teacher/domain/entities/schedule.dart';
import 'package:first_app/features/teacher/domain/entities/teacher.dart';

class Classes extends Equatable {
  final int id;
  final int academicYear;
  final String endDate;
  final String name;
  final int numberStudent;
  final String startDate;
  final String status;
  final int syllabusId;
  final int teacherId;
  final List<Schedule> schedules;
  final Teacher? teacher;

  const Classes({
    required this.id,
    required this.academicYear,
    required this.endDate,
    required this.name,
    required this.numberStudent,
    required this.startDate,
    required this.status,
    required this.syllabusId,
    required this.teacherId,
    required this.schedules,
    this.teacher,
  });

  @override
  List<Object?> get props => [
    id,
    academicYear,
    endDate,
    name,
    numberStudent,
    startDate,
    status,
    syllabusId,
    teacherId,
    schedules,
    teacher,
  ];
}
