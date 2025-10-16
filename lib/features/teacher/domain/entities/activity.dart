import 'package:first_app/features/teacher/domain/entities/schedule.dart';

class Activity {
  final int id;
  final String? date;
  final String? dayOfWeek;
  final String? endTime;
  final String name;
  final String? startTime;
  final int? scheduleId;
  final Schedule? schedule;

  Activity({
    required this.id,
    this.date,
    this.dayOfWeek,
    this.endTime,
    required this.name,
    this.startTime,
    this.scheduleId,
    this.schedule,
  });
}
