import '../../domain/entities/activity.dart';

class ActivityModel extends Activity {
  ActivityModel({
    required super.id,
    super.date,
    super.dayOfWeek,
    super.endTime,
    required super.name,
    super.startTime,
    super.scheduleId,
    super.schedule,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as int? ?? 0,
      date: json['date']?.toString(),
      dayOfWeek: json['dayOfWeek']?.toString(),
      endTime: json['endTime']?.toString(),
      name: (json['name'] ?? '').toString(),
      startTime: json['startTime']?.toString(),
      scheduleId: json['scheduleId'] as int?,
      schedule: null, // Avoid circular dependency with ScheduleModel
    );
  }
}
