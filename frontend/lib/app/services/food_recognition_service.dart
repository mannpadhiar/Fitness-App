import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';

class FoodRecognitionService {
  static const String _apiUrl =
      'https://mannPadhiyar11-food-image-classifier-model.hf.space/gradio_api/call/detect_food';

  /// Sends a food image to the HuggingFace classifier and returns the
  /// predicted food name along with random placeholder nutrition values.
  static Future<Map<String, dynamic>> recognizeFood(File imageFile) async {
    try {
      debugPrint('Starting food recognition...');

      // Convert image to base64
      final imageBytes = await imageFile.readAsBytes();
      debugPrint('Image byte (${imageBytes.length} bytes)');

      final base64Image = base64Encode(imageBytes);
      debugPrint('Image encoded to base64 ($base64Image)');

      // Build JSON body
      final requestBody =  jsonEncode({
        "data": [
          {
            "data": base64Image,
            "name": "image.jpg"
          }
        ]
      });

      // Use dart:io HttpClient directly to avoid http package _Namespace issue
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 60);

      try {
        final uri = Uri.parse(_apiUrl);
        final request = await client.postUrl(uri);
        request.headers.set('Content-Type', 'application/json');
        request.write(requestBody);

        final response = await request.close().timeout(
          const Duration(seconds: 60),
        );

        final responseBody = await response.transform(utf8.decoder).join();
        debugPrint('API response status: ${response.statusCode}');
        debugPrint('API response body: $responseBody');

        if (response.statusCode == 200) {
          final result = jsonDecode(responseBody);
          String foodName = _extractFoodName(result);
          debugPrint('Detected food: $foodName');

          foodName = _cleanFoodName(foodName);
          return _generatePlaceholderNutrition(foodName);
        } else {
          throw Exception('API returned status ${response.statusCode}');
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('Food recognition error: $e');
      if (e is Exception) rethrow;
      throw Exception('Food recognition failed: $e');
    }
  }

  /// Extract food name from various possible API response formats
  static String _extractFoodName(dynamic result) {
    try {
      if (result is! Map) return 'Unknown Food';

      final data = result['data'];
      if (data == null || data is! List || data.isEmpty) return 'Unknown Food';

      final prediction = data[0];

      // Format 1: Simple string "food_name"
      if (prediction is String) {
        return prediction;
      }

      // Format 2: Map with "label" key
      if (prediction is Map) {
        if (prediction.containsKey('label')) {
          return prediction['label'].toString();
        }
        if (prediction.containsKey('value')) {
          return prediction['value'].toString();
        }
        // Format 3: Map with "confidences" array
        if (prediction.containsKey('confidences')) {
          final confidences = prediction['confidences'];
          if (confidences is List && confidences.isNotEmpty) {
            return confidences[0]['label']?.toString() ?? 'Unknown Food';
          }
        }
      }
    } catch (e) {
      debugPrint('Error parsing prediction: $e');
    }
    return 'Unknown Food';
  }

  /// Clean up the food name from the API response
  static String _cleanFoodName(String name) {
    name = name.replaceAll('_', ' ').trim();
    if (name.isEmpty) return 'Unknown Food';
    return name.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Generate random but realistic placeholder nutrition values
  static Map<String, dynamic> _generatePlaceholderNutrition(String foodName) {
    final random = Random();

    final calories = 100 + random.nextInt(400);
    final protein = 2.0 + random.nextDouble() * 28;
    final carbs = 5.0 + random.nextDouble() * 55;
    final fats = 2.0 + random.nextDouble() * 23;

    return {
      'name': foodName,
      'calories': calories,
      'protein': double.parse(protein.toStringAsFixed(1)),
      'carbs': double.parse(carbs.toStringAsFixed(1)),
      'fats': double.parse(fats.toStringAsFixed(1)),
    };
  }
}
