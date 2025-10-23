import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';

class AiChatService {
  final ApiClient _apiClient;
  AiChatService(this._apiClient);

  Future<String> sendGuestMessage(String message) async {
    try {
      final resp = await _apiClient.post(
        '/ai/chat/guest',
        body: {
          'sessionId': '',
          'userRole': '',
          'message': message,
        },
      );

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw Exception('AI service error (${resp.statusCode})');
      }

      if (resp.body.isEmpty) return '';

  final decoded = jsonDecode(resp.body);
  return _extractReply(decoded);
    } catch (e) {
      debugPrint('AiChatService error: $e');
      rethrow;
    }
  }

  String _extractReply(dynamic decoded) {
    // Try common response shapes
    if (decoded is String) return decoded;

    if (decoded is Map<String, dynamic>) {
      // Exact API shape from Swagger (top-level { isSuccess, message, data: { response, ... } })
      if (decoded.containsKey('data')) {
        final data = decoded['data'];
        if (data is Map<String, dynamic>) {
          final resp = data['response'];
          if (resp is String && resp.trim().isNotEmpty) return resp;
        }
      }

      for (final key in const [
        'message',
        'reply',
        'content',
        'answer',
        'text',
      ]) {
        final v = decoded[key];
        if (v is String && v.trim().isNotEmpty) return v;
      }

      // If wrapped in data/result
      for (final key in const ['data', 'result', 'results']) {
        final v = decoded[key];
        final s = _extractReply(v);
        if (s.isNotEmpty) return s;
      }
    }

    if (decoded is List) {
      // If it's a list of messages, return the first non-empty string entry
      for (final item in decoded) {
        final s = _extractReply(item);
        if (s.isNotEmpty) return s;
      }
    }

    return decoded?.toString() ?? '';
  }
}
