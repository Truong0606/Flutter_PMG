import '../../domain/entities/schedule.dart';
import 'activity_model.dart';

class ScheduleModel extends Schedule {
  const ScheduleModel({
    required super.id,
    required super.weekName,
    required super.classesId,
    required super.activities,
    super.classes,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    try {
      // Validate and convert activities list
      final activities = <ActivityModel>[];
      final activitiesList = json['activities'];
      if (activitiesList is List) {
        for (final activity in activitiesList) {
          if (activity is Map<String, dynamic>) {
            try {
              activities.add(ActivityModel.fromJson(activity));
            } catch (e) {
              print('Error parsing activity: $e\nActivity data: $activity');
            }
          }
        }
      }

      return ScheduleModel(
        id: json['id'] is int
            ? json['id']
            : int.tryParse(json['id']?.toString() ?? '') ?? 0,
        weekName: (json['weekName'] ?? '').toString(),
        classesId: json['classesId'] is int
            ? json['classesId']
            : int.tryParse(json['classesId']?.toString() ?? '') ?? 0,
        activities: activities,
        classes: null, // Avoid circular dependency
      );
    } catch (e) {
      rethrow;
    }
  }
}
