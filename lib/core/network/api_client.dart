import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';
import '../config/app_config.dart';

class ApiClient {
  static String get baseUrl => AppConfig.currentApiBaseUrl;
  final StorageService _storageService;
  
  ApiClient(this._storageService);

  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    final token = await _storageService.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
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

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
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

  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
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

  Future<void> _handleAuthErrors(http.Response response) async {
    if (response.statusCode == 401 || response.statusCode == 403) {
      await _storageService.clearAuthData();
      throw UnauthorizedException('Authentication failed');
    }
  }

  Exception _handleException(dynamic error) {
    if (error is SocketException) {
      return NetworkException('No internet connection. Please check your network settings.');
    } else if (error is HttpException) {
      return NetworkException('Server error. Please try again later.');
    } else if (error is FormatException) {
      return NetworkException('Invalid response format from server.');
    } else if (error.toString().contains('Connection refused')) {
      return NetworkException('Cannot connect to server. Make sure the API is running.');
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