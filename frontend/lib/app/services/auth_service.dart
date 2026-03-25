import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_app/app/services/api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? name,
  }) async {
    final response = await ApiService.post(
      '/auth/register',
      body: {
        'email': email,
        'password': password,
        if (name != null) 'name': name,
      },
      auth: false,
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201) {
      await _saveAuthData(data);
      return data;
    } else {
      throw Exception(data['error'] ?? 'Registration failed');
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      '/auth/login',
      body: {'email': email, 'password': password},
      auth: false,
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      await _saveAuthData(data);
      return data;
    } else {
      throw Exception(data['error'] ?? 'Login failed');
    }
  }

  static Future<void> _saveAuthData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', data['token']);
    final user = data['user'] as Map<String, dynamic>;
    await prefs.setString('user_id', user['id']);
    await prefs.setString('user_email', user['email'] ?? '');
    await prefs.setString('user_name', user['name'] ?? '');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token') != null;
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
