
import '../../domain/entities/activity.dart';
import 'schedule_model.dart';

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
      id: json['id'],
      date: json['date'],
      dayOfWeek: json['dayOfWeek'],
      endTime: json['endTime'],
      name: json['name'],
      startTime: json['startTime'],
      scheduleId: json['scheduleId'],
      schedule: json['schedule'] != null
          ? ScheduleModel.fromJson(json['schedule'])
          : null,
    );
  }
}
