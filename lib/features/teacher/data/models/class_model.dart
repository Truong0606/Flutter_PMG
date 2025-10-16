
import 'package:first_app/features/teacher/data/models/schedule_model.dart';
import 'package:first_app/features/teacher/data/models/teacher_model.dart';

import '../../domain/entities/classes.dart';

class ClassModel extends Classes {
  const ClassModel({
    required super.id,
    required super.academicYear,
    required super.endDate,
    required super.name,
    required super.numberStudent,
    required super.startDate,
    required super.status,
    required super.syllabusId,
    required super.teacherId,
    required super.schedules,
    super.teacher,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'],
      academicYear: json['academicYear'],
      endDate: json['endDate'],
      name: json['name'],
      numberStudent: json['numberStudent'],
      startDate: json['startDate'],
      status: json['status'],
      syllabusId: json['syllabusId'],
      teacherId: json['teacherId'],
      schedules: (json['schedules'] as List)
          .map((schedule) => ScheduleModel.fromJson(schedule))
          .toList(),
      teacher: json['teacher'] != null
          ? TeacherModel.fromJson(json['teacher'])
          : null,
    );
  }
}
