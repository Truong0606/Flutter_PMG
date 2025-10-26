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

      // New response shape: { isSuccess, message, data: { token, role }, ... }
      final bool isSuccess = data['isSuccess'] == true || data['success'] == true;
      final dynamic dataNode = data['data'];
      String? token;
      String? roleFromApi;
      if (dataNode is Map<String, dynamic>) {
        token = dataNode['token']?.toString();
        roleFromApi = dataNode['role']?.toString();
      } else {
        // Fallback for old shape
        token = data['token']?.toString();
        roleFromApi = data['role']?.toString();
      }

      if (response.statusCode == 200 && token != null && token.isNotEmpty) {
        // Decode JWT token to get user info
        final jwt = JWT.decode(token);
        final payload = jwt.payload as Map<String, dynamic>;

        // Robust exp parsing (seconds since epoch)
        DateTime? tokenExpiry;
        final exp = payload['exp'];
        if (exp != null) {
          final intExp = exp is int ? exp : int.tryParse(exp.toString());
          if (intExp != null) {
            tokenExpiry = DateTime.fromMillisecondsSinceEpoch(intExp * 1000);
          }
        }

        final roleClaim = payload['http://schemas.microsoft.com/ws/2008/06/identity/claims/role']?.toString();
        final role = roleClaim ?? payload['role']?.toString() ?? roleFromApi ?? '';
        final name = payload['unique_name']?.toString() ?? payload['name']?.toString() ?? data['name']?.toString() ?? '';
        final id = payload['id']?.toString() ?? payload['sub']?.toString() ?? '';

        // Create user object
        final user = User(
          id: id,
          email: payload['email']?.toString() ?? email,
          name: name,
          role: role,
          token: token,
          tokenExpiry: tokenExpiry,
        );

        // Save to local storage
        await _storageService.saveToken(token);
        await _storageService.saveUser(user);

        return AuthResult.success(user, token, message: data['message']?.toString());
      }

      // If API says success but token missing, surface clear message
      if (response.statusCode == 200 && isSuccess && (token == null || token.isEmpty)) {
        return AuthResult.failure('Login succeeded but token missing in response', response.statusCode);
      }

      return AuthResult.failure(
        data['message']?.toString() ?? 'Login failed',
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
    String? job,
    String? relationshipToChild,
  }) async {
    try {
      final response = await _apiClient.post('/auth/register-parent', body: {
        'email': email,
        'password': password,
        'name': name,
        // Optional new fields
        if (job != null && job.isNotEmpty) 'job': job,
        if (relationshipToChild != null && relationshipToChild.isNotEmpty) 'relationshipToChild': relationshipToChild,
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

  @override
  Future<AuthResult> getProfile() async {
    try {
      final response = await _apiClient.get('/auth/profile');

      // Handle 204 No Content FIRST - profile is empty/incomplete, create empty user object
      if (response.statusCode == 204) {
        final currentUser = await _storageService.getUser();
        if (currentUser != null) {
          // Preserve existing cached fields; server just says no content
          return AuthResult.success(currentUser, '');
        }
        return AuthResult.failure('Profile is empty and no user session found. Please login again.');
      }

      // Handle different response status codes
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          // Treat empty 200 as a soft success using cached user if available
          final existingUser = await _storageService.getUser();
          if (existingUser != null) {
            return AuthResult(success: true, message: '', user: existingUser, token: null);
          }
          return AuthResult.failure(
            'Unable to load your profile right now. Please try again later.',
            response.statusCode,
          );
        }

        Map<String, dynamic> data;
        try {
          data = jsonDecode(response.body);
        } catch (e) {
          return AuthResult.failure(
            'Invalid response format from server',
            response.statusCode,
          );
        }

        // Preserve token information if the profile payload doesn't include it
        final existingUser = await _storageService.getUser();
        final userFromApi = User.fromJson(data);
        final user = userFromApi.copyWith(
          token: userFromApi.token ?? existingUser?.token,
          tokenExpiry: userFromApi.tokenExpiry ?? existingUser?.tokenExpiry,
        );
        await _storageService.saveUser(user);
        return AuthResult.success(user, '');
      }



      // Handle server errors
      if (response.statusCode >= 500) {
        return AuthResult.failure(
          'Server error (${response.statusCode}). Please try again later.',
          response.statusCode,
        );
      }

      // Handle client errors (4xx)
      String errorMessage = 'Failed to get profile';
      if (response.body.isNotEmpty) {
        try {
          final data = jsonDecode(response.body);
          errorMessage = data['message'] ?? errorMessage;
        } catch (e) {
          // If we can't parse the error, use the default message
        }
      }

      return AuthResult.failure(
        errorMessage,
        response.statusCode,
      );
    } catch (e) {
      return AuthResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<AuthResult> updateProfile({
    required String name,
    String? phone,
    String? address,
    String? avatarUrl,
    String? gender,
    String? identityNumber,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'name': name,
      };
      
      if (phone != null && phone.isNotEmpty) requestBody['phone'] = phone;
      if (address != null && address.isNotEmpty) requestBody['address'] = address;
      if (avatarUrl != null && avatarUrl.isNotEmpty) requestBody['avatarUrl'] = avatarUrl;
      if (gender != null && gender.isNotEmpty) requestBody['gender'] = gender;
      if (identityNumber != null && identityNumber.isNotEmpty) requestBody['identityNumber'] = identityNumber;

      final response = await _apiClient.put('/auth/profile', body: requestBody);

      if (response.statusCode == 204 || (response.statusCode == 200 && response.body.isEmpty)) {
        // Some backends return 204 No Content for successful updates
        final existingUser = await _storageService.getUser();
        if (existingUser != null) {
          final updatedUser = existingUser.copyWith(
            name: name,
            phone: phone ?? existingUser.phone,
            address: address ?? existingUser.address,
            avatarUrl: avatarUrl ?? existingUser.avatarUrl,
            gender: gender ?? existingUser.gender,
            identityNumber: identityNumber ?? existingUser.identityNumber,
          );
          await _storageService.saveUser(updatedUser);
          return AuthResult(success: true, message: 'Profile updated successfully', user: updatedUser, token: null);
        }
        // No existing user to update, but treat as success without exposing details
        return AuthResult(success: true, message: 'Profile updated successfully', user: null, token: null);
      }

      if (response.body.isEmpty) {
        return AuthResult.failure(
          'Server returned empty response. Status: ${response.statusCode}',
          response.statusCode,
        );
      }

      if (response.statusCode >= 500) {
        return AuthResult.failure(
          'Server error (${response.statusCode}). Please try again later.',
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

      if (response.statusCode == 200) {
        final user = User.fromJson(data);
        await _storageService.saveUser(user);
        return AuthResult.success(user, 'Profile updated successfully');
      }

      return AuthResult.failure(
        data['message'] ?? 'Failed to update profile',
        response.statusCode,
      );
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  // New: Forgot Password - request reset token via email
  @override
  Future<AuthResult> forgotPassword({required String email}) async {
    try {
      final response = await _apiClient.post('/auth/pass/forgot', body: {
        'email': email,
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          // Consider success even if body empty; backend might not return details
          return AuthResult(success: true, message: 'If this email exists, a reset token was sent.', user: null, token: null);
        }
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final msg = data['message']?.toString() ?? 'Reset token sent.';
          final token = data['resetToken']?.toString();
          return AuthResult(success: true, message: msg, user: null, token: token);
        } catch (_) {
          return AuthResult(success: true, message: 'Reset token sent.', user: null, token: null);
        }
      }

      String message = 'Failed to request password reset';
      if (response.body.isNotEmpty) {
        try { message = (jsonDecode(response.body) as Map<String, dynamic>)['message']?.toString() ?? message; } catch (_) {}
      }
      return AuthResult.failure(message, response.statusCode);
    } catch (e) {
      return AuthResult.failure('Network error: ${e.toString()}');
    }
  }

  // New: Reset Password using provided resetToken
  @override
  Future<AuthResult> resetPassword({required String email, required String resetToken, required String newPassword}) async {
    try {
      final response = await _apiClient.post('/auth/pass/reset', body: {
        'email': email,
        'token': resetToken,
        'newPassword': newPassword,
      });

      if (response.statusCode == 200) {
        final data = response.body.isNotEmpty ? jsonDecode(response.body) as Map<String, dynamic> : {};
        final msg = data['message']?.toString() ?? 'Password reset successful';
        return AuthResult(success: true, message: msg, user: null, token: null);
      }

      String message = 'Failed to reset password';
      if (response.body.isNotEmpty) {
        try { message = (jsonDecode(response.body) as Map<String, dynamic>)['message']?.toString() ?? message; } catch (_) {}
      }
      return AuthResult.failure(message, response.statusCode);
    } catch (e) {
      return AuthResult.failure('Network error: ${e.toString()}');
    }
  }

  // New: Change Password for authenticated user
  @override
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.post('/auth/change-password', body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.body.isNotEmpty ? jsonDecode(response.body) as Map<String, dynamic> : {};
        final msg = data['message']?.toString() ?? 'Password changed successfully';
        return AuthResult(success: true, message: msg, user: null, token: null);
      }

      String message = 'Failed to change password';
      if (response.body.isNotEmpty) {
        try { message = (jsonDecode(response.body) as Map<String, dynamic>)['message']?.toString() ?? message; } catch (_) {}
      }
      return AuthResult.failure(message, response.statusCode);
    } catch (e) {
      return AuthResult.failure('Network error: ${e.toString()}');
    }
  }
}