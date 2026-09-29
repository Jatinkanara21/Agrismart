import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';

class CropRecommendationPage extends StatefulWidget {
  const CropRecommendationPage({super.key});

  @override
  State<CropRecommendationPage> createState() => _CropRecommendationPageState();
}

class _CropRecommendationPageState extends State<CropRecommendationPage> {
  final fields = <String, TextEditingController>{
    'nitrogen': TextEditingController(text: '90'),
    'phosphorus': TextEditingController(text: '42'),
    'potassium': TextEditingController(text: '43'),
    'temperature': TextEditingController(text: '25'),
    'humidity': TextEditingController(text: '70'),
    'ph': TextEditingController(text: '6.5'),
    'rainfall': TextEditingController(text: '200'),
  };
  bool loading = false;
  String? error;
  Map<String, dynamic>? result;

  Future<void> predict() async {
    final body = <String, dynamic>{};
    for (final entry in fields.entries) {
      final value = double.tryParse(entry.value.text);
      if (value == null) {
        setState(() => error = 'Enter valid numeric values for every field.');
        return;
      }
      body[entry.key] = value;
    }
    setState(() {
      loading = true;
      error = null;
      result = null;
    });
    try {
      final response = await ApiClient().post('/crops/recommend', body);
      setState(() => result = response['data'] as Map<String, dynamic>?);
    } catch (e) {
      setState(() => error = apiMessage(e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => ToolScaffold(
        title: 'Crop Recommendation',
        subtitle: 'Enter soil and climate measurements for a real model prediction.',
        child: Column(
          children: [
            NumericForm(fields: fields),
            const SizedBox(height: 12),
            ActionButton(label: 'Recommend crop', loading: loading, onPressed: predict),
            if (error != null) ...[
              const SizedBox(height: 12),
              ErrorBox(message: error!),
            ],
            if (result != null) ...[
              const SizedBox(height: 12),
              ResultCard(
                title: result!['recommendation'].toString(),
                subtitle: 'Model confidence: ' + result!['confidence'].toString() + '%',
                icon: Icons.grass,
                extra: 'Alternatives: ' +
                    (result!['alternatives'] as List).map((item) {
                      final map = item as Map;
                      return map['crop'].toString() + ' (' + map['confidence'].toString() + '%)';
                    }).join(' • '),
              ),
              const SizedBox(height: 8),
              const Text(
                'Decision support only. Validate soil results and local agronomy guidance before planting.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
      );
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final location = TextEditingController(text: 'Ahmedabad');
  bool loading = false;
  String? error;
  Map<String, dynamic>? data;

  Future<void> loadWeather() async {
    if (location.text.trim().length < 2) {
      setState(() => error = 'Enter a city or location.');
      return;
    }
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await ApiClient().get(
        '/weather?location=' + Uri.encodeQueryComponent(location.text.trim()),
      );
      setState(() => data = response['data'] as Map<String, dynamic>?);
    } catch (e) {
      setState(() => error = apiMessage(e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => ToolScaffold(
        title: 'Weather',
        subtitle: 'Live current conditions and a five-day forecast from Open-Meteo.',
        child: Column(
          children: [
            TextField(
              controller: location,
              onSubmitted: (_) => loadWeather(),
              decoration: const InputDecoration(
                labelText: 'City or location',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 12),
            ActionButton(label: 'Load weather', loading: loading, onPressed: loadWeather),
            if (error != null) ...[
              const SizedBox(height: 12),
              ErrorBox(message: error!),
            ],
            if (data != null) ...[
              const SizedBox(height: 12),
              WeatherResult(data: data!),
            ],
          ],
        ),
      );
}

class WeatherResult extends StatelessWidget {
  const WeatherResult({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final current = (data['current'] as Map?)?.cast<String, dynamic>() ?? {};
    final daily = (data['daily'] as Map?)?.cast<String, dynamic>() ?? {};
    final times = List<String>.from(daily['time'] ?? const []);
    final max = List<dynamic>.from(daily['temperature_2m_max'] ?? const []);
    final min = List<dynamic>.from(daily['temperature_2m_min'] ?? const []);
    final rain = List<dynamic>.from(daily['precipitation_sum'] ?? const []);

    return Column(
      children: [
        ResultCard(
          title: data['location'].toString(),
          subtitle: (current['temperature_2m'] ?? '--').toString() +
              ' °C • humidity ' +
              (current['relative_humidity_2m'] ?? '--').toString() +
              '%',
          icon: Icons.cloud,
          extra: 'Feels like ' +
              (current['apparent_temperature'] ?? '--').toString() +
              ' °C • rain ' +
              (current['precipitation'] ?? '--').toString() +
              ' mm • wind ' +
              (current['wind_speed_10m'] ?? '--').toString() +
              ' km/h',
        ),
        const SizedBox(height: 10),
        ...List.generate(
          times.length,
          (index) => Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(times[index]),
              subtitle: Text(
                'Min ' + itemAt(min, index) +
                    ' °C • Max ' + itemAt(max, index) +
                    ' °C • Rain ' + itemAt(rain, index) + ' mm',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DiseaseDetectionPage extends StatefulWidget {
  const DiseaseDetectionPage({super.key});

  @override
  State<DiseaseDetectionPage> createState() => _DiseaseDetectionPageState();
}

class _DiseaseDetectionPageState extends State<DiseaseDetectionPage> {
  final picker = ImagePicker();
  XFile? image;
  bool loading = false;
  String? error;
  Map<String, dynamic>? result;

  Future<void> choose(ImageSource source) async {
    final selected = await picker.pickImage(source: source, imageQuality: 90);
    if (selected != null) {
      setState(() {
        image = selected;
        error = null;
        result = null;
      });
    }
  }

  Future<void> detect() async {
    if (image == null) {
      setState(() => error = 'Choose a leaf image first.');
      return;
    }
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final bytes = await image!.readAsBytes();
      final response = await ApiClient().postMultipart(
        '/disease/detect',
        'image',
        bytes,
        image!.name,
      );
      setState(() => result = response['data'] as Map<String, dynamic>?);
    } catch (e) {
      setState(() => error = apiMessage(e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => ToolScaffold(
        title: 'Disease Detection',
        subtitle: 'Upload a leaf image. A diagnosis is returned only when a real vision provider is configured.',
        child: Column(
          children: [
            if (image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: FutureBuilder<Uint8List>(
                  future: image!.readAsBytes(),
                  builder: (_, snapshot) => snapshot.hasData
                      ? Image.memory(
                          snapshot.data!,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : const SizedBox(height: 220),
                ),
              )
            else
              const EmptyState(
                icon: Icons.image_outlined,
                title: 'No image selected',
                message: 'Use camera or gallery to select a clear leaf photo.',
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => choose(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => choose(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ActionButton(label: 'Detect disease', loading: loading, onPressed: detect),
            if (error != null) ...[
              const SizedBox(height: 12),
              ErrorBox(message: error!),
            ],
            if (result != null) ...[
              const SizedBox(height: 12),
              ResultCard(
                title: 'Top prediction',
                subtitle: result!['predictions'].toString(),
                icon: Icons.health_and_safety_outlined,
                extra: 'Model: ' + result!['model'].toString(),
              ),
            ],
          ],
        ),
      );
}

class YieldPredictionPage extends StatelessWidget {
  const YieldPredictionPage({super.key});

  @override
  Widget build(BuildContext context) => const ToolScaffold(
        title: 'Yield Prediction',
        subtitle: 'No estimate is displayed until a validated yield dataset and trained model are deployed.',
        child: EmptyState(
          icon: Icons.analytics_outlined,
          title: 'Model not configured',
          message: 'AgriSmart will not invent a yield number. A validated dataset and trained model are required.',
        ),
      );
}

class AgriBotPage extends StatefulWidget {
  const AgriBotPage({super.key});

  @override
  State<AgriBotPage> createState() => _AgriBotPageState();
}

class _AgriBotPageState extends State<AgriBotPage> {
  final controller = TextEditingController();
  bool loading = false;
  final messages = <String>[];

  Future<void> send() async {
    final text = controller.text.trim();
    if (text.isEmpty || loading) return;
    setState(() {
      messages.add('You: ' + text);
      controller.clear();
      loading = true;
    });
    try {
      final response = await ApiClient().post('/agribot/chat', {'message': text});
      final data = response['data'] as Map<String, dynamic>;
      setState(() => messages.add('AgriBot: ' + data['answer'].toString()));
    } catch (e) {
      setState(() => messages.add('AgriBot unavailable: ' + apiMessage(e)));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => ToolScaffold(
        title: 'AgriBot',
        subtitle: 'AI agricultural assistant. No fake fallback answers are generated.',
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: messages.isEmpty
                  ? const EmptyState(
                      icon: Icons.smart_toy_outlined,
                      title: 'Ask AgriBot',
                      message: 'Try a question about soil, irrigation, crops, or farming practices.',
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: messages.map((m) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text(m),
                          )).toList(),
                    ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Ask a farming question',
                suffixIcon: IconButton(
                  onPressed: loading ? null : send,
                  icon: const Icon(Icons.send),
                ),
              ),
              onSubmitted: (_) => send(),
            ),
          ],
        ),
      );
}

class FarmDecisionPage extends StatefulWidget {
  const FarmDecisionPage({super.key});

  @override
  State<FarmDecisionPage> createState() => _FarmDecisionPageState();
}

class _FarmDecisionPageState extends State<FarmDecisionPage> {
  final location = TextEditingController(text: 'Ahmedabad');
  final fields = <String, TextEditingController>{
    'nitrogen': TextEditingController(text: '90'),
    'phosphorus': TextEditingController(text: '42'),
    'potassium': TextEditingController(text: '43'),
    'temperature': TextEditingController(text: '25'),
    'humidity': TextEditingController(text: '70'),
    'ph': TextEditingController(text: '6.5'),
    'rainfall': TextEditingController(text: '200'),
  };
  bool loading = false;
  String? error;
  Map<String, dynamic>? result;

  Future<void> decide() async {
    final body = <String, dynamic>{'location': location.text.trim()};
    for (final entry in fields.entries) {
      final value = double.tryParse(entry.value.text);
      if (value == null) {
        setState(() => error = 'Enter valid numeric values for every field.');
        return;
      }
      body[entry.key] = value;
    }
    setState(() {
      loading = true;
      error = null;
      result = null;
    });
    try {
      final response = await ApiClient().post('/farming/decision', body);
      setState(() => result = response['data'] as Map<String, dynamic>?);
    } catch (e) {
      setState(() => error = apiMessage(e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => ToolScaffold(
        title: 'Farm Decisions',
        subtitle: 'Combines the crop model with transparent decision-support actions.',
        child: Column(
          children: [
            TextField(
              controller: location,
              decoration: const InputDecoration(
                labelText: 'Farm location',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 12),
            NumericForm(fields: fields),
            const SizedBox(height: 12),
            ActionButton(label: 'Generate decision support', loading: loading, onPressed: decide),
            if (error != null) ...[
              const SizedBox(height: 12),
              ErrorBox(message: error!),
            ],
            if (result != null) ...[
              const SizedBox(height: 12),
              ResultCard(
                title: result!['recommended_crop'].toString(),
                subtitle: 'Model confidence: ' + result!['confidence'].toString() + '%',
                icon: Icons.agriculture,
                extra: 'Alternatives: ' + result!['alternatives'].toString(),
              ),
              const SizedBox(height: 8),
              ...(result!['actions'] as List).map(
                (item) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(item.toString()),
                ),
              ),
            ],
          ],
        ),
      );
}

class NumericForm extends StatelessWidget {
  const NumericForm({super.key, required this.fields});

  final Map<String, TextEditingController> fields;

  @override
  Widget build(BuildContext context) => Column(
        children: fields.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TextField(
              controller: entry.value,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: fieldLabel(entry.key)),
            ),
          );
        }).toList(),
      );
}

class ToolScaffold extends StatelessWidget {
  const ToolScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 18),
            child,
          ],
        ),
      );
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: loading ? null : onPressed,
          child: loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(label),
        ),
      );
}

class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.extra,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String extra;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(subtitle),
                    const SizedBox(height: 8),
                    Text(extra),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          children: [
            Icon(icon, size: 54, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      );

String apiMessage(Object error) {
  if (error is ApiException) {
    if (error.statusCode == 503) {
      return 'Service not configured: ' + error.message;
    }
    return error.message;
  }
  return 'Request failed. Check the API connection.';
}

String fieldLabel(String key) {
  const labels = {
    'nitrogen': 'Nitrogen (N)',
    'phosphorus': 'Phosphorus (P)',
    'potassium': 'Potassium (K)',
    'temperature': 'Temperature (°C)',
    'humidity': 'Humidity (%)',
    'ph': 'Soil pH',
    'rainfall': 'Rainfall (mm)',
  };
  return labels[key] ?? key;
}

String itemAt(List<dynamic> values, int index) {
  if (index < 0 || index >= values.length) return '--';
  return values[index].toString();
}
