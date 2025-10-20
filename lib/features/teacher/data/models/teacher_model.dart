import '../../domain/entities/teacher.dart';

class TeacherModel extends Teacher {
  TeacherModel({
    required super.id,
    super.name,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'],
      name: json['name'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
