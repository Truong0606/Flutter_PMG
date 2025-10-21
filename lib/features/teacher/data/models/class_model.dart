import 'package:first_app/features/teacher/data/models/teacher_model.dart';
import 'package:first_app/features/teacher/data/models/schedule_model.dart';
import 'package:flutter/foundation.dart';
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

  factory ClassModel.fromJson(
    Map<String, dynamic> json, {
    bool parseSchedules = true,
  }) {
    // Parse schedules array from JSON only when explicitly requested
    final schedulesList = <ScheduleModel>[];
    if (parseSchedules && json['schedules'] is List) {
      for (final scheduleJson in json['schedules']) {
        if (scheduleJson is Map<String, dynamic>) {
          try {
            schedulesList.add(ScheduleModel.fromJson(scheduleJson));
          } catch (e) {
            // Skip invalid schedule entries
            debugPrint('Error parsing schedule: $e');
          }
        }
      }
    }

    return ClassModel(
      id: json['id'] as int? ?? 0,
      academicYear: json['academicYear'] as int? ?? 0,
      endDate: (json['endDate'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      numberStudent: json['numberStudent'] as int? ?? 0,
      startDate: (json['startDate'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      syllabusId: json['syllabusId'] as int? ?? 0,
      teacherId: json['teacherId'] as int? ?? 0,
      schedules: schedulesList,
      teacher: json['teacher'] != null
          ? TeacherModel.fromJson(json['teacher'] as Map<String, dynamic>)
          : null,
    );
  }
}
