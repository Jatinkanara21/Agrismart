import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/agri_provider.dart';
import '../../widgets/agri_widgets.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});
  @override State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int index = 0;
  @override void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AgriProvider>().refresh());
  }
  void openFeature(String title) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => FeaturePage(title: title)));
  @override Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: index, children: [
      HomePage(onFeature: openFeature), FarmPage(onOpen: openFeature), AiHub(onOpen: openFeature), const MarketPage(), const ProfilePage(),
    ]),
    bottomNavigationBar: NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (value) => setState(() => index = value),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.agriculture_outlined), label: 'My Farm'),
        NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), label: 'AI'),
        NavigationDestination(icon: Icon(Icons.show_chart_outlined), label: 'Market'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    ),
    floatingActionButton: index == 0 ? FloatingActionButton.extended(
      onPressed: () => openFeature('AgriBot'), backgroundColor: AppTheme.forest, foregroundColor: Colors.white,
      icon: const Icon(Icons.smart_toy), label: const Text('AgriBot'),
    ) : null,
  );
}

class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.title, required this.subtitle});
  final String title, subtitle;
  @override Widget build(BuildContext context) => Row(children: [
    CircleAvatar(backgroundColor: AppTheme.green.withValues(alpha: .12), child: const Icon(Icons.eco, color: AppTheme.green)),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
      Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
    ])),
    IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
  ]);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onFeature});
  final void Function(String) onFeature;
  @override Widget build(BuildContext context) {
    final p = context.watch<AgriProvider>();
    return SafeArea(child: RefreshIndicator(onRefresh: p.refresh, child: ListView(padding: const EdgeInsets.fromLTRB(18,18,18,100), children: [
      const TopBar(title: 'Good morning, Jatin', subtitle: 'Green Valley Farm • Ahmedabad'),
      const SizedBox(height: 18),
      AgriCard(child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.forest, AppTheme.green]), borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("TODAY'S FARMING INTELLIGENCE", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8), const Text('Know what to do next.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)),
          const SizedBox(height: 14),
          Text('${p.weather['temperature']}°C • ${p.weather['condition']}', style: const TextStyle(color: Colors.white)),
          Text('${p.weather['rainProbability']}% rain expected', style: const TextStyle(color: Colors.white70)),
        ]),
      )),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: MetricTile(icon: Icons.water_drop_outlined, title: 'Soil Moisture', value: '${p.farm.moisture.round()}%', subtitle: 'Target 40–60%')),
        const SizedBox(width: 12),
        Expanded(child: MetricTile(icon: Icons.eco_outlined, title: 'Soil Health', value: '87/100', subtitle: 'Good condition')),
      ]),
      const SizedBox(height: 18), const Text('Recommended actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 10),
      if (p.insights.isEmpty) const AgriCard(child: Text('Refresh the dashboard to generate today’s actions.'))
      else ...p.insights.take(4).map((i) => Padding(padding: const EdgeInsets.only(bottom: 10), child: AgriCard(child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(backgroundColor: AppTheme.freshGreen.withValues(alpha: .12), child: const Icon(Icons.auto_awesome, color: AppTheme.green)),
        title: Text(i.title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(i.message), trailing: Text(i.level),
      )))),
      const SizedBox(height: 8), const Text('AI tools', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 10),
      GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.25, children: [
        FeatureTile(icon: Icons.spa, title: 'Recommend Crop', subtitle: 'Find your best crop', onTap: () => onFeature('Crop Recommendation')),
        FeatureTile(icon: Icons.camera_alt_outlined, title: 'Detect Disease', subtitle: 'Scan plant health', onTap: () => onFeature('Disease Detection')),
        FeatureTile(icon: Icons.analytics_outlined, title: 'Predict Yield', subtitle: 'Estimate harvest', onTap: () => onFeature('Yield Prediction')),
        FeatureTile(icon: Icons.smart_toy_outlined, title: 'Ask AgriBot', subtitle: 'Get farming advice', onTap: () => onFeature('AgriBot')),
      ]),
      const SizedBox(height: 10), FeatureTile(icon: Icons.water_drop_outlined, title: 'Smart Irrigation', subtitle: 'Moisture + rain aware', onTap: () => onFeature('Smart Irrigation')),
      const SizedBox(height: 10), FeatureTile(icon: Icons.science_outlined, title: 'Fertilizer Plan', subtitle: 'NPK-aware guidance', onTap: () => onFeature('Fertilizer Recommendation')),
    ])));
  }
}

class FarmPage extends StatelessWidget {
  const FarmPage({super.key, required this.onOpen});
  final void Function(String) onOpen;
  @override Widget build(BuildContext context) {
    final f = context.watch<AgriProvider>().farm;
    return SafeArea(child: ListView(padding: const EdgeInsets.all(18), children: [
      const TopBar(title: 'My Farm', subtitle: 'Manage fields, crops and history'), const SizedBox(height: 16),
      AgriCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(f.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 8),
        Text('${f.area} ha • ${f.location}'), Text('${f.soil} soil • ${f.crop}'), const SizedBox(height: 12),
        const LinearProgressIndicator(value: .68), const SizedBox(height: 8), Text('Flowering • Moisture ${f.moisture.round()}%'),
      ])),
      const SizedBox(height: 12), FeatureTile(icon: Icons.add_circle_outline, title: 'Add another farm', subtitle: 'Track multiple fields', onTap: () => onOpen('Add Farm')),
      const SizedBox(height: 10), FeatureTile(icon: Icons.science, title: 'Soil health', subtitle: 'NPK, pH and moisture', onTap: () => onOpen('Soil Health')),
    ]));
  }
}

class AiHub extends StatelessWidget {
  const AiHub({super.key, required this.onOpen});
  final void Function(String) onOpen;
  @override Widget build(BuildContext context) { const tools = ['Crop Recommendation','Disease Detection','Yield Prediction','AgriBot','Decision Engine']; return SafeArea(child: ListView(padding: const EdgeInsets.all(18), children: [
    const TopBar(title: 'AI Farming', subtitle: 'Five intelligence systems in one place'), const SizedBox(height: 16),
    ...tools.map((tool) => Padding(padding: const EdgeInsets.only(bottom: 10), child: FeatureTile(icon: Icons.auto_awesome, title: tool, subtitle: 'AI analysis and action plan', onTap: () => onOpen(tool)))),
  ])); }
}

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});
  @override Widget build(BuildContext context) { final prices = context.watch<AgriProvider>().marketPrices; return SafeArea(child: ListView(padding: const EdgeInsets.all(18), children: [
    const TopBar(title: 'Market Intelligence', subtitle: 'Nearby prices and trends'), const SizedBox(height: 16),
    if (prices.isEmpty) const AgriCard(child: Text('Market data is loading.')) else ...prices.map((price) => Padding(padding: const EdgeInsets.only(bottom: 10), child: AgriCard(child: Row(children: [
      const Icon(Icons.grass, color: AppTheme.green), const SizedBox(width: 12), Expanded(child: Text('${price['crop']} • ${price['market']}')),
      Text('₹${price['price']}/q', style: const TextStyle(fontWeight: FontWeight.w800)),
    ])))),
    const AgriCard(child: Text('Market trends are guidance only. Verify local arrivals and buyer demand before selling.')),
  ])); }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(18), children: [
    const TopBar(title: 'Profile & Settings', subtitle: 'Your farm preferences'), const SizedBox(height: 16),
    const AgriCard(child: ListTile(leading: CircleAvatar(backgroundColor: AppTheme.green, child: Icon(Icons.person, color: Colors.white)), title: Text('Jatin'), subtitle: Text('Farmer • Ahmedabad, Gujarat'))),
    const SizedBox(height: 12), FeatureTile(icon: Icons.language, title: 'Language', subtitle: 'English • Hindi • Gujarati • Marathi +6', onTap: () {}),
    const SizedBox(height: 10), FeatureTile(icon: Icons.notifications_outlined, title: 'Notifications', subtitle: 'Weather, disease and market alerts', onTap: () {}),
  ]));
}

class FeaturePage extends StatelessWidget {
  const FeaturePage({super.key, required this.title});
  final String title;
  @override Widget build(BuildContext context) {
    final Widget body;
    switch (title) {
      case 'Crop Recommendation': body = const CropRecommendationView(); break;
      case 'Disease Detection': body = const DiseaseView(); break;
      case 'Yield Prediction': body = const YieldView(); break;
      case 'AgriBot': body = const BotView(); break;
      case 'Decision Engine': body = const DecisionView(); break;
      case 'Soil Health': body = const SoilView(); break;
      case 'Smart Irrigation': body = const IrrigationView(); break;
      case 'Fertilizer Recommendation': body = const FertilizerView(); break;
      default: body = GenericView(title: title);
    }
    return Scaffold(appBar: AppBar(title: Text(title)), body: body);
  }
}

class CropRecommendationView extends StatelessWidget {
  const CropRecommendationView({super.key});
  @override Widget build(BuildContext context) { final p = context.watch<AgriProvider>(); return ListView(padding: const EdgeInsets.all(18), children: [
    const AgriCard(child: Text('N 82 • P 48 • K 42 • pH 6.7 • 29°C • 78% humidity • 185 mm rainfall')),
    const SizedBox(height: 12), FilledButton.icon(onPressed: p.recommendCrop, icon: const Icon(Icons.auto_awesome), label: const Text('Run recommendation')),
    const SizedBox(height: 12), if (p.busy) const LinearProgressIndicator() else if (p.cropRecommendations.isEmpty) const AgriCard(child: Text('Run the model to see recommended crops.')) else ...p.cropRecommendations.map((r) => Padding(padding: const EdgeInsets.only(bottom: 10), child: AgriCard(child: Row(children: [ScoreRing(value: r.score, label: 'fit'), const SizedBox(width: 14), Expanded(child: Text(r.crop, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)))])))),
  ]); }
}

class DiseaseView extends StatelessWidget {
  const DiseaseView({super.key});
  @override Widget build(BuildContext context) { final p = context.watch<AgriProvider>(); return ListView(padding: const EdgeInsets.all(18), children: [
    AgriCard(child: Column(children: [const Icon(Icons.local_florist, color: AppTheme.green, size: 56), const SizedBox(height: 10), const Text('Scan a clear leaf image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 14), Row(children: [
      Expanded(child: OutlinedButton.icon(onPressed: () => p.scanDisease(source: ImageSource.camera), icon: const Icon(Icons.camera_alt), label: const Text('Camera'))), const SizedBox(width: 10),
      Expanded(child: OutlinedButton.icon(onPressed: () => p.scanDisease(source: ImageSource.gallery), icon: const Icon(Icons.photo), label: const Text('Gallery'))),
    ])])),
    const SizedBox(height: 12), if (p.busy) const LinearProgressIndicator() else if (p.disease != null) AgriCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(p.disease!.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 8), ScoreRing(value: p.disease!.confidence, label: 'confidence'), const SizedBox(height: 8),
      Text('Severity: ${p.disease!.severity}'), Text(p.disease!.cause), const SizedBox(height: 8), Text(p.disease!.action),
    ])),
  ]); }
}

class YieldView extends StatelessWidget {
  const YieldView({super.key});
  @override Widget build(BuildContext context) { final p = context.watch<AgriProvider>(); final result = p.yieldResult; return ListView(padding: const EdgeInsets.all(18), children: [
    const AgriCard(child: Text('Wheat • 4.8 ha • Moisture 31% • Historical yield 4.35 t/ha')), const SizedBox(height: 12),
    FilledButton.icon(onPressed: p.predictYield, icon: const Icon(Icons.analytics), label: const Text('Predict yield')), const SizedBox(height: 12),
    if (p.busy) const LinearProgressIndicator() else if (result == null) const AgriCard(child: Text('Run the model to see the expected yield.')) else AgriCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${result.estimated.toStringAsFixed(1)} t/ha', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), Text('Range ${result.min.toStringAsFixed(1)}–${result.max.toStringAsFixed(1)} t/ha'), const SizedBox(height: 8), LinearProgressIndicator(value: result.confidence),
    ])),
  ]); }
}

class BotView extends StatefulWidget { const BotView({super.key}); @override State<BotView> createState() => _BotViewState(); }
class _BotViewState extends State<BotView> {
  final controller = TextEditingController();
  @override void dispose() { controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) { final p = context.watch<AgriProvider>(); return Column(children: [
    Expanded(child: ListView(padding: const EdgeInsets.all(18), children: [if (p.messages.isEmpty) const AgriCard(child: Text('Ask AgriBot about crops, soil, pests, irrigation or harvesting.')), ...p.messages.map((m) => Align(
      alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: m.isUser ? AppTheme.green : Colors.white, borderRadius: BorderRadius.circular(14)), child: Text(m.text, style: TextStyle(color: m.isUser ? Colors.white : Colors.black87))),
    ))])),
    SafeArea(child: Row(children: [Expanded(child: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Ask AgriBot...'))), IconButton(onPressed: () { final text = controller.text; controller.clear(); p.askBot(text); }, icon: const Icon(Icons.send))])),
  ]); }
}

class DecisionView extends StatelessWidget { const DecisionView({super.key}); @override Widget build(BuildContext context) { final items = context.watch<AgriProvider>().insights; return ListView(padding: const EdgeInsets.all(18), children: items.isEmpty ? [const AgriCard(child: Text('Refresh the dashboard to generate smart decisions.'))] : items.map((i) => Padding(padding: const EdgeInsets.only(bottom: 10), child: AgriCard(child: ListTile(title: Text(i.title), subtitle: Text(i.message), trailing: Text(i.level))))).toList()); } }
class SoilView extends StatelessWidget { const SoilView({super.key}); @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: const [AgriCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Soil Health 87/100', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), SizedBox(height: 12), Text('pH 6.7'), Text('Nitrogen 82'), Text('Phosphorus 48'), Text('Potassium 42'), Text('Moisture 31%')]))]); }
class IrrigationView extends StatelessWidget { const IrrigationView({super.key}); @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: const [AgriCard(child: Text('Irrigation advice: soil moisture is low, but rain probability is high. Re-check field conditions before irrigating.'))]); }
class FertilizerView extends StatelessWidget { const FertilizerView({super.key}); @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: const [AgriCard(child: Text('Use an NPK-aware fertilizer plan matched to crop stage and soil-test results. Verify dosage locally before application.'))]); }
class GenericView extends StatelessWidget { const GenericView({super.key, required this.title}); final String title; @override Widget build(BuildContext context) => Center(child: Text('$title is ready for API integration.')); }
