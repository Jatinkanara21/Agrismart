import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/weather.dart';
import '../../providers/dashboard_provider.dart';
import '../../services/mock_api_service.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardProvider(MockApiService())..load(),
      child: const _WeatherView(),
    );
  }
}

class _WeatherView extends StatelessWidget {
  const _WeatherView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Weather & insights', style: TextStyle(fontWeight: FontWeight.w800))),
      body: RefreshIndicator(
        onRefresh: provider.load,
        color: AppColors.primary,
        child: provider.loading && provider.weather == null
            ? const Center(child: CircularProgressIndicator())
            : provider.weather == null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 200),
                      Center(child: Text('Weather data unavailable. Pull to retry.')),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      _CurrentCard(data: provider.weather!),
                      const SizedBox(height: 18),
                      const Text('Smart recommendations', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                      const SizedBox(height: 10),
                      _Recommendation(icon: Icons.water_drop_outlined, title: 'Reduce irrigation tomorrow', body: 'Rain probability is above 60% for part of the day.', color: AppColors.info),
                      _Recommendation(icon: Icons.spa_outlined, title: 'Ideal fertilizer window', body: 'Morning conditions are calm enough for foliar application.', color: AppColors.primary),
                      _Recommendation(icon: Icons.warning_amber_rounded, title: 'Watch humidity', body: 'Higher humidity can increase fungal pressure on tomatoes.', color: AppColors.warning),
                      const SizedBox(height: 18),
                      const Text('7-day forecast', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                      const SizedBox(height: 10),
                      ...provider.weather!.forecast.map((day) => _ForecastTile(day: day)),
                    ],
                  ),
      ),
    );
  }
}

class _CurrentCard extends StatelessWidget {
  final WeatherSnapshot data;
  const _CurrentCard({required this.data});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.location, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.wb_sunny_rounded, color: AppColors.accent, size: 38),
                const SizedBox(width: 12),
                Text('${data.temperature}°C', style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w800)),
                const Spacer(),
                Text(data.condition, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Metric('Humidity', '${data.humidity}%'),
                _Metric('Rain', '${data.rainChance}%'),
                _Metric('Wind', data.wind),
                _Metric('UV', '6'),
              ],
            ),
          ],
        ),
      );
}

class _Metric extends StatelessWidget {
  final String label, value;
  const _Metric(this.label, this.value);
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      );
}

class _Recommendation extends StatelessWidget {
  final IconData icon;
  final String title, body;
  final Color color;
  const _Recommendation({required this.icon, required this.title, required this.body, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: .4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(body, style: const TextStyle(color: AppColors.textSecondary, height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _ForecastTile extends StatelessWidget {
  final WeatherDay day;
  const _ForecastTile({required this.day});
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: const Icon(Icons.cloud_outlined, color: AppColors.info),
          title: Text('${_weekday(day.date.weekday)} • ${day.condition}', style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('Rain ${day.rainChance}% • Humidity ${day.humidity}% • UV ${day.uvIndex}'),
          trailing: Text('${day.temperature}° / ${day.low}°', style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
      );

  String _weekday(int n) => const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][n - 1];
}
