enum CropHealth { excellent, good, attention, critical }

enum CropTaskStatus { todo, inProgress, done }

class Crop {
  final String id;
  final String name;
  final String variety;
  final String farmName;
  final DateTime plantedOn;
  final DateTime expectedHarvest;
  final double progress;
  final CropHealth health;
  final double areaAcres;
  final List<String> notes;

  const Crop({
    required this.id,
    required this.name,
    required this.variety,
    required this.farmName,
    required this.plantedOn,
    required this.expectedHarvest,
    required this.progress,
    required this.health,
    required this.areaAcres,
    this.notes = const [],
  });

  Crop copyWith({
    String? name,
    String? variety,
    String? farmName,
    DateTime? plantedOn,
    DateTime? expectedHarvest,
    double? progress,
    CropHealth? health,
    double? areaAcres,
    List<String>? notes,
  }) => Crop(
    id: id,
    name: name ?? this.name,
    variety: variety ?? this.variety,
    farmName: farmName ?? this.farmName,
    plantedOn: plantedOn ?? this.plantedOn,
    expectedHarvest: expectedHarvest ?? this.expectedHarvest,
    progress: progress ?? this.progress,
    health: health ?? this.health,
    areaAcres: areaAcres ?? this.areaAcres,
    notes: notes ?? this.notes,
  );
}
