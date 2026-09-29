class DemoCrop {
  const DemoCrop(this.name, this.confidence, this.status);
  final String name;
  final int confidence;
  final String status;
}

class DemoWeather {
  const DemoWeather({
    required this.location,
    required this.temperature,
    required this.humidity,
    required this.rainChance,
  });
  final String location;
  final int temperature;
  final int humidity;
  final int rainChance;
}

const demoWeather = DemoWeather(
  location: 'Ahmedabad',
  temperature: 29,
  humidity: 68,
  rainChance: 22,
);

const demoCrops = <DemoCrop>[
  DemoCrop('Rice', 94, 'Good match'),
  DemoCrop('Maize', 78, 'Alternative'),
  DemoCrop('Cotton', 71, 'Alternative'),
];

const demoTips = <String>[
  'Check soil moisture before irrigation.',
  'Scout leaves weekly for early disease signs.',
  'Use soil-test results before fertilizer decisions.',
];
