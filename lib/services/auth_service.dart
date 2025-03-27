import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';

  bool _isAuthenticated = false;
  String? _token;
  String? _refreshToken;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;

  Future<SharedPreferences> get _storage => SharedPreferences.getInstance();

  static Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/token/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Store tokens
        final prefs = await _storage;
        await prefs.setString(tokenKey, data['access']);
        await prefs.setString(refreshTokenKey, data['refresh']);

        _token = data['access'];
        _refreshToken = data['refresh'];
        _isAuthenticated = true;
        notifyListeners();

        return data;
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await _storage;
    _token = prefs.getString(tokenKey);
    return _token;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    _isAuthenticated = token != null;
    return _isAuthenticated;
  }

  Future<void> logout() async {
    final prefs = await _storage;
    await prefs.remove(tokenKey);
    await prefs.remove(refreshTokenKey);
    _token = null;
    _refreshToken = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<String> refreshToken() async {
    final prefs = await _storage;
    final refreshToken = _refreshToken ?? prefs.getString(refreshTokenKey);

    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'refresh': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['access'];
        await prefs.setString(tokenKey, _token!);
        notifyListeners();
        return _token!;
      } else {
        _isAuthenticated = false;
        notifyListeners();
        throw Exception('Failed to refresh token: ${response.body}');
      }
    } catch (e) {
      _isAuthenticated = false;
      notifyListeners();
      throw Exception('Failed to connect to server: $e');
    }
  }
}
