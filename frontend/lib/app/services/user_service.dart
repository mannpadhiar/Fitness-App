import 'dart:convert';
import 'package:fitness_app/app/services/api_service.dart';

class UserService {
  static Future<Map<String, dynamic>> getUser(String userId) async {
    final response = await ApiService.get('/users/$userId');
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load user');
    }
  }

  static Future<Map<String, dynamic>> updateUser(
    String userId,
    Map<String, dynamic> data,
  ) async {
    final response = await ApiService.put('/users/$userId', body: data);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to update user');
    }
  }
}
