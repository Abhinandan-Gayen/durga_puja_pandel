import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PandalApiService {
  static const String baseUrl = 'https://phonepe-backend-zcky.onrender.com';

  static Future<Map<String, dynamic>> createPandal({
    required String name,
    required String description,
    required String district,
    required String address,
    required String imageUrl,
    double? latitude,
    double? longitude,
  }) async {
    final url = Uri.parse('$baseUrl/api/pandals');

    final Map<String, dynamic> requestBody = {
      'name': name.trim(),
      'description': description.trim(),
      'district': district.trim(),
      'address': address.trim(),
      'imageUrl': imageUrl.trim(),
    };
    if (latitude != null) requestBody['latitude'] = latitude;
    if (longitude != null) requestBody['longitude'] = longitude;

    if (kDebugMode) {
      debugPrint('Request URL: $url');
      debugPrint('Request Body: ${jsonEncode(requestBody)}');
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');
      }

      if (response.body.isEmpty) {
        throw const FormatException('Empty response from server');
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        final message = responseData['message'] ?? 'Server returned error ${response.statusCode}';
        throw HttpException(message);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error calling API: $e');
      }
      rethrow;
    }
  }
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);

  @override
  String toString() => message;
}
