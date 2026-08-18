import '../models/app_notification.dart';
import '../models/crop.dart';
import '../models/farm.dart';
import '../models/market_price.dart';
import '../models/weather.dart';

class MockApiService {
  Future<List<Crop>> fetchCrops() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    final now = DateTime.now();
    return [
      Crop(
        id: 'crop-1', name: 'Tomato', variety: 'Roma', farmName: 'Green Valley Farm',
        plantedOn: now.subtract(const Duration(days: 48)), expectedHarvest: now.add(const Duration(days: 22)),
        progress: .68, health: CropHealth.good, areaAcres: 2.4,
        notes: const ['Flowering stage', 'Morning irrigation preferred'],
      ),
      Crop(
        id: 'crop-2', name: 'Wheat', variety: 'Sharbati', farmName: 'North Field',
        plantedOn: now.subtract(const Duration(days: 74)), expectedHarvest: now.add(const Duration(days: 31)),
        progress: .81, health: CropHealth.excellent, areaAcres: 4.8,
        notes: const ['Monitor grain fill', 'Low weed pressure'],
      ),
      Crop(
        id: 'crop-3', name: 'Cotton', variety: 'Bt Cotton', farmName: 'River Bend Farm',
        plantedOn: now.subtract(const Duration(days: 92)), expectedHarvest: now.add(const Duration(days: 51)),
        progress: .57, health: CropHealth.attention, areaAcres: 6.1,
        notes: const ['Scout for bollworm', 'Check potassium level'],
      ),
      Crop(
        id: 'crop-4', name: 'Onion', variety: 'Red Creole', farmName: 'Green Valley Farm',
        plantedOn: now.subtract(const Duration(days: 36)), expectedHarvest: now.add(const Duration(days: 43)),
        progress: .44, health: CropHealth.good, areaAcres: 1.7,
        notes: const ['Bulbing started'],
      ),
    ];
  }

  Future<WeatherSnapshot> fetchWeather() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final today = DateTime.now();
    final labels = ['Sunny', 'Partly Cloudy', 'Cloudy', 'Light Rain', 'Sunny', 'Sunny', 'Partly Cloudy'];
    return WeatherSnapshot(
      location: 'Ahmedabad, Gujarat', condition: 'Sunny', temperature: 31,
      humidity: 58, rainChance: 18, wind: '13 km/h',
      forecast: List.generate(7, (index) => WeatherDay(
        date: today.add(Duration(days: index)), condition: labels[index], temperature: 31 - (index % 3),
        low: 23 + (index % 2), rainChance: [18, 26, 40, 62, 20, 14, 22][index],
        humidity: 58 + index * 2, uvIndex: 6 - (index % 2), wind: '${10 + index} km/h',
      )),
    );
  }

  Future<List<MarketCropPrice>> fetchMarketPrices() async {
    await Future<void>.delayed(const Duration(milliseconds: 550));
    final today = DateTime.now();
    List<MarketPricePoint> points(List<double> values) => List.generate(values.length,
      (i) => MarketPricePoint(today.subtract(Duration(days: values.length - i - 1)), values[i]));

    return [
      MarketCropPrice(crop: 'Tomato', unit: '₹/kg', currentPrice: 38, changePercent: 7.4,
        trend: points([30, 31, 29, 33, 35, 36, 38])),
      MarketCropPrice(crop: 'Wheat', unit: '₹/kg', currentPrice: 28.5, changePercent: 2.1,
        trend: points([27.2, 27.9, 28.1, 27.7, 28.2, 28.4, 28.5])),
      MarketCropPrice(crop: 'Cotton', unit: '₹/kg', currentPrice: 72, changePercent: -3.2,
        trend: points([76, 75, 74, 74, 73, 72.5, 72])),
      MarketCropPrice(crop: 'Onion', unit: '₹/kg', currentPrice: 31, changePercent: 5.8,
        trend: points([25, 27, 28, 27, 30, 30, 31])),
    ];
  }

  Future<List<Farm>> fetchFarms() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return const [
      Farm(id: 'farm-1', name: 'Green Valley Farm', location: 'Sanand, Ahmedabad', areaAcres: 12.6, soilType: 'Loamy', soilMoisture: 64, ph: 6.8),
      Farm(id: 'farm-2', name: 'North Field', location: 'Dholka, Gujarat', areaAcres: 8.2, soilType: 'Sandy loam', soilMoisture: 49, ph: 7.1),
      Farm(id: 'farm-3', name: 'River Bend Farm', location: 'Bavla, Gujarat', areaAcres: 15.4, soilType: 'Clay loam', soilMoisture: 58, ph: 6.5),
    ];
  }

  Future<List<AppNotification>> fetchNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return [
      AppNotification(id: 'n1', title: 'Rain expected tomorrow', message: 'Consider delaying irrigation for the tomato field.', createdAt: now.subtract(const Duration(minutes: 22)), type: NotificationType.weather),
      AppNotification(id: 'n2', title: 'Tomato health check', message: 'Leaf moisture suggests early morning irrigation.', createdAt: now.subtract(const Duration(hours: 2)), type: NotificationType.crop),
      AppNotification(id: 'n3', title: 'Cotton price softened', message: 'Market price moved down 3.2% this week.', createdAt: now.subtract(const Duration(hours: 5)), type: NotificationType.market),
      AppNotification(id: 'n4', title: 'Weekly farm summary', message: '4 tasks completed and 2 insights generated.', createdAt: now.subtract(const Duration(days: 1)), type: NotificationType.system, isRead: true),
    ];
  }
}
