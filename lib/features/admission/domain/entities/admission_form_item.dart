class AdmissionFormItem {
  final int id;
  final int studentId;
  final int admissionTermId;
  final List<int> classIds;
  final String status; // e.g., pending/approved/rejected
  final String? createdAt;
  final String? updatedAt;
  final Map<String, dynamic>? student; // optional enriched student object
  final String? admissionTermStartDate;
  final String? admissionTermEndDate;
  final String? submittedDate;
  final String? paymentExpiryDate;
  final String? approvedDate;
  final String? cancelReason;

  const AdmissionFormItem({
    required this.id,
    required this.studentId,
    required this.admissionTermId,
    required this.classIds,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.student,
    this.admissionTermStartDate,
    this.admissionTermEndDate,
    this.submittedDate,
    this.paymentExpiryDate,
    this.approvedDate,
    this.cancelReason,
  });

  factory AdmissionFormItem.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }
    final classes = <int>[];
    final raw = json['classIds'];
    if (raw is List) {
      for (final e in raw) {
        final n = toInt(e);
        if (n > 0) classes.add(n);
      }
    }
    return AdmissionFormItem(
      id: toInt(json['id']),
      studentId: toInt(json['studentId'] ?? (json['student'] is Map ? (json['student']['id']) : 0)),
      admissionTermId: toInt(json['admissionTermId']),
      classIds: classes,
      status: (json['status'] ?? '').toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      student: json['student'] is Map<String, dynamic> ? (json['student'] as Map<String, dynamic>) : null,
      admissionTermStartDate: json['admissionTermStartDate']?.toString(),
      admissionTermEndDate: json['admissionTermEndDate']?.toString(),
      submittedDate: json['submittedDate']?.toString(),
      paymentExpiryDate: json['paymentExpiryDate']?.toString(),
      approvedDate: json['approvedDate']?.toString(),
      cancelReason: json['cancelReason']?.toString(),
    );
  }
}
