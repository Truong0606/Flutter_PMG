import '../entities/admission_term.dart';
import '../entities/admission_form_item.dart';

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

  // Create admission form
  // POST /api/admissionForm (parent-api)
  // Body:
  // {
  //   "studentId": 0,
  //   "admissionTermId": 0,
  //   "classIds": [0]
  // }
  Future<Map<String, dynamic>> createAdmissionForm({
    required int studentId,
    required int admissionTermId,
    required List<int> classIds,
  });

  // GET /api/admissionForm/list (parent-api)
  Future<List<AdmissionFormItem>> listAdmissionForms();

  // GET /api/admissionForm/paymentUrl/{id} (parent-api)
  Future<String> getAdmissionPaymentUrl(int id);

  // Optional: GET /api/admissionForm/{id} if available; otherwise we use list data passed in
  // Future<AdmissionFormItem> getAdmissionForm(int id);
}
