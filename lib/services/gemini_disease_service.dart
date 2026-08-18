import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class DiseaseAnalysis {
  final String disease;
  final double confidence;
  final String symptoms;
  final String treatment;
  final String prevention;

  const DiseaseAnalysis({
    required this.disease,
    required this.confidence,
    required this.symptoms,
    required this.treatment,
    required this.prevention,
  });
}

class GeminiDiseaseService {
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const _model = 'gemini-2.5-flash-lite';
  static const _endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<DiseaseAnalysis> analyze(XFile image) async {
    if (!isConfigured) {
      throw StateError('Gemini is not configured. Build with --dart-define=GEMINI_API_KEY=YOUR_KEY.');
    }

    final bytes = await image.readAsBytes();
    final mimeType = _mimeType(image.name);
    final prompt = '''You are an agricultural plant-health expert. Analyze this plant image.
Return ONLY valid JSON with exactly these keys:
{"disease":"...","confidence":0.0,"symptoms":"...","treatment":"...","prevention":"..."}
confidence must be a number from 0 to 100. If the image is unclear, say "Unable to determine" and lower confidence. Do not invent a disease with high confidence.''';

    final response = await http.post(
      Uri.parse('$_endpoint?key=$_apiKey'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inline_data': {
                  'mime_type': mimeType,
                  'data': base64Encode(bytes),
                },
              },
            ],
          },
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'temperature': 0.2,
        },
      }),
    ).timeout(const Duration(seconds: 45));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gemini request failed (${response.statusCode}).');
    }

    final root = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = root['candidates'] as List<dynamic>?;
    final text = candidates?.isNotEmpty == true
        ? (((candidates!.first as Map<String, dynamic>)['content'] as Map<String, dynamic>)['parts'] as List<dynamic>).first['text'] as String
        : null;
    if (text == null || text.isEmpty) throw Exception('Gemini returned no analysis.');

    final clean = text.replaceFirst(RegExp(r'^```json\s*'), '').replaceFirst(RegExp(r'\s*```$'), '').trim();
    final data = jsonDecode(clean) as Map<String, dynamic>;
    return DiseaseAnalysis(
      disease: data['disease']?.toString() ?? 'Unable to determine',
      confidence: (data['confidence'] as num?)?.toDouble() ?? 0,
      symptoms: data['symptoms']?.toString() ?? 'No symptoms returned.',
      treatment: data['treatment']?.toString() ?? 'Consult a local agronomist before treatment.',
      prevention: data['prevention']?.toString() ?? 'Maintain good crop hygiene and monitor regularly.',
    );
  }

  String _mimeType(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }
}
