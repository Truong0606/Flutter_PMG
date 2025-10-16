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

  @override
  Future<void> deleteStudent(int id) async {
    if (id <= 0) {
      throw Exception('Invalid student id: $id');
    }

    // Try common RESTful shapes, stop on first success (2xx)
    final endpoints = <String>[
      '/student/$id',           // RESTful path param
      '/student?id=$id',        // query param 'id'
      '/student?studentId=$id', // query param 'studentId'
    ];

    Exception? lastError;
    for (final ep in endpoints) {
      final resp = await _apiClient.deleteParent(ep);
      if (kDebugMode) {
        debugPrint('DELETE $ep -> ${resp.statusCode} ${resp.body}');
      }
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return;
      }
      // Capture server message if any and continue to next shape
      String msg = 'Failed to delete student (${resp.statusCode})';
      try {
        if (resp.body.isNotEmpty) {
          final m = jsonDecode(resp.body);
          if (m is Map) {
            final serverMsg = m['message'] ?? m['error'] ?? m['detail'] ?? m['title'];
            if (serverMsg != null) msg = serverMsg.toString();
          } else if (m is String && m.trim().isNotEmpty) {
            msg = m;
          }
        }
      } catch (_) {}
      lastError = Exception(msg);
    }
    throw lastError ?? Exception('Failed to delete student');
  }

  @override
  Future<Student> updateStudent({
    required int id,
    required String name,
    required String gender,
    required String dateOfBirth,
    String? placeOfBirth,
    String? profileImage,
    String? householdRegistrationImg,
    String? birthCertificateImg,
  }) async {
    if (id <= 0) {
      throw Exception('Invalid student id: $id');
    }
    final body = <String, dynamic>{
      'id': id,
      'name': name,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      if (placeOfBirth != null) 'placeOfBirth': placeOfBirth,
      if (profileImage != null) 'profileImage': profileImage,
      if (householdRegistrationImg != null) 'householdRegistrationImg': householdRegistrationImg,
      if (birthCertificateImg != null) 'birthCertificateImg': birthCertificateImg,
    };
    if (kDebugMode) {
      debugPrint('PUT /parent-api/api/student payload: ${jsonEncode(body)}');
    }
    final resp = await _apiClient.putParent('/student', body: body);
    if (kDebugMode) {
      debugPrint('PUT /student -> ${resp.statusCode}: ${resp.body}');
    }
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final map = resp.body.isNotEmpty ? jsonDecode(resp.body) : null;
      if (map is Map && map['data'] != null) {
        return Student.fromJson(map['data'] as Map<String, dynamic>);
      }
      if (map is Map<String, dynamic>) {
        return Student.fromJson(map);
      }
      // Fallback: return local merged object
      return Student(
        id: id,
        name: name,
        gender: gender,
        dateOfBirth: dateOfBirth,
        placeOfBirth: placeOfBirth,
        profileImage: profileImage,
        householdRegistrationImg: householdRegistrationImg,
        birthCertificateImg: birthCertificateImg,
      );
    }
    String serverMsg = 'Failed to update student (${resp.statusCode})';
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
