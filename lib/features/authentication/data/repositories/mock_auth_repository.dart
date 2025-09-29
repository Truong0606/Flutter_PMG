import '../../domain/entities/auth_result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<AuthResult> login(String email, String password) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock login logic
    if (email == 'test@merrystar.edu.vn' && password == 'password123') {
      final user = User(
        id: '1',
        email: email,
        name: 'Test User',
        role: 'PARENT',
        phone: '+84123456789',
      );
      return AuthResult.success(user, 'mock_token_123');
    } else {
      return AuthResult.failure('Invalid email or password');
    }
  }

  @override
  Future<AuthResult> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock successful registration
    final user = User(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      role: 'PARENT',
      phone: phone,
    );
    return AuthResult.success(user, 'mock_token_${user.id}');
  }

  @override
  Future<void> logout() async {
    // Mock logout - just clear local data
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<User?> getCurrentUser() async {
    // Mock - return null (no user logged in)
    return null;
  }

  @override
  Future<bool> isLoggedIn() async {
    // Mock - always return false for testing
    return false;
  }
}