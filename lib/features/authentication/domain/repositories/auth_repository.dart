import '../entities/auth_result.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<AuthResult> login(String email, String password);
  Future<AuthResult> register({
    required String email,
    required String password,
    required String name,
  });
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<AuthResult> getProfile();
  Future<AuthResult> updateProfile({
    required String name,
    String? phone,
    String? address,
    String? avatarUrl,
    String? gender,
    String? identityNumber,
  });
}