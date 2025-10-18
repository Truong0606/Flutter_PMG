
import '../entities/classes.dart';
import '../entities/schedule.dart';

abstract class TeacherActionRepository {
  // Lấy danh sách lớp theo teacherId
  Future<List<Classes>> getClassList();

  // Lấy danh sách schedule theo teacherId
  Future<List<Schedule>> getScheduleList();
  
  Future<List<Schedule>> getWeeklySchedule(String weekName);
}
