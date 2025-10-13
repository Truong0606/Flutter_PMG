import '../entities/admission_term.dart';

abstract class AdmissionRepository {
  Future<AdmissionTerm> getActiveTerm();

  // Create or update admission form to re-check availability
  // When checkedClassIds is empty, backend should return options for the student
  // Payload shape (based on swagger):
  // {
  //   "studentId": 0,
  //   "currentClassId": 0,
  //   "checkedClassIds": [0]
  // }
  Future<Map<String, dynamic>> checkAvailabilityClasses({
    required int studentId,
    required int currentClassId,
    required List<int> checkedClassIds,
  });
}
