import 'dart:convert';
import 'package:fitness_app/app/services/api_service.dart';

class DailyService {
  static Future<Map<String, dynamic>> upsertSteps(
    String userId,
    int steps, {
    String? date,
  }) async {
    final body = <String, dynamic>{'steps': steps};
    if (date != null) {
      body['date'] = date;
    }
    final response = await ApiService.post(
      '/users/$userId/daily-steps',
      body: body,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to upsert steps');
    }
  }

  static Future<Map<String, dynamic>> getDailySummary(
    String userId,
    String date,
  ) async {
    final response = await ApiService.get(
      '/users/$userId/daily-summary?date=$date',
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load daily summary');
    }
  }
}
