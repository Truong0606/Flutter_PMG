import 'package:equatable/equatable.dart';

import 'activity.dart';
import 'classes.dart';

class Schedule extends Equatable {
  final int id;
  final String weekName;
  final int classesId;
  final List<Activity> activities;
  final Classes? classes;

  const Schedule({
    required this.id,
    required this.weekName,
    required this.classesId,
    required this.activities,
    this.classes,
  });

  @override
  List<Object?> get props => [id, weekName, classesId, activities, classes];
}
