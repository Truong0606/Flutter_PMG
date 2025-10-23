class AdmissionNotAvailableException implements Exception {
  final String message;
  const AdmissionNotAvailableException([
    this.message = 'Admission is currently not available.',
  ]);

  @override
  String toString() => message;
}
