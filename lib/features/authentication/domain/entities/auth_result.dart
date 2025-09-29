import 'user.dart';

class AuthResult {
  final bool success;
  final String? error;
  final User? user;
  final String? token;
  final int? status;

  const AuthResult({
    required this.success,
    this.error,
    this.user,
    this.token,
    this.status,
  });

  factory AuthResult.success(User user, String token) {
    return AuthResult(
      success: true,
      user: user,
      token: token,
    );
  }

  factory AuthResult.failure(String error, [int? status]) {
    return AuthResult(
      success: false,
      error: error,
      status: status,
    );
  }
}