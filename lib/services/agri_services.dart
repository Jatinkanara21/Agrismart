import 'dart:math';
import 'dart:typed_data';
import '../models/agri_models.dart';

class CropRecommendationService {
  Future<List<CropRecommendation>> recommend({required double n, required double p, required double k, required double ph, required double temperature, required double humidity, required double rainfall, required String soil, required String season}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final riceFit = (rainfall > 140 && soil.toLowerCase().contains('loam')) ? 0.94 : 0.86;
    return [
      CropRecommendation(crop: 'Rice', score: riceFit, duration: '120–150 days', water: 'High', reason: 'Strong match for rainfall, humidity and your soil profile.'),
      CropRecommendation(crop: 'Maize', score: 0.88, duration: '90–110 days', water: 'Medium', reason: 'Balanced nutrient demand and good seasonal flexibility.'),
      CropRecommendation(crop: 'Cotton', score: 0.81, duration: '160–180 days', water: 'Medium', reason: 'Suitable when drainage is good and rainfall is moderate.'),
    ];
  }
}

class DiseaseDetectionService {
  Future<DiseaseResult> detect(Uint8List? imageBytes) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return const DiseaseResult(name: 'Tomato Late Blight', confidence: 0.96, severity: 'Moderate', cause: 'Cool, wet conditions can favor fungal spread.', action: 'Remove badly affected leaves, improve airflow and verify treatment with a local agronomist.');
  }
}

class YieldPredictionService {
  Future<YieldResult> predict({required String crop, required double area, required double moisture, required double fertilizer, required double historicalYield}) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    final estimate = max(1.5, historicalYield * (0.92 + moisture / 1000 + fertilizer / 2500));
    return YieldResult(estimated: estimate, min: estimate * .86, max: estimate * 1.12, confidence: .89);
  }
}

class AgriBotService {
  Future<String> ask(String prompt, {String language = 'English'}) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final p = prompt.toLowerCase();
    if (p.contains('yellow') || p.contains('leaf')) return 'Yellow leaves can come from nutrient deficiency, water stress, pests or disease. Check the underside of leaves, soil moisture and recent fertilizer use. Avoid adding fertilizer blindly; confirm the cause first.';
    if (p.contains('rain')) return 'Rain is likely to affect irrigation and spray timing. Avoid irrigation when useful rainfall is expected and delay foliar applications until leaves can dry.';
    if (p.contains('crop')) return 'For a crop decision, combine soil NPK and pH with local season, rainfall, water availability and market conditions. AgriSmart can score several crops side by side.';
    if (language != 'English') return 'I can answer in $language. Please share the crop, field condition and the problem you are seeing.';
    return 'Tell me your crop, field location, soil condition and the problem you are seeing. I will give you practical checks, a recommended next action and risk notes.';
  }
}

class WeatherService {
  Future<Map<String, dynamic>> getCurrent() async => {'temperature': 29, 'humidity': 78, 'rainProbability': 82, 'wind': 14, 'uv': 6, 'condition': 'Partly cloudy'};
}

class MarketService {
  Future<List<Map<String, dynamic>>> getPrices() async => [
    {'crop': 'Wheat', 'price': 2680, 'trend': '+4.2%', 'market': 'Ahmedabad APMC'},
    {'crop': 'Rice', 'price': 3210, 'trend': '+2.1%', 'market': 'Unjha APMC'},
    {'crop': 'Maize', 'price': 2240, 'trend': '-1.4%', 'market': 'Gondal APMC'},
  ];
}

class DecisionEngineService {
  Future<List<Insight>> buildInsights({required Farm farm, required Map<String, dynamic> weather}) async {
    final rain = weather['rainProbability'] as int;
    return [
      Insight(title: 'Rain alert', message: rain > 70 ? 'Heavy rain is likely. Avoid irrigation today and delay fertilizer application.' : 'Rain risk is low. Continue planned field work.', level: rain > 70 ? 'High' : 'Low', icon: 0xe3b8),
      Insight(title: 'Irrigation', message: farm.moisture < 35 ? 'Soil moisture is low. Irrigation is recommended after checking local weather.' : 'Moisture is in an acceptable range.', level: farm.moisture < 35 ? 'Medium' : 'Good', icon: 0xe798),
      Insight(title: 'Disease risk', message: weather['humidity'] > 75 ? 'High humidity increases fungal disease risk. Inspect crop leaves today.' : 'Disease pressure looks moderate.', level: weather['humidity'] > 75 ? 'Medium' : 'Low', icon: 0xe80c),
      const Insight(title: 'Harvest watch', message: 'Crop is entering the planned harvest window. Check maturity and local market prices before selling.', level: 'Watch', icon: 0xe3f1),
    ];
  }
}
