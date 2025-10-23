import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/authentication/domain/entities/user.dart';

class StorageService {
  static const String _tokenKey = 'token';
  static const String _userKey = 'user';
  static const String _guestChatKey = 'guest_ai_chat_history';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return User.fromJson(userMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    final user = await getUser();
    
    if (token == null || user == null) {
      return false;
    }
    
    // Check if token is expired
    if (user.tokenExpiry != null) {
      return DateTime.now().isBefore(user.tokenExpiry!);
    }
    
    return true;
  }

  // ===== Guest AI chat history =====
  Future<void> saveGuestChatHistory(List<Map<String, dynamic>> messages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_guestChatKey, jsonEncode(messages));
  }

  Future<List<Map<String, dynamic>>> getGuestChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_guestChatKey);
    if (jsonStr == null || jsonStr.isEmpty) return <Map<String, dynamic>>[];
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map((e) => {
                  'role': (e['role'] ?? '').toString(),
                  'text': (e['text'] ?? '').toString(),
                })
            .toList();
      }
    } catch (_) {}
    return <Map<String, dynamic>>[];
  }

  Future<void> clearGuestChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_guestChatKey);
  }
}