import '../entities/student.dart';
import '../entities/activity_item.dart';

abstract class StudentRepository {
  Future<List<Student>> getStudents();
  Future<Student> createStudent({
    required String name,
    required String gender,
    required String dateOfBirth, // yyyy-MM-dd
    String? placeOfBirth,
    String? profileImage,
    String? householdRegistrationImg,
    String? birthCertificateImg,
  });

  Future<void> deleteStudent(int id);

  Future<Student> updateStudent({
    required int id,
    required String name,
    required String gender,
    required String dateOfBirth, // yyyy-MM-dd
    String? placeOfBirth,
    String? profileImage,
    String? householdRegistrationImg,
    String? birthCertificateImg,
  });

  // Schedule/Activities between two dates (yyyy-MM-dd)
  Future<List<ActivityItem>> getActivities({
    required int studentId,
    required String startWeek,
    required String endWeek,
  });
}
