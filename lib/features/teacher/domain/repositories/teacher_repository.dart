
import '../entities/activity.dart';
import '../entities/classes.dart';
import '../entities/schedule.dart';

abstract class TeacherActionRepository {
  // Lấy danh sách lớp theo teacherId
  Future<List<Classes>> getClassesByTeacherId(int teacherId);

  // Lấy chi tiết một class theo classId và teacherId
  Future<Classes?> getClassDetail(int classId, int teacherId);

  // Lấy danh sách schedule theo teacherId
  Future<List<Schedule>> getSchedulesByTeacherId(int teacherId);

  // Lấy danh sách activity theo scheduleId
  Future<List<Activity>> getActivitiesByScheduleId(int scheduleId);

  // Lấy schedule của tuần theo teacherId và weekName
  Future<List<Schedule>> getWeeklySchedule(int teacherId, String weekName);
}
