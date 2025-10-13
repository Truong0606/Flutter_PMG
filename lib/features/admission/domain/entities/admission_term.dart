class AdmissionClassPattern {
  final String dayOfWeek;
  final String startTime; // HH:mm:ss
  final String endTime;   // HH:mm:ss
  const AdmissionClassPattern({required this.dayOfWeek, required this.startTime, required this.endTime});

  factory AdmissionClassPattern.fromJson(Map<String, dynamic> json) => AdmissionClassPattern(
        dayOfWeek: (json['dayOfWeek'] ?? '').toString(),
        startTime: (json['startTime'] ?? '').toString(),
        endTime: (json['endTime'] ?? '').toString(),
      );
}

class AdmissionClassDto {
  final int id;
  final String name;
  final int numberStudent;
  final int academicYear;
  final int numberOfWeeks;
  final String startDate; // yyyy-MM-dd
  final num cost;
  final String status; // active/inactive
  final List<AdmissionClassPattern> patterns;

  const AdmissionClassDto({
    required this.id,
    required this.name,
    required this.numberStudent,
    required this.academicYear,
    required this.numberOfWeeks,
    required this.startDate,
    required this.cost,
    required this.status,
    required this.patterns,
  });

  factory AdmissionClassDto.fromJson(Map<String, dynamic> json) => AdmissionClassDto(
        id: _toInt(json['id']),
        name: (json['name'] ?? '').toString(),
        numberStudent: _toInt(json['numberStudent']),
        academicYear: _toInt(json['academicYear']),
        numberOfWeeks: _toInt(json['numberOfWeeks']),
        startDate: (json['startDate'] ?? '').toString(),
        cost: (json['cost'] ?? 0) as num,
        status: (json['status'] ?? '').toString(),
        patterns: (json['patternActivitiesDTO'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(AdmissionClassPattern.fromJson)
            .toList(),
      );
}

class AdmissionTerm {
  final int id;
  final int academicYear;
  final int maxNumberRegistration;
  final int currentRegisteredStudents;
  final int numberOfClasses;
  final String startDate; // ISO
  final String endDate; // ISO
  final String status; // active
  final List<AdmissionClassDto> classes;

  const AdmissionTerm({
    required this.id,
    required this.academicYear,
    required this.maxNumberRegistration,
    required this.currentRegisteredStudents,
    required this.numberOfClasses,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.classes,
  });

  factory AdmissionTerm.fromJson(Map<String, dynamic> json) => AdmissionTerm(
        id: _toInt(json['id']),
        academicYear: _toInt(json['academicYear']),
        maxNumberRegistration: _toInt(json['maxNumberRegistration']),
        currentRegisteredStudents: _toInt(json['currentRegisteredStudents']),
        numberOfClasses: _toInt(json['numberOfClasses']),
        startDate: (json['startDate'] ?? '').toString(),
        endDate: (json['endDate'] ?? '').toString(),
        status: (json['status'] ?? '').toString(),
        classes: (json['classDtos'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(AdmissionClassDto.fromJson)
            .toList(),
      );
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}
