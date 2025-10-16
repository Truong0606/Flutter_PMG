import 'dart:convert';

import 'package:first_app/core/network/api_client.dart';
import 'package:first_app/features/teacher/data/models/activity_model.dart';
import 'package:first_app/features/teacher/data/models/class_model.dart';
import 'package:first_app/features/teacher/data/models/schedule_model.dart';
import 'package:first_app/features/teacher/domain/entities/activity.dart';
import 'package:first_app/features/teacher/domain/entities/classes.dart';
import 'package:first_app/features/teacher/domain/entities/schedule.dart';
import 'package:first_app/features/teacher/domain/repositories/teacher_repository.dart';

class TeacherActionRepositoryImpl implements TeacherActionRepository {
  final ApiClient _apiClient;

  TeacherActionRepositoryImpl(this._apiClient);

  @override
  Future<List<Classes>> getClassesByTeacherId(int teacherId) async {
    final resp = await _apiClient.get('/auth-api/api/teacher/classes?teacherId=$teacherId');
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (resp.body.isEmpty) return [];
      final data = jsonDecode(resp.body) as List;
      return data
          .map((e) => ClassModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load classes (${resp.statusCode})');
  }

  @override
  Future<Classes?> getClassDetail(int classId, int teacherId) async {
    final resp = await _apiClient.get(
      '/auth-api/api/teacher/classes/$classId?teacherId=$teacherId',
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (resp.body.isEmpty) return null;
      return ClassModel.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to load class detail (${resp.statusCode})');
  }

  @override
  Future<List<Schedule>> getSchedulesByTeacherId(int teacherId) async {
    final resp = await _apiClient.get(
      '/auth-api/api/teacher/schedules?teacherId=$teacherId',
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (resp.body.isEmpty) return [];
      final data = jsonDecode(resp.body) as List;
      return data
          .map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load schedules (${resp.statusCode})');
  }

  @override
  Future<List<Activity>> getActivitiesByScheduleId(int scheduleId) async {
    final resp = await _apiClient.get('/auth-api/api/schedules/$scheduleId/activities');
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (resp.body.isEmpty) return [];
      final data = jsonDecode(resp.body) as List;
      return data
          .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load activities (${resp.statusCode})');
  }

  @override
  Future<List<Schedule>> getWeeklySchedule(
    int teacherId,
    String weekName,
  ) async {
    final resp = await _apiClient.get(
      '/auth-api/api/teacher/schedules/weekly?teacherId=$teacherId&weekName=$weekName',
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (resp.body.isEmpty) return [];
      final data = jsonDecode(resp.body) as List;
      return data
          .map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load weekly schedule (${resp.statusCode})');
  }
}
