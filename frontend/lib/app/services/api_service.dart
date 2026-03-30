import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  static String baseUrl = dotenv.env['BASE_URL']!;

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (auth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<http.Response> get(String path, {bool auth = true}) async {
    final headers = await _headers(auth: auth);
    return http.get(Uri.parse('$baseUrl$path'), headers: headers);
  }

  static Future<http.Response> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final headers = await _headers(auth: auth);
    return http.post(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  static Future<http.Response> put(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final headers = await _headers(auth: auth);
    return http.put(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  static Future<http.Response> delete(String path, {bool auth = true}) async {
    final headers = await _headers(auth: auth);
    return http.delete(Uri.parse('$baseUrl$path'), headers: headers);
  }
}
