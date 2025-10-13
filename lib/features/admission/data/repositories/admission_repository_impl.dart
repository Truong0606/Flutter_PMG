import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/admission_term.dart';
import '../../domain/repositories/admission_repository.dart';

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
}
