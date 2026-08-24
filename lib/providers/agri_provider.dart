import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../models/agri_models.dart';
import '../services/agri_services.dart';

class AgriProvider extends ChangeNotifier {
  final CropRecommendationService cropService = CropRecommendationService();
  final DiseaseDetectionService diseaseService = DiseaseDetectionService();
  final YieldPredictionService yieldService = YieldPredictionService();
  final AgriBotService botService = AgriBotService();
  final WeatherService weatherService = WeatherService();
  final MarketService marketService = MarketService();
  final DecisionEngineService decisionService = DecisionEngineService();

  Farm farm = const Farm(name: 'Green Valley Farm', area: 4.8, location: 'Ahmedabad, Gujarat', crop: 'Wheat', soil: 'Loam', moisture: 31);
  Map<String, dynamic> weather = {'temperature': 29, 'humidity': 78, 'rainProbability': 82, 'wind': 14, 'uv': 6, 'condition': 'Partly cloudy'};
  List<Insight> insights = const [];
  List<CropRecommendation> cropRecommendations = const [];
  DiseaseResult? disease;
  YieldResult? yield;
  List<Map<String, dynamic>> marketPrices = const [];
  List<ChatMessage> messages = const [];
  bool busy = false;
  String language = 'English';

  Future<void> refresh() async {
    busy = true; notifyListeners();
    weather = await weatherService.getCurrent();
    insights = await decisionService.buildInsights(farm: farm, weather: weather);
    marketPrices = await marketService.getPrices();
    busy = false; notifyListeners();
  }

  Future<void> recommendCrop() async {
    busy = true; notifyListeners();
    cropRecommendations = await cropService.recommend(n: 82, p: 48, k: 42, ph: 6.7, temperature: 29, humidity: 78, rainfall: 185, soil: farm.soil, season: 'Kharif');
    busy = false; notifyListeners();
  }

  Future<void> scanDisease({required ImageSource source}) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 80);
    Uint8List? bytes;
    if (file != null) bytes = await file.readAsBytes();
    busy = true; notifyListeners();
    disease = await diseaseService.detect(bytes);
    busy = false; notifyListeners();
  }

  Future<void> predictYield() async {
    busy = true; notifyListeners();
    yield = await yieldService.predict(crop: farm.crop, area: farm.area, moisture: farm.moisture, fertilizer: 70, historicalYield: 4.35);
    busy = false; notifyListeners();
  }

  Future<void> askBot(String prompt) async {
    final updated = [...messages, ChatMessage(text: prompt, isUser: true, time: DateTime.now())];
    messages = updated; notifyListeners();
    final answer = await botService.ask(prompt, language: language);
    messages = [...messages, ChatMessage(text: answer, isUser: false, time: DateTime.now())]; notifyListeners();
  }

  void setLanguage(String value) { language = value; notifyListeners(); }
}
