import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/agri_provider.dart';
import '../../widgets/agri_widgets.dart';
import '../../core/theme/app_theme.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});
  @override State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int index = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AgriProvider>().refresh());
  }
  void openFeature(String title) => Navigator.push(context, MaterialPageRoute(builder: (_) => FeaturePage(title: title)));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: [
        HomePage(onFeature: openFeature),
        FarmPage(onOpen: openFeature),
        AiHub(onOpen: openFeature),
        const MarketPage(),
        const ProfilePage(),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.agriculture_outlined), selectedIcon: Icon(Icons.agriculture), label: 'My Farm'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'AI'),
          NavigationDestination(icon: Icon(Icons.show_chart_outlined), selectedIcon: Icon(Icons.show_chart), label: 'Market'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: index == 0
          ? FloatingActionButton.extended(onPressed: () => openFeature('AgriBot'), backgroundColor: AppTheme.forest, icon: const Icon(Icons.smart_toy, color: Colors.white), label: const Text('AgriBot', style: TextStyle(color: Colors.white)))
          : null,
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.title, required this.subtitle});
  final String title, subtitle;
  @override Widget build(BuildContext context) => Row(children: [
    CircleAvatar(backgroundColor: AppTheme.green.withValues(alpha: .12), child: const Icon(Icons.eco, color: AppTheme.green)),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54))])),
    IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
  ]);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onFeature});
  final void Function(String) onFeature;
  @override Widget build(BuildContext context) {
    final p = context.watch<AgriProvider>();
    return SafeArea(child: RefreshIndicator(onRefresh: p.refresh, child: ListView(padding: const EdgeInsets.fromLTRB(18, 18, 18, 100), children: [
      const TopBar(title: 'Good morning, Jatin', subtitle: 'Green Valley Farm • Ahmedabad'),
      const SizedBox(height: 18),
      AgriCard(child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.forest, AppTheme.green]), borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("TODAY'S FARMING INTELLIGENCE", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8), const Text('Know what to do next.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)),
          const SizedBox(height: 16),
          Row(children: [const Icon(Icons.thermostat, color: Colors.white70), const SizedBox(width: 6), Text('${p.weather['temperature']}°C • ${p.weather['condition']}', style: const TextStyle(color: Colors.white)), const Spacer(), Text('${p.weather['rainProbability']}% rain', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))]),
        ]),
      )),
      const SizedBox(height: 16),
      Row(children: [Expanded(child: MetricTile(icon: Icons.water_drop_outlined, title: 'Soil Moisture', value: '${p.farm.moisture.round()}%', subtitle: 'Target 40–60%')), const SizedBox(width: 12), Expanded(child: MetricTile(icon: Icons.eco_outlined, title: 'Soil Health', value: '87/100', subtitle: 'Good condition'))]),
      const SizedBox(height: 18), const Text('Recommended actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 10),
      if (p.insights.isEmpty) const LinearProgressIndicator() else ...p.insights.take(4).map((i) => Padding(padding: const EdgeInsets.only(bottom: 10), child: AgriCard(child: ListTile(leading: CircleAvatar(backgroundColor: AppTheme.green.withValues(alpha: .1), child: Icon(IconData(i.icon, fontFamily: 'MaterialIcons'), color: AppTheme.green)), title: Text(i.title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(i.message), trailing: Text(i.level, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: i.level == 'High' ? Colors.red : AppTheme.green))))),
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
      AgriCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.agriculture, color: AppTheme.green), const SizedBox(width: 10), Expanded(child: Text(f.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))), Chip(label: Text('${f.area} ha'))]), const SizedBox(height: 14), Wrap(spacing: 8, children: [Chip(label: Text(f.location)), Chip(label: Text(f.soil)), Chip(label: Text(f.crop)), Chip(label: Text('Moisture ${f.moisture.round()}%'))]), const SizedBox(height: 14), const LinearProgressIndicator(value: .68), const SizedBox(height: 8), const Text('Crop timeline • Growth stage: Flowering', style: TextStyle(fontSize: 12, color: Colors.black54))])),
      const SizedBox(height: 16), FeatureTile(icon: Icons.add_circle_outline, title: 'Add another farm', subtitle: 'Track multiple fields independently', onTap: () => onOpen('Add Farm')),
      const SizedBox(height: 10), FeatureTile(icon: Icons.timeline, title: 'Crop management', subtitle: 'Schedule, growth stages and harvest', onTap: () => onOpen('Crop Management')),
      const SizedBox(height: 10), FeatureTile(icon: Icons.science, title: 'Soil health', subtitle: 'NPK, pH, moisture and organic matter', onTap: () => onOpen('Soil Health')),
    ]));
  }
}

class AiHub extends StatelessWidget {
  const AiHub({super.key, required this.onOpen});
  final void Function(String) onOpen;
  @override Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(18), children: [
    const TopBar(title: 'AI Farming', subtitle: 'Five intelligence systems in one place'), const SizedBox(height: 16), const Text('Pick an AI tool', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 10),
    ...['Crop Recommendation', 'Disease Detection', 'Yield Prediction', 'AgriBot', 'Decision Engine'].map((x) => Padding(padding: const EdgeInsets.only(bottom: 10), child: FeatureTile(icon: Icons.auto_awesome, title: x, subtitle: 'AI analysis with explanation and actions', onTap: () => onOpen(x)))),
  ]));
}

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});
  @override Widget build(BuildContext context) {
    final prices = context.watch<AgriProvider>().marketPrices;
    return SafeArea(child: ListView(padding: const EdgeInsets.all(18), children: [
      const TopBar(title: 'Market Intelligence', subtitle: 'Nearby prices and trends'), const SizedBox(height: 16),
      if (prices.isEmpty) const LinearProgressIndicator() else ...prices.map((x) => Padding(padding: const EdgeInsets.only(bottom: 10), child: AgriCard(child: Row(children: [Container(width: 46, height: 46, decoration: BoxDecoration(color: AppTheme.green.withValues(alpha: .1), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.grass, color: AppTheme.green)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${x['crop']}', style: const TextStyle(fontWeight: FontWeight.w800)), Text('${x['market']} • ₹${x['price']}/q', style: const TextStyle(fontSize: 12, color: Colors.black54))])), Text('${x['trend']}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.green))])))),
      const SizedBox(height: 10), const AgriCard(child: Text('AI note: Market trends are guidance only. Verify local arrivals, quality and buyer demand before selling.', style: TextStyle(fontSize: 12, color: Colors.black54))),
    ]));
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(18), children: [
    const TopBar(title: 'Profile & Settings', subtitle: 'Your farm preferences'), const SizedBox(height: 16),
    const AgriCard(child: ListTile(leading: CircleAvatar(backgroundColor: AppTheme.green, child: Icon(Icons.person, color: Colors.white)), title: Text('Jatin', style: TextStyle(fontWeight: FontWeight.w900)), subtitle: Text('Farmer • Ahmedabad, Gujarat'))),
    const SizedBox(height: 12), FeatureTile(icon: Icons.language, title: 'Language', subtitle: 'English • Hindi • Gujarati • Marathi +6', onTap: () {}),
    const SizedBox(height: 10), FeatureTile(icon: Icons.notifications_outlined, title: 'Notifications', subtitle: 'Weather, disease, irrigation and market alerts', onTap: () {}),
    const SizedBox(height: 10), FeatureTile(icon: Icons.verified_user_outlined, title: 'Privacy & security', subtitle: 'Permissions and account controls', onTap: () {}),
    const SizedBox(height: 10), FeatureTile(icon: Icons.menu_book_outlined, title: 'Government schemes', subtitle: 'Eligibility and official sources', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeaturePage(title: 'Government Schemes')))),
  ]));
}

class FeaturePage extends StatelessWidget {
  const FeaturePage({super.key, required this.title});
  final String title;
  @override Widget build(BuildContext context) {
    final Widget body = switch (title) {
      'Crop Recommendation' => const CropRecommendationView(),
      'Disease Detection' => const DiseaseView(),
      'Yield Prediction' => const YieldView(),
      'AgriBot' => const BotView(),
      'Decision Engine' => const DecisionView(),
      'Soil Health' => const SoilView(),
      'Smart Irrigation' => const IrrigationView(),
      'Fertilizer Recommendation' => const FertilizerView(),
      _ => GenericView(title: title),
    };
    return Scaffold(appBar: AppBar(title: Text(title)), body: body);
  }
}

class CropRecommendationView extends StatelessWidget {
  const CropRecommendationView({super.key});
  @override Widget build(BuildContext context) { final p = context.watch<AgriProvider>(); return ListView(padding: const EdgeInsets.all(18), children: [
    const AgriCard(child: Text('Soil: N 82 • P 48 • K 42 • pH 6.7 • 29°C • 78% humidity • 185 mm rainfall')),
    const SizedBox(height: 12), FilledButton.icon(onPressed: p.recommendCrop, icon: const Icon(Icons.auto_awesome), label: const Text('Run crop recommendation')),
    const SizedBox(height: 12), if (p.busy) const LinearProgressIndicator() else ...p.cropRecommendations.map((r) => Padding(padding: const EdgeInsets.only(bottom: 10), child: AgriCard(child: Row(children: [ScoreRing(value: r.score, label: 'fit'), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r.crop, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), Text(r.reason, style: const TextStyle(color: Colors.black54)), const SizedBox(height: 6), Text('${r.duration} • Water ${r.water}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))]))])))),
  ]); }
}

class DiseaseView extends StatelessWidget {
  const DiseaseView({super.key});
  @override Widget build(BuildContext context) { final p = context.watch<AgriProvider>(); return ListView(padding: const EdgeInsets.all(18), children: [
    AgriCard(child: Column(children: [const Icon(Icons.local_florist, color: AppTheme.green, size: 60), const SizedBox(height: 8), const Text('Scan a clear leaf or crop image', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)), const SizedBox(height: 8), const Text('Use camera or gallery. Confirm important diagnoses locally.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)), const SizedBox(height: 16), Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () => p.scanDisease(source: ImageSource.camera), icon: const Icon(Icons.camera_alt), label: const Text('Camera'))), const SizedBox(width: 10), Expanded(child: OutlinedButton.icon(onPressed: () => p.scanDisease(source: ImageSource.gallery), icon: const Icon(Icons.photo_library), label: const Text('Gallery')))])])),
    const SizedBox(height: 12), if (p.busy) const LinearProgressIndicator() else if (p.disease != null) AgriCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [ScoreRing(value: p.disease!.confidence, label: 'conf.'), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.disease!.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), Text('Severity: ${p.disease!.severity}', style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.orange))]))]), const Divider(height: 28), const Text('Likely cause', style: TextStyle(fontWeight: FontWeight.w900)), Text(p.disease!.cause), const SizedBox(height: 10), const Text('Recommended action', style: TextStyle(fontWeight: FontWeight.w900)), Text(p.disease!.action)])),
  ]); }
}

class YieldView extends StatelessWidget {
  const YieldView({super.key});
  @override Widget build(BuildContext context) { final p = context.watch<AgriProvider>(); final y = p.yield; return ListView(padding: const EdgeInsets.all(18), children: [
    const AgriCard(child: Text('Wheat • 4.8 ha • Moisture 31% • Fertilizer index 70 • Historical yield 4.35 t/ha')),
    const SizedBox(height: 12), FilledButton.icon(onPressed: p.predictYield, icon: const Icon(Icons.analytics), label: const Text('Predict yield')),
    const SizedBox(height: 12), if (p.busy) const LinearProgressIndicator() else if (y != null) AgriCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${y.estimated.toStringAsFixed(1)} tons/hectare', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), Text('Expected range: ${y.min.toStringAsFixed(1)}–${y.max.toStringAsFixed(1)} t/ha'), const SizedBox(height: 12), LinearProgressIndicator(value: y.confidence), const SizedBox(height: 6), Text('Confidence ${(y.confidence * 100).round()}%')])) else const AgriCard(child: Text('Run the model to see your expected yield and confidence.')),
  ]); }
}

class BotView extends StatefulWidget { const BotView({super.key}); @override State<BotView> createState() => _BotViewState(); }
class _BotViewState extends State<BotView> { final controller = TextEditingController(); @override void dispose(){controller.dispose(); super.dispose();}
  @override Widget build(BuildContext context) { final p = context.watch<AgriProvider>(); return Column(children: [Expanded(child: ListView(padding: const EdgeInsets.all(18), children: [if (p.messages.isEmpty) const AgriCard(child: Text('Ask about crops, pests, irrigation, soil, fertilizer, weather or harvesting.')), ...p.messages.map((m) => Align(alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: m.isUser ? AppTheme.green : Colors.white, borderRadius: BorderRadius.circular(16)), child: Text(m.text, style: TextStyle(color: m.isUser ? Colors.white : Colors.black87)))))])), SafeArea(child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [Expanded(child: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Ask AgriBot...'))), IconButton(onPressed: () { final text = controller.text; controller.clear(); p.askBot(text); }, icon: const Icon(Icons.send))]))]); }
}

class DecisionView extends StatelessWidget { const DecisionView({super.key}); @override Widget build(BuildContext context){ final list = context.watch<AgriProvider>().insights; return ListView(padding: const EdgeInsets.all(18), children: [if(list.isEmpty) const LinearProgressIndicator() else ...list.map((i) => Padding(padding: const EdgeInsets.only(bottom: 10), child: AgriCard(child: ListTile(title: Text(i.title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(i.message), trailing: Text(i.level)))))]); } }
class SoilView extends StatelessWidget { const SoilView({super.key}); @override Widget build(BuildContext context)=>const ListView(padding: EdgeInsets.all(18), children: [AgriCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Soil Health Score: 87/100', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), SizedBox(height: 14), Text('pH 6.7'), Text('Nitrogen 82'), Text('Phosphorus 48'), Text('Potassium 42'), Text('Moisture 31%')]))]); }
class IrrigationView extends StatelessWidget { const IrrigationView({super.key}); @override Widget build(BuildContext context)=>const ListView(padding: EdgeInsets.all(18), children: [AgriCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Irrigation: Recommended', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), SizedBox(height: 8), Text('Current moisture is below the preferred range. Rain is expected soon, so re-check before irrigating.')])),]); }
class FertilizerView extends StatelessWidget { const FertilizerView({super.key}); @override Widget build(BuildContext context)=>const ListView(padding: EdgeInsets.all(18), children: [AgriCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Fertilizer Plan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), SizedBox(height: 10), Text('Use an NPK-aware plan matched to crop growth stage and soil test results. Verify exact dosage with a local agricultural expert before application.')]))]); }
class GenericView extends StatelessWidget { const GenericView({super.key, required this.title}); final String title; @override Widget build(BuildContext context)=>ListView(padding: const EdgeInsets.all(18), children: [AgriCard(child: Text('$title is ready for backend/API integration.', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)))]); }
