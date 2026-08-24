class Farm {
  const Farm({required this.name, required this.area, required this.location, required this.crop, required this.soil, required this.moisture});
  final String name, location, crop, soil;
  final double area, moisture;
}

class CropRecommendation {
  const CropRecommendation({required this.crop, required this.score, required this.duration, required this.water, required this.reason});
  final String crop, duration, water, reason;
  final double score;
}

class DiseaseResult {
  const DiseaseResult({required this.name, required this.confidence, required this.severity, required this.action, required this.cause});
  final String name, severity, action, cause;
  final double confidence;
}

class YieldResult {
  const YieldResult({required this.estimated, required this.min, required this.max, required this.confidence});
  final double estimated, min, max, confidence;
}

class Insight {
  const Insight({required this.title, required this.message, required this.level, required this.icon});
  final String title, message, level;
  final int icon;
}

class ChatMessage {
  const ChatMessage({required this.text, required this.isUser, required this.time});
  final String text;
  final bool isUser;
  final DateTime time;
}
