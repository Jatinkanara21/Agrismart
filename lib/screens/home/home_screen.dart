import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/weather.dart';
import '../../providers/crop_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../services/mock_api_service.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';
import '../crops/add_crop_screen.dart';
import '../disease_detection/disease_detection_screen.dart';
import '../farm/farm_screen.dart';
import '../notifications/notifications_screen.dart';
import '../weather/weather_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider(MockApiService())..load()),
        ChangeNotifierProvider(create: (_) => CropProvider(MockApiService())..load()),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    final crops = context.watch<CropProvider>();
    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await Future.wait([dashboard.load(), crops.load()]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              titleSpacing: 20,
              title: Row(children: [
                Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.eco_rounded, color: Colors.white)),
                const SizedBox(width: 12),
                const Text('AgriSmart', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -.4)),
              ]),
              actions: [
                IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())), icon: const Icon(Icons.notifications_none_rounded)),
                const SizedBox(width: 8),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              sliver: SliverList.list(children: [
                Text('Good morning, Jatin 👋', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                Text('Here is your farm intelligence for today.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                _WeatherHero(snapshot: dashboard.weather, loading: dashboard.loading),
                const SizedBox(height: 22),
                const SectionHeader(title: 'Quick actions'),
                const SizedBox(height: 12),
                Wrap(spacing: 10, runSpacing: 10, children: [
                  _QuickAction(icon: Icons.add_circle_outline_rounded, label: 'Add crop', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCropScreen()))),
                  _QuickAction(icon: Icons.document_scanner_outlined, label: 'Disease scan', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiseaseDetectionScreen()))),
                  _QuickAction(icon: Icons.landscape_outlined, label: 'My farms', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmScreen()))),
                  _QuickAction(icon: Icons.wb_sunny_outlined, label: 'Forecast', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherScreen()))),
                ]),
                const SizedBox(height: 22),
                const SectionHeader(title: 'Farm overview'),
                const SizedBox(height: 12),
                GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.18, children: [
                  StatCard(label: 'Active crops', value: crops.crops.length.toString(), icon: Icons.grass_rounded),
                  const StatCard(label: 'Tasks today', value: '5', icon: Icons.task_alt_rounded, color: AppColors.warning),
                  StatCard(label: 'Farms', value: dashboard.farms.length.toString(), icon: Icons.terrain_rounded, color: AppColors.secondary),
                  const StatCard(label: 'Insights', value: '3', icon: Icons.auto_awesome_rounded, color: AppColors.info),
                ]),
                const SizedBox(height: 22),
                _InsightCard(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherScreen()))),
                const SizedBox(height: 22),
                const SectionHeader(title: 'Crops needing attention', actionLabel: 'View all'),
                const SizedBox(height: 10),
                if (crops.loading)
                  const LinearProgressIndicator(minHeight: 3)
                else if (crops.crops.isEmpty)
                  const Text('No crops yet. Add your first crop to start tracking.')
                else
                  ...crops.crops.take(3).map((crop) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                      leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.eco_rounded, color: AppColors.primary)),
                      title: Text(crop.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${(crop.progress * 100).round()}% growth • ${crop.farmName}'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                    ),
                  )),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherHero extends StatelessWidget {
  final WeatherSnapshot? snapshot;
  final bool loading;
  const _WeatherHero({required this.snapshot, required this.loading});

  @override
  Widget build(BuildContext context) {
    final data = snapshot;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [BoxShadow(color: Color(0x332E7D32), blurRadius: 22, offset: Offset(0, 11))],
      ),
      child: loading || data == null
        ? const SizedBox(height: 140, child: Center(child: CircularProgressIndicator(color: Colors.white)))
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Today on the farm', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 3),
              Text(data.location, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
            ]),
            const Icon(Icons.wb_sunny_rounded, color: AppColors.accent, size: 40),
          ]),
          const SizedBox(height: 18),
          Row(children: [
            Text('${data.temperature}°', style: const TextStyle(color: Colors.white, fontSize: 46, fontWeight: FontWeight.w800, height: .9)),
            const SizedBox(width: 14),
            const Text('Clear skies', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _WeatherMetric(icon: Icons.water_drop_outlined, value: '${data.humidity}%', label: 'Humidity'),
            _WeatherMetric(icon: Icons.umbrella_outlined, value: '${data.rainChance}%', label: 'Rain'),
            _WeatherMetric(icon: Icons.air_rounded, value: data.wind, label: 'Wind'),
            _WeatherMetric(icon: Icons.thermostat_outlined, value: '${data.temperature - 7}°', label: 'Low'),
          ]),
        ]),
    );
  }
}

class _WeatherMetric extends StatelessWidget {
  final IconData icon; final String value; final String label;
  const _WeatherMetric({required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, color: Colors.white70, size: 18), const SizedBox(height: 4),
    Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
    Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
  ]);
}

class _QuickAction extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: .45))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: AppColors.primary, size: 20), const SizedBox(width: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.w600))]),
    ),
  );
}

class _InsightCard extends StatelessWidget {
  final VoidCallback onTap;
  const _InsightCard({required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(22),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.beige, borderRadius: BorderRadius.circular(22)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.auto_awesome_rounded, color: Colors.white)),
        const SizedBox(width: 14),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('AI farm insight', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)), SizedBox(height: 3), Text('Light rain is likely tomorrow. Consider reducing irrigation for tomatoes.', style: TextStyle(color: AppColors.textSecondary, height: 1.35))])),
        const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: AppColors.textSecondary),
      ]),
    ),
  );
}
