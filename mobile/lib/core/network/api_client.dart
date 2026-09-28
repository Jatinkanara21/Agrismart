import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({String? baseUrl})
      : baseUrl = baseUrl ??
            const String.fromEnvironment('API_BASE_URL',
                defaultValue: 'http://10.0.2.2:8000/api/v1');

  final String baseUrl;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> body) async {
    final token = await storage.read(key: 'token');
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      throw ApiException(
        data['message']?.toString() ?? 'Request failed',
        response.statusCode,
      );
    }
    return data;
  }

  Future<Map<String, dynamic>> get(String path) async {
    final token = await storage.read(key: 'token');
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      throw ApiException(
        data['message']?.toString() ?? 'Request failed',
        response.statusCode,
      );
    }
    return data;
  }
}

class ApiException implements Exception {
  const ApiException(this.message, this.statusCode);

  final String message;
  final int statusCode;
}
