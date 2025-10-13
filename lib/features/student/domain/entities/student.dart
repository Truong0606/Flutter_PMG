class Student {
  final int id;
  final String name;
  final String gender; // "Male" | "Female" | others
  final String dateOfBirth; // ISO string
  final String? placeOfBirth;
  final String? profileImage;
  final String? householdRegistrationImg;
  final String? birthCertificateImg;
  final bool? isStudent;

  const Student({
    required this.id,
    required this.name,
    required this.gender,
    required this.dateOfBirth,
    this.placeOfBirth,
    this.profileImage,
    this.householdRegistrationImg,
    this.birthCertificateImg,
    this.isStudent,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }
    String? cleanUrl(dynamic v) {
      final s = v?.toString().trim();
      if (s == null || s.isEmpty) return null;
      // Many Swagger mocks return literal "string" for text fields
      if (s.toLowerCase() == 'string' || s.toLowerCase() == 'null') return null;
      final uri = Uri.tryParse(s);
      if (uri == null) return null;
      return (uri.scheme == 'http' || uri.scheme == 'https') ? s : null;
    }
    return Student(
      id: toInt(json['id']),
      name: (json['name'] ?? '').toString(),
      gender: (json['gender'] ?? '').toString(),
      dateOfBirth: (json['dateOfBirth'] ?? '').toString(),
      placeOfBirth: json['placeOfBirth']?.toString(),
      profileImage: cleanUrl(json['profileImage']),
      householdRegistrationImg: cleanUrl(json['householdRegistrationImg']),
      birthCertificateImg: cleanUrl(json['birthCertificateImg']),
      isStudent: json['isStudent'] == null ? null : json['isStudent'] == true || json['isStudent'].toString() == 'true',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'gender': gender,
        'dateOfBirth': dateOfBirth,
        if (placeOfBirth != null) 'placeOfBirth': placeOfBirth,
        if (profileImage != null) 'profileImage': profileImage,
        if (householdRegistrationImg != null) 'householdRegistrationImg': householdRegistrationImg,
        if (birthCertificateImg != null) 'birthCertificateImg': birthCertificateImg,
        if (isStudent != null) 'isStudent': isStudent,
      };
}
