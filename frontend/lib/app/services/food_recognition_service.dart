import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FoodRecognitionService {
  static const String _baseUrl =
      'https://mannPadhiyar11-food-image-classifier-model.hf.space';

  static Future<Map<String, dynamic>> recognizeFood(File imageFile) async {
    try {
      debugPrint('Starting food recognition...');
      final hfToken = dotenv.env['HF_TOKEN'] ?? '';

      final imageBytes = await imageFile.readAsBytes();
      debugPrint('Image bytes: ${imageBytes.length}');

      final filename = imageFile.path.split('/').last;
      final mimeType =
      imageFile.path.endsWith('.png') ? 'image/png' : 'image/jpeg';

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 60);

      try {
        // ── STEP 1: Upload image to Gradio's /upload endpoint ────────────
        final uploadUri = Uri.parse('$_baseUrl/gradio_api/upload');
        final boundary = 'boundary${DateTime.now().millisecondsSinceEpoch}';

        final uploadRequest = await client.postUrl(uploadUri);
        uploadRequest.headers.set(
          'Content-Type',
          'multipart/form-data; boundary=$boundary',
        );
        if (hfToken.isNotEmpty) {
          uploadRequest.headers.set('Authorization', 'Bearer $hfToken');
        }

        // Build multipart body manually
        final bodyBuffer = BytesBuilder();
        bodyBuffer.add(utf8.encode('--$boundary\r\n'));
        bodyBuffer.add(utf8.encode(
          'Content-Disposition: form-data; name="files"; filename="$filename"\r\n'
              'Content-Type: $mimeType\r\n\r\n',
        ));
        bodyBuffer.add(imageBytes);
        bodyBuffer.add(utf8.encode('\r\n--$boundary--\r\n'));

        final body = bodyBuffer.toBytes();
        uploadRequest.headers.contentLength = body.length;
        uploadRequest.add(body);

        final uploadResponse =
        await uploadRequest.close().timeout(const Duration(seconds: 60));
        final uploadBody =
        await uploadResponse.transform(utf8.decoder).join();
        debugPrint('Upload status: ${uploadResponse.statusCode}');
        debugPrint('Upload response: $uploadBody');

        if (uploadResponse.statusCode != 200) {
          throw Exception('Upload failed: $uploadBody');
        }

        // Response is a JSON array of file paths e.g. ["/tmp/gradio/abc.jpg"]
        final List<dynamic> uploadedFiles = jsonDecode(uploadBody);
        final String uploadedPath = uploadedFiles[0] as String;
        debugPrint('Uploaded file path: $uploadedPath');

        // ── STEP 2: POST to /gradio_api/call/detect_food → get event_id ──
        final postUri =
        Uri.parse('$_baseUrl/gradio_api/call/detect_food');
        final postRequest = await client.postUrl(postUri);
        postRequest.headers.set('Content-Type', 'application/json');
        if (hfToken.isNotEmpty) {
          postRequest.headers.set('Authorization', 'Bearer $hfToken');
        }

        final requestBody = jsonEncode({
          "data": [
            {
              "path": uploadedPath,
              "orig_name": filename,
              "mime_type": mimeType,
              "meta": {"_type": "gradio.FileData"}
            }
          ]
        });

        postRequest.write(requestBody);

        final postResponse =
        await postRequest.close().timeout(const Duration(seconds: 60));
        final postBody =
        await postResponse.transform(utf8.decoder).join();
        debugPrint('POST status: ${postResponse.statusCode}');
        debugPrint('POST response: $postBody');

        if (postResponse.statusCode != 200) {
          throw Exception(
              'POST /detect_food failed with status ${postResponse.statusCode}: $postBody');
        }

        final postResult = jsonDecode(postBody) as Map<String, dynamic>;
        final eventId = postResult['event_id'] as String?;

        if (eventId == null || eventId.isEmpty) {
          throw Exception('No event_id returned from API');
        }

        debugPrint('Got event_id: $eventId');

        // ── STEP 3: GET /gradio_api/call/detect_food/{event_id} → SSE ────
        final getUri = Uri.parse(
            '$_baseUrl/gradio_api/call/detect_food/$eventId');
        final getRequest = await client.getUrl(getUri);
        if (hfToken.isNotEmpty) {
          getRequest.headers.set('Authorization', 'Bearer $hfToken');
        }

        final getResponse =
        await getRequest.close().timeout(const Duration(seconds: 90));
        final getBody =
        await getResponse.transform(utf8.decoder).join();
        debugPrint('GET status: ${getResponse.statusCode}');
        debugPrint('GET response: $getBody');

        if (getResponse.statusCode != 200) {
          throw Exception(
              'GET /predict failed with status ${getResponse.statusCode}: $getBody');
        }

        final prediction = _parseSSEResponse(getBody);
        debugPrint('Parsed prediction: $prediction');

        String foodName = _extractFoodName(prediction);
        debugPrint('Detected food: $foodName');

        foodName = _cleanFoodName(foodName);

        return _extractNutrition(foodName, prediction);
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('Food recognition error: $e');
      if (e is Exception) rethrow;
      throw Exception('Food recognition failed: $e');
    }
  }

  /// Parse Gradio SSE (Server-Sent Events) response.
  /// Format:
  ///   event: complete
  ///   data: [{"label": "pizza", ...}]
  static dynamic _parseSSEResponse(String sseBody) {
    final lines = sseBody.split('\n');
    String? lastData;

    for (final line in lines) {
      if (line.startsWith('data: ')) {
        lastData = line.substring(6).trim();
      }
    }

    if (lastData == null || lastData.isEmpty) {
      throw Exception('No data found in SSE response');
    }

    try {
      return jsonDecode(lastData);
    } catch (e) {
      debugPrint('Failed to parse SSE data as JSON: $lastData');
      return lastData;
    }
  }

  /// Extract food name from the parsed prediction result
  static String _extractFoodName(dynamic result) {
    try {
      // Format: [{"label": "pizza", "confidences": [...]}]
      if (result is List && result.isNotEmpty) {
        final first = result[0];
        if (first is String) return first;
        if (first is Map) {
          if (first.containsKey('label')) return first['label'].toString();
          if (first.containsKey('value')) return first['value'].toString();
          if (first.containsKey('confidences')) {
            final confs = first['confidences'];
            if (confs is List && confs.isNotEmpty) {
              return confs[0]['label']?.toString() ?? 'Unknown Food';
            }
          }
        }
      }

      // Format: {"data": [...]}
      if (result is Map) {
        final data = result['data'];
        if (data is List && data.isNotEmpty) {
          return _extractFoodName(data);
        }
        if (result.containsKey('label')) return result['label'].toString();
        if (result.containsKey('value')) return result['value'].toString();
      }

      // Format: plain string
      if (result is String) return result;
    } catch (e) {
      debugPrint('Error parsing prediction: $e');
    }
    return 'Unknown Food';
  }

  /// Clean up the food name
  static String _cleanFoodName(String name) {
    name = name.replaceAll('_', ' ').trim();
    if (name.isEmpty) return 'Unknown Food';
    return name.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Extract nutrition values from prediction, or estimate them
  static Map<String, dynamic> _extractNutrition(
      String foodName, dynamic prediction) {
    double? calories, protein, carbs, fats;

    try {
      if (prediction is List && prediction.length > 1) {
        final nutritionData = prediction[1];
        if (nutritionData is Map) {
          calories = _toDouble(nutritionData['calories']);
          protein = _toDouble(nutritionData['protein']);
          carbs = _toDouble(nutritionData['carbs']);
          fats = _toDouble(nutritionData['fats'] ?? nutritionData['fat']);
        }
      }
    } catch (e) {
      debugPrint('Nutrition extraction from model failed: $e');
    }

    final estimates = _estimateNutrition(foodName);

    return {
      'name': foodName,
      'calories': calories?.round() ?? estimates['calories'],
      'protein': protein ?? estimates['protein'],
      'carbs': carbs ?? estimates['carbs'],
      'fats': fats ?? estimates['fats'],
    };
  }

  static double? _toDouble(dynamic val) {
    if (val == null) return null;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) return double.tryParse(val);
    return null;
  }

  /// Common food nutrition estimates (per 100g) as fallback
  static Map<String, dynamic> _estimateNutrition(String foodName) {
    final name = foodName.toLowerCase();

    final Map<String, Map<String, dynamic>> knownFoods = {
      'pizza': {'calories': 266, 'protein': 11.0, 'carbs': 33.0, 'fats': 10.0},
      'burger': {'calories': 295, 'protein': 17.0, 'carbs': 24.0, 'fats': 14.0},
      'hamburger': {'calories': 295, 'protein': 17.0, 'carbs': 24.0, 'fats': 14.0},
      'salad': {'calories': 65, 'protein': 3.0, 'carbs': 7.0, 'fats': 3.0},
      'rice': {'calories': 130, 'protein': 2.7, 'carbs': 28.0, 'fats': 0.3},
      'pasta': {'calories': 131, 'protein': 5.0, 'carbs': 25.0, 'fats': 1.1},
      'noodles': {'calories': 138, 'protein': 4.5, 'carbs': 25.0, 'fats': 2.0},
      'chicken': {'calories': 239, 'protein': 27.0, 'carbs': 0.0, 'fats': 14.0},
      'steak': {'calories': 271, 'protein': 26.0, 'carbs': 0.0, 'fats': 18.0},
      'fish': {'calories': 206, 'protein': 22.0, 'carbs': 0.0, 'fats': 12.0},
      'egg': {'calories': 155, 'protein': 13.0, 'carbs': 1.1, 'fats': 11.0},
      'bread': {'calories': 265, 'protein': 9.0, 'carbs': 49.0, 'fats': 3.2},
      'sandwich': {'calories': 250, 'protein': 12.0, 'carbs': 30.0, 'fats': 9.0},
      'sushi': {'calories': 143, 'protein': 5.8, 'carbs': 26.0, 'fats': 1.1},
      'soup': {'calories': 60, 'protein': 3.0, 'carbs': 8.0, 'fats': 1.5},
      'cake': {'calories': 350, 'protein': 4.0, 'carbs': 50.0, 'fats': 15.0},
      'ice cream': {'calories': 207, 'protein': 3.5, 'carbs': 24.0, 'fats': 11.0},
      'fries': {'calories': 312, 'protein': 3.4, 'carbs': 41.0, 'fats': 15.0},
      'french fries': {'calories': 312, 'protein': 3.4, 'carbs': 41.0, 'fats': 15.0},
      'hot dog': {'calories': 290, 'protein': 10.0, 'carbs': 24.0, 'fats': 17.0},
      'taco': {'calories': 226, 'protein': 9.0, 'carbs': 20.0, 'fats': 12.0},
      'donut': {'calories': 452, 'protein': 5.0, 'carbs': 51.0, 'fats': 25.0},
      'apple': {'calories': 52, 'protein': 0.3, 'carbs': 14.0, 'fats': 0.2},
      'banana': {'calories': 89, 'protein': 1.1, 'carbs': 23.0, 'fats': 0.3},
      'orange': {'calories': 47, 'protein': 0.9, 'carbs': 12.0, 'fats': 0.1},
      'dal': {'calories': 120, 'protein': 9.0, 'carbs': 20.0, 'fats': 0.4},
      'roti': {'calories': 264, 'protein': 8.0, 'carbs': 50.0, 'fats': 3.0},
      'chapati': {'calories': 264, 'protein': 8.0, 'carbs': 50.0, 'fats': 3.0},
      'naan': {'calories': 262, 'protein': 9.0, 'carbs': 45.0, 'fats': 5.0},
      'biryani': {'calories': 200, 'protein': 7.0, 'carbs': 25.0, 'fats': 8.0},
      'curry': {'calories': 150, 'protein': 6.0, 'carbs': 12.0, 'fats': 8.0},
      'paneer': {'calories': 265, 'protein': 18.0, 'carbs': 1.0, 'fats': 21.0},
      'dosa': {'calories': 168, 'protein': 4.0, 'carbs': 27.0, 'fats': 5.0},
      'idli': {'calories': 58, 'protein': 2.0, 'carbs': 12.0, 'fats': 0.2},
      'aloo gobi': {'calories': 150, 'protein': 4.0, 'carbs': 20.0, 'fats': 6.0},
      'aloo paratha': {'calories': 280, 'protein': 7.0, 'carbs': 38.0, 'fats': 11.0},
      'anda curry': {'calories': 180, 'protein': 12.0, 'carbs': 8.0, 'fats': 11.0},
      'chana masala': {'calories': 164, 'protein': 8.0, 'carbs': 22.0, 'fats': 5.0},
      'chole bhature': {'calories': 350, 'protein': 10.0, 'carbs': 48.0, 'fats': 14.0},
      'dabeli': {'calories': 220, 'protein': 6.0, 'carbs': 35.0, 'fats': 7.0},
      'dal khichdi': {'calories': 140, 'protein': 6.0, 'carbs': 22.0, 'fats': 3.0},
      'dhokla': {'calories': 160, 'protein': 5.0, 'carbs': 26.0, 'fats': 4.0},
      'falooda': {'calories': 190, 'protein': 4.0, 'carbs': 35.0, 'fats': 5.0},
      'fish curry': {'calories': 170, 'protein': 18.0, 'carbs': 6.0, 'fats': 8.0},
      'garlic bread': {'calories': 290, 'protein': 7.0, 'carbs': 40.0, 'fats': 12.0},
      'garlic naan': {'calories': 270, 'protein': 8.0, 'carbs': 44.0, 'fats': 7.0},
      'grilled sandwich': {'calories': 240, 'protein': 11.0, 'carbs': 28.0, 'fats': 9.0},
      'gulab jamun': {'calories': 380, 'protein': 5.0, 'carbs': 55.0, 'fats': 15.0},
      'hara bhara kabab': {'calories': 180, 'protein': 7.0, 'carbs': 22.0, 'fats': 7.0},
      'kulfi': {'calories': 220, 'protein': 5.0, 'carbs': 28.0, 'fats': 10.0},
      'margherita pizza': {'calories': 250, 'protein': 10.0, 'carbs': 32.0, 'fats': 9.0},
      'masala dosa': {'calories': 200, 'protein': 5.0, 'carbs': 30.0, 'fats': 7.0},
      'masala papad': {'calories': 140, 'protein': 5.0, 'carbs': 20.0, 'fats': 5.0},
      'palak paneer': {'calories': 220, 'protein': 10.0, 'carbs': 10.0, 'fats': 15.0},
      'paneer masala': {'calories': 250, 'protein': 12.0, 'carbs': 12.0, 'fats': 17.0},
      'paneer pizza': {'calories': 260, 'protein': 12.0, 'carbs': 32.0, 'fats': 10.0},
      'pav bhaji': {'calories': 200, 'protein': 5.0, 'carbs': 30.0, 'fats': 7.0},
      'poha': {'calories': 130, 'protein': 3.0, 'carbs': 24.0, 'fats': 3.0},
      'rasgulla': {'calories': 186, 'protein': 4.0, 'carbs': 38.0, 'fats': 2.0},
      'samosa': {'calories': 308, 'protein': 6.0, 'carbs': 32.0, 'fats': 17.0},
      'seekh kebab': {'calories': 220, 'protein': 18.0, 'carbs': 5.0, 'fats': 14.0},
      'steamed momo': {'calories': 180, 'protein': 9.0, 'carbs': 25.0, 'fats': 4.0},
      'thali': {'calories': 500, 'protein': 18.0, 'carbs': 65.0, 'fats': 18.0},
      'uttapam': {'calories': 170, 'protein': 5.0, 'carbs': 28.0, 'fats': 4.0},
      'vada pav': {'calories': 290, 'protein': 7.0, 'carbs': 40.0, 'fats': 12.0},
      'chicken pizza': {'calories': 270, 'protein': 14.0, 'carbs': 32.0, 'fats': 10.0},
      'chicken wings': {'calories': 290, 'protein': 24.0, 'carbs': 8.0, 'fats': 18.0},
    };

    for (final entry in knownFoods.entries) {
      if (name.contains(entry.key)) {
        return entry.value;
      }
    }

    // Generic fallback
    return {'calories': 200, 'protein': 8.0, 'carbs': 25.0, 'fats': 8.0};
  }
}