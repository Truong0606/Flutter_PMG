import 'dart:convert';
import 'package:first_app/core/network/api_client.dart';
import 'package:first_app/features/teacher/data/models/class_model.dart';
import 'package:first_app/features/teacher/data/models/schedule_model.dart';
import 'package:first_app/features/teacher/domain/entities/classes.dart';
import 'package:first_app/features/teacher/domain/entities/schedule.dart';
import 'package:first_app/features/teacher/domain/repositories/teacher_repository.dart';

class TeacherActionRepositoryImpl implements TeacherActionRepository {
  final ApiClient _apiClient;

  TeacherActionRepositoryImpl(this._apiClient);

  /// Some APIs return a list at the root, others wrap it inside a map
  /// like {"data": [...] } or {"items": [...] }. This helper extracts
  /// the first list it can find from a decoded JSON value.
  List<dynamic> _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      // Common wrapper keys
      for (final key in const ['data', 'items', 'result', 'results', 'content']) {
        final v = decoded[key];
        if (v is List) return v;
      }
      // Fall back: first list value in the map, if any
      for (final v in decoded.values) {
        if (v is List) return v;
      }
    }
    return <dynamic>[];
  }

  @override
  Future<List<Classes>> getClassList() async {
    final resp = await _apiClient.get('/teacher/classes');
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (resp.body.isEmpty) return [];
      final decoded = jsonDecode(resp.body);
      final data = _extractList(decoded);
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
      final resp = await _apiClient.get('/teacher/schedules');
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        if (resp.body.isEmpty) return [];
        final decoded = jsonDecode(resp.body);
        final List<dynamic> jsonData = _extractList(decoded);
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
      final endpoint = '/teacher/schedules?weekName=$encodedWeekName';

      final resp = await _apiClient.get(endpoint);

      if (resp.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      }

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        if (resp.body.isEmpty) return [];

        final decoded = jsonDecode(resp.body);
        final List<dynamic> jsonData = _extractList(decoded);

        final schedules = jsonData
            .map((item) {
              if (item is! Map<String, dynamic>) {
                return null;
              }

              try {
                final schedule = ScheduleModel.fromJson(item);
                return schedule;
              } catch (e) {
                return null;
              }
            })
            .where((schedule) => schedule != null)
            .cast<Schedule>()
            .toList();

        return schedules;
      }

      throw Exception('Failed to load weekly schedule (${resp.statusCode})');
    } catch (e) {
      rethrow;
    }
  }
}
