import 'dart:math';
import 'dart:typed_data';
import '../data/agri_knowledge.dart';
import '../models/agri_models.dart';

class CropRecommendationService {
  Future<List<CropRecommendation>> recommend({required double n, required double p, required double k, required double ph, required double temperature, required double humidity, required double rainfall, required String soil, required String season}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    double scoreFor(String crop) {
      var score = 0.68;
      final profile = AgriKnowledge.byName(crop);
      if (profile == null) return score;
      if (profile.seasons.any((s) => s.toLowerCase() == season.toLowerCase())) score += 0.14;
      if (soil.trim().isNotEmpty && profile.soil.any((s) => soil.toLowerCase().contains(s.toLowerCase().split(' ').first))) score += 0.08;
      if (humidity > 75 && (crop == 'Rice' || crop == 'Soybean')) score += 0.04;
      if (rainfall < 450 && (crop == 'Pearl Millet' || crop == 'Groundnut')) score += 0.04;
      if (temperature > 30 && crop == 'Wheat') score -= 0.08;
      if (n < 40 || p < 20 || k < 20) score -= 0.05;
      if (ph < 5.5 || ph > 8.0) score -= 0.06;
      return score.clamp(0.55, 0.96);
    }
    final candidates = [
      CropRecommendation(crop: 'Groundnut', score: scoreFor('Groundnut'), duration: '120–140 days', water: 'Moderate', reason: AgriKnowledge.byName('Groundnut')!.farmerTip),
      CropRecommendation(crop: 'Pearl Millet', score: scoreFor('Pearl Millet'), duration: '75–110 days', water: 'Low–Moderate', reason: AgriKnowledge.byName('Pearl Millet')!.farmerTip),
      CropRecommendation(crop: 'Soybean', score: scoreFor('Soybean'), duration: '95–120 days', water: 'Moderate', reason: AgriKnowledge.byName('Soybean')!.farmerTip),
      CropRecommendation(crop: 'Cotton', score: scoreFor('Cotton'), duration: '150–180 days', water: 'Moderate', reason: AgriKnowledge.byName('Cotton')!.farmerTip),
      CropRecommendation(crop: 'Rice', score: scoreFor('Rice'), duration: '110–150 days', water: 'High', reason: AgriKnowledge.byName('Rice')!.farmerTip),
    ];
    candidates.sort((a, b) => b.score.compareTo(a.score));
    return candidates.take(3).toList();
  }
}

class DiseaseDetectionService {
  Future<DiseaseResult> detect(Uint8List? imageBytes) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (imageBytes == null || imageBytes.isEmpty) {
      return const DiseaseResult(name: 'Image quality check needed', confidence: 0.0, severity: 'Unknown', cause: 'No usable image was supplied.', action: 'Capture a well-lit close-up of the affected leaf or plant part.');
    }
    return const DiseaseResult(name: 'Field image ready for model analysis', confidence: 0.0, severity: 'Pending', cause: 'The production model should classify the image using the trained on-device model.', action: 'Run the trained TensorFlow Lite model before presenting a diagnosis.');
  }
}

class YieldPredictionService {
  Future<YieldResult> predict({required String crop, required double area, required double moisture, required double fertilizer, required double historicalYield}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final moistureFactor = moisture.clamp(20, 65) / 1000;
    final nutrientFactor = fertilizer.clamp(0, 100) / 2500;
    final estimate = max(0.5, historicalYield * (0.93 + moistureFactor + nutrientFactor));
    final riskAdjustment = (moisture < 25 || moisture > 65) ? 0.12 : 0.07;
    return YieldResult(estimated: estimate, min: estimate * (1 - riskAdjustment), max: estimate * (1 + riskAdjustment), confidence: 0.72);
  }
}

class AgriBotService {
  Future<String> ask(String prompt, {String language = 'English'}) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final query = prompt.trim().toLowerCase();
    if (query.contains('soil') || query.contains('fertilizer') || query.contains('npk')) return '${AgriKnowledge.sourceNote} Soil Health Card guidance covers N, P, K, S, Zn, Fe, Cu, Mn, B, pH, EC and organic carbon. Start with a current soil test before changing fertilizer quantity.';
    if (query.contains('yellow') || query.contains('leaf')) return 'Yellowing is a symptom, not a diagnosis. Check leaf age, underside pest activity, soil moisture, drainage and recent fertilizer use before changing inputs.';
    if (query.contains('crop')) return 'For a crop choice, combine soil test, season, water availability, local weather and market access. AgriSmart currently covers ${AgriKnowledge.crops.take(4).map((c) => c.name).join(', ')} in its curated knowledge layer.';
    if (query.contains('rain') || query.contains('weather')) return 'Use the IMD KALP agro-advisory for location + crop-stage specific actions. Rain forecast can change irrigation, spraying, fertilizer timing and harvest planning.';
    if (query.contains('scheme') || query.contains('pm kisan')) return 'For PM-KISAN, use the official portal to check current eligibility, exclusions, payment status and mandatory eKYC.';
    if (language != 'English') return 'I can respond in $language. Share your crop, location, soil condition and the exact problem.';
    return 'Tell me the crop, village/district, crop stage, recent rain/irrigation and soil-test result if available. I will turn that into a short action checklist.';
  }
}

class WeatherService {
  Future<Map<String, dynamic>> getCurrent() async => const {'temperature': '—', 'humidity': '—', 'rainProbability': '—', 'wind': '—', 'uv': '—', 'condition': 'Live feed required', 'source': 'IMD KALP agro-advisory', 'isLive': false};
}

class MarketService {
  Future<List<Map<String, dynamic>>> getPrices() async => const [];
}

class DecisionEngineService {
  Future<List<Insight>> buildInsights({required Farm farm, required Map<String, dynamic> weather}) async {
    final rainKnown = weather['rainProbability'] is num;
    final humidityKnown = weather['humidity'] is num;
    return [
      Insight(title: 'Soil-first decision', message: '${AgriKnowledge.sourceNote} Use the latest soil test before making a fertilizer change.', level: 'Action', icon: 0xe8b6),
      Insight(title: 'Irrigation', message: farm.moisture < 35 ? 'Moisture is below the app target. Check the root zone and local rain advisory before irrigating.' : 'Moisture is within the app target band; verify root-zone condition before watering.', level: farm.moisture < 35 ? 'Review' : 'Good', icon: 0xe798),
      Insight(title: 'Weather connection', message: rainKnown ? 'Live weather values are available.' : 'Connect the IMD/location feed to unlock weather-triggered recommendations.', level: rainKnown ? 'Live' : 'Data needed', icon: 0xe3b8),
      Insight(title: 'Disease scouting', message: humidityKnown ? 'Use humidity plus crop stage to prioritize scouting.' : 'Add live humidity and crop-stage data to calculate disease-risk alerts.', level: 'Monitor', icon: 0xe80c),
    ];
  }
}
