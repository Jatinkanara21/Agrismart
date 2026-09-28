import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000/api/v1');
  final String baseUrl;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  Future<Map<String,dynamic>> post(String path, Map<String,dynamic> body) async { final token=await storage.read(key:'token'); final r=await http.post(Uri.parse('$baseUrl$path'),headers:{'Content-Type':'application/json',if(token!=null)'Authorization':'Bearer $token'},body:jsonEncode(body)); final data=jsonDecode(r.body) as Map<String,dynamic>; if(r.statusCode>=400) throw ApiException(data['message']?.toString() ?? 'Request failed',r.statusCode); return data; }
  Future<Map<String,dynamic>> get(String path) async { final token=await storage.read(key:'token'); final r=await http.get(Uri.parse('$baseUrl$path'),headers:{if(token!=null)'Authorization':'Bearer $token'}); final data=jsonDecode(r.body) as Map<String,dynamic>; if(r.statusCode>=400) throw ApiException(data['message']?.toString() ?? 'Request failed',r.statusCode); return data; }
}
class ApiException implements Exception { const ApiException(this.message,this.statusCode); final String message; final int statusCode; }
