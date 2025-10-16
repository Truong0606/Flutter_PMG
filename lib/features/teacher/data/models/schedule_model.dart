
import '../../domain/entities/schedule.dart';
import 'activity_model.dart';
import 'class_model.dart';

class ScheduleModel extends Schedule {
  const ScheduleModel({
    required super.id,
    required super.weekName,
    required super.classesId,
    required super.activities,
    super.classes,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'],
      weekName: json['weekName'],
      classesId: json['classesId'],
      activities: (json['activities'] as List)
          .map((activity) => ActivityModel.fromJson(activity))
          .toList(),
      classes: json['classes'] != null
          ? ClassModel.fromJson(json['classes'])
          : null,
    );
  }
}
