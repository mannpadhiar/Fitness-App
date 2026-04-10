import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class FoodRecommendationService {
  static String get _baseUrl =>
      dotenv.env['FOOD_RECOMMENDATION_URL'] ?? 'http://10.0.2.2:5000/recommend';

  /// Fetches food recommendations based on target and consumed macros.
  ///
  /// Returns a list of recommended food items, each with:
  /// `food_name`, `calories`, `carbs`, `protein`, `fat`
  static Future<List<Map<String, dynamic>>> getRecommendations({
    required int targetCalories,
    required int targetCarbs,
    required int targetProtein,
    required int targetFat,
    required int consumedCalories,
    required double consumedCarbs,
    required double consumedProtein,
    required double consumedFat,
  }) async {
    try {
      final body = {
        'target': {
          'calories': targetCalories,
          'carbs': targetCarbs,
          'protein': targetProtein,
          'fat': targetFat,
        },
        'consumed': {
          'calories': consumedCalories,
          'carbs': consumedCarbs.round(),
          'protein': consumedProtein.round(),
          'fat': consumedFat.round(),
        },
      };

      debugPrint('Food Recommendation Request: ${jsonEncode(body)}');

      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('Food Recommendation Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(decoded);
        } else if (decoded is Map && decoded.containsKey('recommendations')) {
          return List<Map<String, dynamic>>.from(decoded['recommendations']);
        } else if (decoded is Map && decoded.containsKey('data')) {
          return List<Map<String, dynamic>>.from(decoded['data']);
        }
        return [];
      } else {
        debugPrint('Recommendation API error: ${response.body}');
        throw Exception('Failed to fetch recommendations: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Food recommendation error: $e');
      rethrow;
    }
  }
}
