import 'user.dart';

class AuthResult {
  final bool success;
  final String? error;
  final User? user;
  final String? token;
  final int? status;
  final String? message;

  const AuthResult({
    required this.success,
    this.error,
    this.user,
    this.token,
    this.status,
    this.message,
  });

  factory AuthResult.success(User user, String token, {String? message}) {
    return AuthResult(
      success: true,
      user: user,
      token: token,
      message: message,
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