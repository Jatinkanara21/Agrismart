import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_litert/flutter_litert.dart';
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

/// Offline plant-disease classifier.
///
/// The bundled model is a MobileNetV2 classifier trained on PlantVillage.
/// No network request or API key is used during inference.
class LocalDiseaseService {
  static const _modelAsset = 'assets/models/plant_disease.tflite';
  static const _inputSize = 224;

  static const labels = <String>[
    'Apple — Apple scab',
    'Apple — Black rot',
    'Apple — Cedar apple rust',
    'Apple — Healthy',
    'Blueberry — Healthy',
    'Cherry — Powdery mildew',
    'Cherry — Healthy',
    'Corn — Cercospora leaf spot',
    'Corn — Common rust',
    'Corn — Northern leaf blight',
    'Corn — Healthy',
    'Grape — Black rot',
    'Grape — Esca (Black Measles)',
    'Grape — Leaf blight',
    'Grape — Healthy',
    'Orange — Citrus greening',
    'Peach — Bacterial spot',
    'Peach — Healthy',
    'Pepper — Bacterial spot',
    'Pepper — Healthy',
    'Potato — Early blight',
    'Potato — Late blight',
    'Potato — Healthy',
    'Raspberry — Healthy',
    'Soybean — Healthy',
    'Squash — Powdery mildew',
    'Strawberry — Leaf scorch',
    'Strawberry — Healthy',
    'Tomato — Bacterial spot',
    'Tomato — Early blight',
    'Tomato — Late blight',
    'Tomato — Leaf mold',
    'Tomato — Septoria leaf spot',
    'Tomato — Spider mites',
    'Tomato — Target spot',
    'Tomato — Yellow leaf curl virus',
    'Tomato — Mosaic virus',
    'Tomato — Healthy',
  ];

  Interpreter? _interpreter;
  bool _loading = false;

  bool get isModelAvailable => _interpreter != null;

  Future<void> initialize() async {
    if (_interpreter != null || _loading) return;
    _loading = true;
    try {
      await initializeWeb();
      _interpreter = await Interpreter.fromAsset(_modelAsset);
    } finally {
      _loading = false;
    }
  }

  Future<DiseaseAnalysis> analyze(XFile image) async {
    await initialize();
    final interpreter = _interpreter;
    if (interpreter == null) {
      throw StateError(
        'The offline AI model is not installed. Add assets/models/plant_disease.tflite. '
        'See ml/README.md for training instructions.',
      );
    }

    final bytes = await image.readAsBytes();
    final input = await _preprocess(bytes);
    final output = List.generate(1, (_) => List<double>.filled(labels.length, 0));
    interpreter.run(input, output);

    final scores = output.first;
    var bestIndex = 0;
    for (var i = 1; i < scores.length; i++) {
      if (scores[i] > scores[bestIndex]) bestIndex = i;
    }

    final confidence = (scores[bestIndex] * 100).clamp(0, 100).toDouble();
    final label = labels[bestIndex];
    final info = _info(label);

    return DiseaseAnalysis(
      disease: label,
      confidence: confidence,
      symptoms: info.$1,
      treatment: info.$2,
      prevention: info.$3,
    );
  }

  Future<List<List<List<List<double>>>>> _preprocess(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: _inputSize,
      targetHeight: _inputSize,
    );
    final frame = await codec.getNextFrame();
    final rgba = await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (rgba == null) throw StateError('Could not decode the plant image.');

    final data = rgba.buffer.asUint8List();
    final input = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (x) {
            final i = (y * _inputSize + x) * 4;
            return <double>[
              (data[i] / 127.5) - 1.0,
              (data[i + 1] / 127.5) - 1.0,
              (data[i + 2] / 127.5) - 1.0,
            ];
          },
        ),
      ),
    );
    return input;
  }

  (String, String, String) _info(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('healthy')) {
      return (
        'No obvious disease pattern was detected in the leaf.',
        'Continue normal crop care and monitor new growth.',
        'Maintain balanced irrigation, nutrition, airflow, and routine scouting.',
      );
    }
    if (lower.contains('early blight')) {
      return (
        'Dark circular lesions, often with concentric rings and yellowing around affected tissue.',
        'Remove severely infected leaves, improve airflow, and use a locally approved fungicide when recommended.',
        'Avoid overhead irrigation, rotate crops, and remove infected plant debris.',
      );
    }
    if (lower.contains('late blight')) {
      return (
        'Water-soaked or dark lesions that can expand quickly under cool, humid conditions.',
        'Remove affected material and seek local agronomy guidance for an approved fungicide program.',
        'Reduce leaf wetness, improve airflow, and avoid planting infected material.',
      );
    }
    if (lower.contains('rust')) {
      return (
        'Rust-colored or orange-brown powdery lesions on leaf surfaces.',
        'Remove heavily affected foliage and follow a locally approved disease-control program.',
        'Improve airflow and avoid prolonged leaf wetness.',
      );
    }
    if (lower.contains('powdery mildew')) {
      return (
        'White powder-like fungal growth on leaf surfaces with possible curling or yellowing.',
        'Remove heavily affected leaves and follow locally approved mildew treatment guidance.',
        'Improve spacing and airflow and avoid excessive nitrogen.',
      );
    }
    return (
      'The model detected a disease pattern associated with this class.',
      'Confirm the diagnosis with a local agronomist before applying chemicals or changing treatment.',
      'Scout nearby plants and maintain good sanitation, airflow, irrigation, and crop hygiene.',
    );
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
