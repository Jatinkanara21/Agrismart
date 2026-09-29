import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({String? baseUrl})
      : baseUrl = baseUrl ??
            const String.fromEnvironment(
              'API_BASE_URL',
              defaultValue: '',
            );

  final String baseUrl;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  String get _resolvedBaseUrl {
    if (baseUrl.trim().isNotEmpty) {
      return baseUrl.replaceAll(RegExp(r'/$'), '');
    }
    if (!kIsWeb) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    throw const ApiException(
      'The AgriSmart API URL is not configured for web.',
      0,
    );
  }

  Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> body) async {
    final token = await storage.read(key: 'token');
    final response = await http.post(
      Uri.parse('$_resolvedBaseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> get(String path) async {
    final token = await storage.read(key: 'token');
    final response = await http.get(
      Uri.parse('$_resolvedBaseUrl$path'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> postMultipart(String path, String field, List<int> bytes, String filename) async {
    final token = await storage.read(key: 'token');
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_resolvedBaseUrl$path'),
    );
    request.headers['Accept'] = 'application/json';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      http.MultipartFile.fromBytes(field, bytes, filename: filename),
    );
    final response = await http.Response.fromStream(await request.send());
    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> data;
    try {
      final decoded = jsonDecode(response.body);
      data = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{'message': 'Invalid API response'};
    } catch (_) {
      throw ApiException(
        'The API returned an invalid response (${response.statusCode}).',
        response.statusCode,
      );
    }

    if (response.statusCode >= 400) {
      throw ApiException(
        data['message']?.toString() ?? data['detail']?.toString() ?? 'Request failed',
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

  @override
  String toString() => 'ApiException($statusCode): $message';
}