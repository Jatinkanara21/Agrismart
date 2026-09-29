class DemoCrop {
  const DemoCrop(this.name, this.confidence, this.status);

  final String name;
  final int confidence;
  final String status;
}

class DemoDisease {
  const DemoDisease({
    required this.crop,
    required this.disease,
    required this.severity,
    required this.confidence,
    required this.advice,
  });

  final String crop;
  final String disease;
  final String severity;
  final double confidence;
  final String advice;
}

class DemoYield {
  const DemoYield({
    required this.crop,
    required this.soil,
    required this.season,
    required this.rainfall,
    required this.temperature,
    required this.yieldPerHectare,
  });

  final String crop;
  final String soil;
  final String season;
  final int rainfall;
  final double temperature;
  final double yieldPerHectare;
}

class DemoWeather {
  const DemoWeather({
    required this.location,
    required this.temperature,
    required this.humidity,
    required this.rainChance,
    required this.condition,
  });

  final String location;
  final int temperature;
  final int humidity;
  final int rainChance;
  final String condition;
}

const demoWeather = DemoWeather(
  location: 'Ahmedabad',
  temperature: 29,
  humidity: 68,
  rainChance: 22,
  condition: 'Partly cloudy',
);

const demoCrops = <DemoCrop>[
  DemoCrop('Rice', 94, 'Good match'),
  DemoCrop('Maize', 78, 'Alternative'),
  DemoCrop('Cotton', 71, 'Alternative'),
];

const demoDiseases = <DemoDisease>[
  DemoDisease(
    crop: 'Tomato',
    disease: 'Healthy',
    severity: 'Low',
    confidence: 98.2,
    advice: 'Maintain balanced irrigation and inspect leaves weekly.',
  ),
  DemoDisease(
    crop: 'Tomato',
    disease: 'Early Blight',
    severity: 'Medium',
    confidence: 91.4,
    advice: 'Remove affected leaves and improve airflow.',
  ),
  DemoDisease(
    crop: 'Potato',
    disease: 'Late Blight',
    severity: 'High',
    confidence: 94.1,
    advice: 'Isolate affected plants and seek local agronomy guidance.',
  ),
  DemoDisease(
    crop: 'Rice',
    disease: 'Bacterial Leaf Blight',
    severity: 'Medium',
    confidence: 89.7,
    advice: 'Avoid excessive nitrogen and manage field water.',
  ),
];

const demoYields = <DemoYield>[
  DemoYield(
    crop: 'Rice',
    soil: 'Loamy',
    season: 'Kharif',
    rainfall: 1200,
    temperature: 27,
    yieldPerHectare: 4.2,
  ),
  DemoYield(
    crop: 'Wheat',
    soil: 'Loamy',
    season: 'Rabi',
    rainfall: 450,
    temperature: 21,
    yieldPerHectare: 3.1,
  ),
  DemoYield(
    crop: 'Cotton',
    soil: 'Black',
    season: 'Kharif',
    rainfall: 700,
    temperature: 26,
    yieldPerHectare: 2.4,
  ),
  DemoYield(
    crop: 'Maize',
    soil: 'Loamy',
    season: 'Kharif',
    rainfall: 800,
    temperature: 25,
    yieldPerHectare: 3.8,
  ),
];

const demoTips = <String>[
  'Check soil moisture before irrigation.',
  'Scout leaves weekly for early disease signs.',
  'Use soil-test results before fertilizer decisions.',
  'Rotate crop families to support soil health.',
];

const demoBotAnswers = <String, String>{
  'soil': 'For this demo farm, check soil moisture before irrigation and use recent soil-test results before fertilizer decisions.',
  'water': 'Irrigate according to crop stage and soil moisture rather than a fixed schedule.',
  'disease': 'Scout representative field areas weekly and record unusual leaf symptoms early.',
  'crop': 'The bundled demo recommends Rice at 94% confidence, with Maize and Cotton as alternatives.',
};

String demoBotReply(String question) {
  final text = question.toLowerCase();
  for (final entry in demoBotAnswers.entries) {
    if (text.contains(entry.key)) return entry.value;
  }
  return 'Demo AgriBot can help with soil, water, disease, and crop questions. Try asking about irrigation or crop selection.';
}
