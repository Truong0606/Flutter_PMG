import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/student_repository.dart';

class StudentRepositoryImpl implements StudentRepository {
  final ApiClient _apiClient;
  StudentRepositoryImpl(this._apiClient);

  @override
  Future<List<Student>> getStudents() async {
  final resp = await _apiClient.getParent('/student/list');
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (resp.body.isEmpty) return [];
      final jsonMap = jsonDecode(resp.body);
      final data = (jsonMap is Map && jsonMap['data'] is List) ? jsonMap['data'] as List : [];
      return data.map((e) => Student.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load students (${resp.statusCode})');
  }

  @override
  Future<Student> createStudent({
    required String name,
    required String gender,
    required String dateOfBirth,
    String? placeOfBirth,
    String? profileImage,
    String? householdRegistrationImg,
    String? birthCertificateImg,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      if (placeOfBirth != null) 'placeOfBirth': placeOfBirth,
      if (profileImage != null) 'profileImage': profileImage,
      if (householdRegistrationImg != null) 'householdRegistrationImg': householdRegistrationImg,
      if (birthCertificateImg != null) 'birthCertificateImg': birthCertificateImg,
    };
    if (kDebugMode) {
      debugPrint('POST /parent-api/api/student payload: ${jsonEncode(body)}');
    }
    final resp = await _apiClient.postParent('/student', body: body);
    if (kDebugMode) {
      debugPrint('Response ${resp.statusCode}: ${resp.body}');
    }
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final map = resp.body.isNotEmpty ? jsonDecode(resp.body) : null;
      if (map is Map && map['data'] != null) {
        return Student.fromJson(map['data'] as Map<String, dynamic>);
      }
      // Some APIs return the created entity directly
      if (map is Map<String, dynamic>) {
        return Student.fromJson(map);
      }
      // Fallback minimal
      return Student(id: 0, name: name, gender: gender, dateOfBirth: dateOfBirth);
    }
    // Try to surface server message when available
    String serverMsg = 'Failed to create student (${resp.statusCode})';
    try {
      if (resp.body.isNotEmpty) {
        final err = jsonDecode(resp.body);
        if (err is Map) {
          final msg = err['message'] ?? err['error'] ?? err['detail'] ?? err['title'];
          if (msg != null) serverMsg = msg.toString();
        } else if (err is String && err.toString().trim().isNotEmpty) {
          serverMsg = err.toString();
        }
      }
    } catch (_) {
      if (resp.body.isNotEmpty) {
        serverMsg = resp.body.toString();
      }
    }
    throw Exception(serverMsg);
  }
}
