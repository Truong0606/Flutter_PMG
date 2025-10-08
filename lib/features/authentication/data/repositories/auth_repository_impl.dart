import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;

  AuthRepositoryImpl(this._apiClient, this._storageService);

  @override
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await _apiClient.post('/auth/login', body: {
        'email': email,
        'password': password,
      });

      // Check if response body is empty or invalid
      if (response.body.isEmpty) {
        return AuthResult.failure(
          'Server returned empty response. Status: ${response.statusCode}. The API server appears to be having issues. Please try again later or contact support.',
          response.statusCode,
        );
      }

      // Handle server errors with better messages
      if (response.statusCode >= 500) {
        return AuthResult.failure(
          'Server error (${response.statusCode}). The API server is currently experiencing issues. Please try again later.',
          response.statusCode,
        );
      }

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        return AuthResult.failure(
          'Invalid response format from server.',
          response.statusCode,
        );
      }

      if (response.statusCode == 200 && data['token'] != null) {
        final token = data['token'];
        
        // Decode JWT token to get user info
        final jwt = JWT.decode(token);
        final payload = jwt.payload as Map<String, dynamic>;
        
        // Create user object
        final user = User(
          id: payload['sub'] ?? '',
          email: payload['email'] ?? email,
          name: data['name'] ?? '',
          role: payload['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ?? data['role'] ?? '',
          token: token,
          tokenExpiry: payload['exp'] != null
              ? DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000)
              : null,
        );

        // Save to local storage
        await _storageService.saveToken(token);
        await _storageService.saveUser(user);

        return AuthResult.success(user, token);
      }

      return AuthResult.failure(
        data['message'] ?? 'Login failed',
        response.statusCode,
      );
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  @override
  Future<AuthResult> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _apiClient.post('/auth/register', body: {
        'email': email,
        'password': password,
        'name': name,
        'role': 'PARENT',
      });

      // Check if response body is empty or invalid
      if (response.body.isEmpty) {
        return AuthResult.failure(
          'Server returned empty response. Status: ${response.statusCode}. The API server appears to be having issues.',
          response.statusCode,
        );
      }

      // Handle server errors with better messages
      if (response.statusCode >= 500) {
        return AuthResult.failure(
          'Server error (${response.statusCode}). The API server is currently experiencing issues. Please try again later.',
          response.statusCode,
        );
      }

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        return AuthResult.failure(
          'Invalid response format from server.',
          response.statusCode,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final user = User(
          id: (data['id'] ?? '').toString(),
          email: (data['email'] ?? email).toString(),
          name: (data['name'] ?? name).toString(),
          role: (data['role'] ?? 'PARENT').toString(),
          phone: data['phone']?.toString(),
        );

        return AuthResult.success(user, '');
      }

      return AuthResult.failure(
        data['message'] ?? 'Registration failed',
        response.statusCode,
      );
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    await _storageService.clearAuthData();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await _storageService.getUser();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _storageService.isLoggedIn();
  }
}