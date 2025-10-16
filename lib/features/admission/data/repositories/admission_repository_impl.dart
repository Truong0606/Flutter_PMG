import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/admission_term.dart';
import '../../domain/repositories/admission_repository.dart';
import '../../domain/entities/admission_form_item.dart';

class AdmissionRepositoryImpl implements AdmissionRepository {
  final ApiClient _api;
  AdmissionRepositoryImpl(this._api);

  @override
  Future<AdmissionTerm> getActiveTerm() async {
    final resp = await _api.getClassPublic('/term/active');
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final map = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
      final data = (map is Map && map['data'] is Map<String, dynamic>)
          ? map['data'] as Map<String, dynamic>
          : <String, dynamic>{};
      return AdmissionTerm.fromJson(data);
    }
    throw Exception('Failed to get active term (${resp.statusCode})');
  }

  @override
  Future<Map<String, dynamic>> checkAvailabilityClasses({
    required int studentId,
    required int currentClassId,
    required List<int> checkedClassIds,
  }) async {
    final payload = {
      'studentId': studentId,
      'currentClassId': currentClassId,
      'checkedClassIds': checkedClassIds,
    };
    final resp = await _api.putParent('/admissionForm/check/availability/classes', body: payload);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final map = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
      return (map is Map<String, dynamic>) ? map : {'raw': resp.body};
    }
    throw Exception('Failed to check availability (${resp.statusCode})');
  }

  @override
  Future<Map<String, dynamic>> createAdmissionForm({
    required int studentId,
    required int admissionTermId,
    required List<int> classIds,
  }) async {
    final payload = {
      'studentId': studentId,
      'admissionTermId': admissionTermId,
      'classIds': classIds,
    };
    final resp = await _api.postParent('/admissionForm', body: payload);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final map = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
      return (map is Map<String, dynamic>) ? map : {'raw': resp.body};
    }
    throw Exception('Failed to create admission form (${resp.statusCode})');
  }

  @override
  Future<List<AdmissionFormItem>> listAdmissionForms() async {
    final resp = await _api.getParent('/admissionForm/list');
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final map = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
      final data = (map is Map && map['data'] is List) ? (map['data'] as List) : <dynamic>[];
      return data
          .whereType<Map<String, dynamic>>()
          .map(AdmissionFormItem.fromJson)
          .toList();
    }
    throw Exception('Failed to fetch admission forms (${resp.statusCode})');
  }

  @override
  Future<String> getAdmissionPaymentUrl(int id) async {
    final resp = await _api.getParent('/admissionForm/paymentUrl/$id');
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final map = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
      if (map is Map) {
        // Swagger example shows URL in 'message'
        final msg = map['message']?.toString();
        if (msg != null && msg.startsWith('http')) return msg;
      }
      return resp.body.toString();
    }
    throw Exception('Failed to fetch payment URL (${resp.statusCode})');
  }
}
