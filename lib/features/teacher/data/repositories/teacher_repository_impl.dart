import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:first_app/core/network/api_client.dart';
import 'package:first_app/features/teacher/data/models/class_model.dart';
import 'package:first_app/features/teacher/data/models/schedule_model.dart';
import 'package:first_app/features/teacher/domain/entities/classes.dart';
import 'package:first_app/features/teacher/domain/entities/schedule.dart';
import 'package:first_app/features/teacher/domain/repositories/teacher_repository.dart';

class TeacherActionRepositoryImpl implements TeacherActionRepository {
  final ApiClient _apiClient;

  TeacherActionRepositoryImpl(this._apiClient);

  @override
  Future<List<Classes>> getClassList() async {
    final resp = await _apiClient.get('/auth-api/api/teacher/classes');
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (resp.body.isEmpty) return [];
      final data = jsonDecode(resp.body) as List;
      return data
          .map((e) => ClassModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(
      'Failed to load classes (${resp.statusCode}): ${resp.body}',
    );
  }

  @override
  Future<List<Schedule>> getScheduleList() async {
    try {
      final resp = await _apiClient.get('/auth-api/api/teacher/schedules');
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        if (resp.body.isEmpty) return [];
        final List<dynamic> jsonData = jsonDecode(resp.body);
        final schedules = jsonData
            .map((item) {
              if (item is! Map<String, dynamic>) return null;
              try {
                return ScheduleModel.fromJson(item);
              } catch (e) {
                return null;
              }
            })
            .where((schedule) => schedule != null)
            .cast<Schedule>()
            .toList();
        return schedules;
      }
      throw Exception(
        'Failed to load schedules (${resp.statusCode}): ${resp.body}',
      );
    } catch (e) {
      throw Exception('Error loading schedules: ${e.toString()}');
    }
  }

  @override
  Future<List<Schedule>> getWeeklySchedule(String weekName) async {
    try {
      final encodedWeekName = Uri.encodeComponent(weekName);
      final endpoint =
          '/auth-api/api/teacher/schedules/weekly?weekName=$encodedWeekName';

      if (kDebugMode) {
        print('[TeacherRepo] Fetching schedule: $endpoint');
      }
      final resp = await _apiClient.get(endpoint);

      if (resp.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      }

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        if (resp.body.isEmpty) return [];

        if (kDebugMode) {
          print('[TeacherRepo] Raw response: ${resp.body}');
        }

        final List<dynamic> jsonData = jsonDecode(resp.body);
        final schedules = jsonData
            .map((item) {
              if (item is! Map<String, dynamic>) {
                if (kDebugMode) {
                  print('[TeacherRepo] Invalid item format: $item');
                }
                return null;
              }

              try {
                return ScheduleModel.fromJson(item);
              } catch (e) {
                if (kDebugMode) {
                  print('[TeacherRepo] Parse error: $e');
                }
                return null;
              }
            })
            .where((schedule) => schedule != null)
            .cast<Schedule>()
            .toList();

        if (kDebugMode) {
          print(
            '[TeacherRepo] Parsed ${schedules.length} schedules successfully',
          );
        }

        return schedules;
      }

      if (kDebugMode) {
        print('[TeacherRepo] API Error: ${resp.statusCode} - ${resp.body}');
      }
      throw Exception('Failed to load weekly schedule (${resp.statusCode})');
    } catch (e) {
      if (kDebugMode) {
        print('[TeacherRepo] Error: $e');
      }
      rethrow;
    }
  }
}
