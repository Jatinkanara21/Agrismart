import 'package:flutter/foundation.dart';
import '../models/crop.dart';
import '../services/mock_api_service.dart';

class CropProvider extends ChangeNotifier {
  final MockApiService _service;
  CropProvider(this._service);

  List<Crop> _crops = const [];
  bool _loading = false;
  String? _error;

  List<Crop> get crops => _crops;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _crops = await _service.fetchCrops();
    } catch (e) {
      _error = 'Could not load crops. Please try again.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void addCrop(Crop crop) {
    _crops = [crop, ..._crops];
    notifyListeners();
  }

  void deleteCrop(String id) {
    _crops = _crops.where((crop) => crop.id != id).toList();
    notifyListeners();
  }

  void updateCrop(Crop updated) {
    _crops = [for (final crop in _crops) if (crop.id == updated.id) updated else crop];
    notifyListeners();
  }
}
