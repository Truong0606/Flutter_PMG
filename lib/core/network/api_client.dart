import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../config/app_config.dart';

class ApiClient {
  static String get baseUrl => AppConfig.currentApiBaseUrl;
  static String get parentBaseUrl => AppConfig.currentParentApiBaseUrl;
  static String get classBaseUrl => AppConfig.currentClassApiBaseUrl;
  final StorageService _storageService;

  ApiClient(this._storageService);

  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': '*/*',
    };

    final token = await _storageService.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (kDebugMode) {
      // Do not print token, only whether it exists
      debugPrint(
        '[ApiClient] Headers: auth=${headers.containsKey('Authorization')}',
      );
    }

    return headers;
  }

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    try {
      final response = await http.get(url, headers: headers);
      await _handleAuthErrors(response);
      return response;
    } catch (e) {
      throw _handleException(e);
    }
  }

  // Parent API
  Future<http.Response> getParent(String endpoint) async {
    final url = Uri.parse('$parentBaseUrl$endpoint');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      await _handleAuthErrors(response);
      return response;
    } catch (e) {
      throw _handleException(e);
    }
  }

  Future<http.Response> postParent(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$parentBaseUrl$endpoint');
    final headers = await _getHeaders();
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      await _handleAuthErrors(response);
      return response;
    } catch (e) {
      throw _handleException(e);
    }
  }

  Future<http.Response> putParent(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$parentBaseUrl$endpoint');
    final headers = await _getHeaders();
    if (kDebugMode) {
      debugPrint('[ApiClient] PUT(parent) $url');
    }
    try {
      final response = await http.put(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      await _handleAuthErrors(response);
      return response;
    } catch (e) {
      throw _handleException(e);
    }
  }

  // Class API
  Future<http.Response> getClass(String endpoint) async {
    final url = Uri.parse('$classBaseUrl$endpoint');
    final headers = await _getHeaders();
    if (kDebugMode) {
      debugPrint('[ApiClient] GET(class) $url');
    }
    try {
      final response = await http.get(url, headers: headers);
      await _handleAuthErrors(response);
      return response;
    } catch (e) {
      throw _handleException(e);
    }
  }

  // Some class-api endpoints (e.g., /term/active) may be public; do not attach Authorization
  Future<http.Response> getClassPublic(String endpoint) async {
    final url = Uri.parse('$classBaseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': '*/*',
    };
    if (kDebugMode) {
      debugPrint('[ApiClient] GET(class-public) $url');
    }
    try {
      final response = await http.get(url, headers: headers);
      // No auth error handling since no token
      return response;
    } catch (e) {
      throw _handleException(e);
    }
  }

  Future<http.Response> postClass(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$classBaseUrl$endpoint');
    final headers = await _getHeaders();
    if (kDebugMode) {
      debugPrint('[ApiClient] POST(class) $url');
    }
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      await _handleAuthErrors(response);
      return response;
    } catch (e) {
      throw _handleException(e);
    }
  }

  Future<http.Response> putClass(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$classBaseUrl$endpoint');
    final headers = await _getHeaders();
    if (kDebugMode) {
      debugPrint('[ApiClient] PUT(class) $url');
    }
    try {
      final response = await http.put(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      await _handleAuthErrors(response);
      return response;
    } catch (e) {
      throw _handleException(e);
    }
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      await _handleAuthErrors(response);
      return response;
    } catch (e) {
      throw _handleException(e);
    }
  }

  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      await _handleAuthErrors(response);
      return response;
    } catch (e) {
      throw _handleException(e);
    }
  }

  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    try {
      final response = await http.delete(url, headers: headers);
      await _handleAuthErrors(response);
      return response;
    } catch (e) {
      throw _handleException(e);
    }
  }

  Future<http.Response> deleteParent(String endpoint) async {
    final url = Uri.parse('$parentBaseUrl$endpoint');
    final headers = await _getHeaders();
    if (kDebugMode) {
      debugPrint('[ApiClient] DELETE(parent) $url');
    }
    try {
      final response = await http.delete(url, headers: headers);
      await _handleAuthErrors(response);
      return response;
    } catch (e) {
      throw _handleException(e);
    }
  }

  Future<void> _handleAuthErrors(http.Response response) async {
    if (response.statusCode == 401 || response.statusCode == 403) {
      await _storageService.clearAuthData();
      throw UnauthorizedException('Authentication failed');
    }
  }

  Exception _handleException(dynamic error) {
    if (error is SocketException) {
      return NetworkException(
        'No internet connection. Please check your network settings.',
      );
    } else if (error is HttpException) {
      return NetworkException('Server error. Please try again later.');
    } else if (error is FormatException) {
      return NetworkException('Invalid response format from server.');
    } else if (error.toString().contains('Connection refused')) {
      return NetworkException(
        'Cannot connect to server. Make sure the API is running.',
      );
    } else {
      return NetworkException('Network error: ${error.toString()}');
    }
  }
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => message;
}
