class WeatherDay {
  final DateTime date;
  final String condition;
  final int temperature;
  final int low;
  final int rainChance;
  final int humidity;
  final int uvIndex;
  final String wind;

  const WeatherDay({
    required this.date,
    required this.condition,
    required this.temperature,
    required this.low,
    required this.rainChance,
    required this.humidity,
    required this.uvIndex,
    required this.wind,
  });
}

class WeatherSnapshot {
  final String location;
  final String condition;
  final int temperature;
  final int humidity;
  final int rainChance;
  final String wind;
  final List<WeatherDay> forecast;

  const WeatherSnapshot({
    required this.location,
    required this.condition,
    required this.temperature,
    required this.humidity,
    required this.rainChance,
    required this.wind,
    required this.forecast,
  });
}
