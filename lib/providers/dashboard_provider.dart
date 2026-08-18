import 'package:flutter/foundation.dart';
import '../models/farm.dart';
import '../models/market_price.dart';
import '../models/weather.dart';
import '../services/mock_api_service.dart';

class DashboardProvider extends ChangeNotifier {
  final MockApiService _service;
  DashboardProvider(this._service);

  WeatherSnapshot? weather;
  List<MarketCropPrice> markets = const [];
  List<Farm> farms = const [];
  bool loading = false;
  String? error;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.fetchWeather(),
        _service.fetchMarketPrices(),
        _service.fetchFarms(),
      ]);
      weather = results[0] as WeatherSnapshot;
      markets = results[1] as List<MarketCropPrice>;
      farms = results[2] as List<Farm>;
    } catch (_) {
      error = 'Some dashboard data could not be loaded.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
