import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/demo_data.dart';

class CropRecommendationPage extends StatelessWidget {
  const CropRecommendationPage({super.key});

  @override
  Widget build(BuildContext context) => ToolScaffold(
        title: 'Crop Recommendation',
        subtitle: 'Local demo dataset • no API required',
        child: Column(
          children: [
            const DemoBanner(),
            const SizedBox(height: 12),
            ...demoCrops.map(
              (crop) => ResultCard(
                title: crop.name,
                subtitle: '${crop.confidence}% confidence • ${crop.status}',
                icon: Icons.grass,
                extra: crop.name == 'Rice'
                    ? 'Recommended for the demo soil and climate profile.'
                    : 'Alternative crop in the demo dataset.',
              ),
            ),
            const SizedBox(height: 8),
            const Disclaimer(),
          ],
        ),
      );
}

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) => ToolScaffold(
        title: 'Weather',
        subtitle: 'Bundled demo weather • not live conditions',
        child: Column(
          children: [
            const DemoBanner(),
            const SizedBox(height: 12),
            ResultCard(
              title: demoWeather.location,
              subtitle: '${demoWeather.temperature} °C • ${demoWeather.condition}',
              icon: Icons.cloud,
              extra:
                  'Humidity ${demoWeather.humidity}% • Rain chance ${demoWeather.rainChance}%',
            ),
            const SizedBox(height: 12),
            const Card(
              child: ListTile(
                leading: Icon(Icons.thermostat_outlined),
                title: Text('Field conditions'),
                subtitle: Text('Use local observations before making irrigation decisions.'),
              ),
            ),
            const Disclaimer(),
          ],
        ),
      );
}

class DiseaseDetectionPage extends StatefulWidget {
  const DiseaseDetectionPage({super.key});

  @override
  State<DiseaseDetectionPage> createState() => _DiseaseDetectionPageState();
}

class _DiseaseDetectionPageState extends State<DiseaseDetectionPage> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    final disease = demoDiseases[selected];

    return ToolScaffold(
      title: 'Disease Detection',
      subtitle: 'Local demo cases • no image API required',
      child: Column(
        children: [
          const DemoBanner(),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: selected,
            decoration: const InputDecoration(
              labelText: 'Choose demo case',
              prefixIcon: Icon(Icons.local_florist),
            ),
            items: [
              for (var i = 0; i < demoDiseases.length; i++)
                DropdownMenuItem(
                  value: i,
                  child: Text('${demoDiseases[i].crop} • ${demoDiseases[i].disease}'),
                ),
            ],
            onChanged: (value) => setState(() => selected = value ?? 0),
          ),
          const SizedBox(height: 12),
          ResultCard(
            title: disease.disease,
            subtitle:
                '${disease.crop} • ${disease.confidence.toStringAsFixed(1)}% confidence',
            icon: disease.severity == 'High'
                ? Icons.warning_amber_rounded
                : Icons.health_and_safety_outlined,
            extra: 'Severity: ${disease.severity} • ${disease.advice}',
          ),
          const SizedBox(height: 8),
          const Disclaimer(),
        ],
      ),
    );
  }
}

class YieldPredictionPage extends StatefulWidget {
  const YieldPredictionPage({super.key});

  @override
  State<YieldPredictionPage> createState() => _YieldPredictionPageState();
}

class _YieldPredictionPageState extends State<YieldPredictionPage> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    final item = demoYields[selected];

    return ToolScaffold(
      title: 'Yield Prediction',
      subtitle: 'Bundled sample dataset • illustrative estimate',
      child: Column(
        children: [
          const DemoBanner(),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: selected,
            decoration: const InputDecoration(
              labelText: 'Crop scenario',
              prefixIcon: Icon(Icons.analytics_outlined),
            ),
            items: [
              for (var i = 0; i < demoYields.length; i++)
                DropdownMenuItem(
                  value: i,
                  child: Text(demoYields[i].crop),
                ),
            ],
            onChanged: (value) => setState(() => selected = value ?? 0),
          ),
          const SizedBox(height: 12),
          ResultCard(
            title: '${item.yieldPerHectare.toStringAsFixed(1)} tons/hectare',
            subtitle: '${item.crop} • ${item.season} • ${item.soil} soil',
            icon: Icons.trending_up,
            extra:
                'Rainfall ${item.rainfall} mm • Temperature ${item.temperature.toStringAsFixed(0)} °C',
          ),
          const SizedBox(height: 8),
          const Disclaimer(),
        ],
      ),
    );
  }
}

class AgriBotPage extends StatefulWidget {
  const AgriBotPage({super.key});

  @override
  State<AgriBotPage> createState() => _AgriBotPageState();
}

class _AgriBotPageState extends State<AgriBotPage> {
  final controller = TextEditingController();
  final api = ApiClient();
  final messages = <String>[];
  bool loading = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> send() async {
    final question = controller.text.trim();
    if (question.isEmpty || loading) return;

    setState(() {
      messages.add('You: ' + question);
      loading = true;
      controller.clear();
    });

    try {
      final data = await api.post('/agribot/chat', {'message': question});
      final reply = data['reply']?.toString().trim();
      if (reply == null || reply.isEmpty) {
        throw const ApiException('AgriBot returned an empty response.', 502);
      }
      if (!mounted) return;
      setState(() {
        messages.add('AgriBot AI: ' + reply);
        loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        messages.add(
          'AgriBot: AI service is unavailable (' +
              error.statusCode.toString() +
              '). Demo answer: ' +
              demoBotReply(question),
        );
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        messages.add(
          'AgriBot: AI service could not be reached. Demo answer: ' +
              demoBotReply(question),
        );
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => ToolScaffold(
        title: 'AgriBot',
        subtitle: 'AI farming assistant • secure backend connection',
        child: Column(
          children: [
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: const Row(
                children: [
                  Icon(Icons.smart_toy_outlined, color: AppColors.primary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'AI requests go through the AgriSmart backend. '
                      'The OpenAI API key is never stored in the app.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: messages.isEmpty
                  ? const EmptyState(
                      icon: Icons.smart_toy_outlined,
                      title: 'Ask AgriBot AI',
                      message:
                          'Try: “How should I manage water?” or “What should I check for crop disease?”',
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: messages
                          .map(
                            (message) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Text(message),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              enabled: !loading,
              decoration: InputDecoration(
                labelText: 'Ask a farming question',
                suffixIcon: loading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.send),
              ),
              onSubmitted: (_) => send(),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: loading ? null : send,
              icon: const Icon(Icons.send),
              label: Text(loading ? 'Thinking...' : 'Ask AgriBot'),
            ),
            const Disclaimer(),
          ],
        ),
      );
}

class FarmDecisionPage extends StatelessWidget {
  const FarmDecisionPage({super.key});

  @override
  Widget build(BuildContext context) => ToolScaffold(
        title: 'Farm Decisions',
        subtitle: 'Local demo decision support • transparent sample data',
        child: Column(
          children: [
            const DemoBanner(),
            const SizedBox(height: 12),
            ResultCard(
              title: 'Rice',
              subtitle: '94% demo match • Ahmedabad profile',
              icon: Icons.agriculture,
              extra: 'Use soil moisture, rainfall, and crop-stage observations before acting.',
            ),
            const SizedBox(height: 8),
            const ActionTile(
              icon: Icons.water_drop_outlined,
              title: 'Irrigation',
              text: 'Check soil moisture before watering.',
            ),
            const ActionTile(
              icon: Icons.science_outlined,
              title: 'Soil',
              text: 'Use recent soil-test results before fertilizer decisions.',
            ),
            const ActionTile(
              icon: Icons.search_outlined,
              title: 'Scouting',
              text: 'Inspect representative field areas weekly for disease symptoms.',
            ),
            const Disclaimer(),
          ],
        ),
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

class DemoBanner extends StatelessWidget {
  const DemoBanner({super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.mint,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: const Row(
          children: [
            Icon(Icons.offline_bolt, color: AppColors.primary),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'DEMO MODE • Data is bundled with AgriSmart and works without an API.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
}

class ActionTile extends StatelessWidget {
  const ActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title),
          subtitle: Text(text),
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
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 54, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      );
}

class Disclaimer extends StatelessWidget {
  const Disclaimer({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Demo/decision-support data only. Validate important farming decisions with current field measurements and local agronomy guidance.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        ),
      );
}
