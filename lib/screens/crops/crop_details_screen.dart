import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/crop.dart';

class CropDetailsScreen extends StatelessWidget {
  final Crop crop;
  const CropDetailsScreen({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              expandedHeight: 210,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(crop.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                background: Container(
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                  child: const Center(child: Icon(Icons.eco_rounded, color: Colors.white54, size: 90)),
                ),
              ),
            ),
            SliverPersistentHeader(pinned: true, delegate: _TabDelegate(const TabBar(tabs: [Tab(text: 'Overview'), Tab(text: 'Tasks'), Tab(text: 'Health'), Tab(text: 'Notes')]))),
          ],
          body: TabBarView(children: [_overview(context), _tasks(context), _health(context), _notes(context)]),
        ),
      ),
    );
  }

  Widget _overview(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2.1, children: [
      _Info(icon: Icons.landscape_outlined, label: 'Farm', value: crop.farmName),
      _Info(icon: Icons.square_foot_outlined, label: 'Area', value: '${crop.areaAcres.toStringAsFixed(1)} acres'),
      _Info(icon: Icons.calendar_today_outlined, label: 'Planted', value: '${crop.plantedOn.day}/${crop.plantedOn.month}/${crop.plantedOn.year}'),
      _Info(icon: Icons.event_available_outlined, label: 'Harvest', value: '${crop.expectedHarvest.day}/${crop.expectedHarvest.month}/${crop.expectedHarvest.year}'),
    ]),
    const SizedBox(height: 22),
    const Text('Growth timeline', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
    const SizedBox(height: 12),
    _TimelineRow(title: 'Planting', date: crop.plantedOn, done: true),
    _TimelineRow(title: 'Vegetative stage', date: crop.plantedOn.add(const Duration(days: 25)), done: crop.progress > .28),
    _TimelineRow(title: 'Flowering stage', date: crop.plantedOn.add(const Duration(days: 50)), done: crop.progress > .55),
    _TimelineRow(title: 'Harvest window', date: crop.expectedHarvest, done: crop.progress >= .95),
  ]);

  Widget _tasks(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: const [
    _Task(title: 'Morning irrigation', time: '08:00 AM', icon: Icons.water_drop_outlined),
    _Task(title: 'Scout for pests', time: '11:30 AM', icon: Icons.bug_report_outlined),
    _Task(title: 'Leaf health check', time: '04:00 PM', icon: Icons.eco_outlined),
  ]);

  Widget _health(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(22)), child: Row(children: [const Icon(Icons.favorite_rounded, color: AppColors.primary, size: 28), const SizedBox(width: 12), Expanded(child: Text('Overall health: ${_healthLabel()}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)))])),
    const SizedBox(height: 14),
    const _Bullet(title: 'Soil moisture', value: 'Optimal range'),
    const _Bullet(title: 'Leaf color', value: 'Healthy green'),
    const _Bullet(title: 'Pest pressure', value: 'Low'),
  ]);

  Widget _notes(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    ...crop.notes.map((note) => Card(child: ListTile(leading: const Icon(Icons.notes_outlined, color: AppColors.primary), title: Text(note)))),
    const SizedBox(height: 12),
    OutlinedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notes editor opened.'))), icon: const Icon(Icons.add), label: const Text('Add note')),
  ]);

  String _healthLabel() => switch (crop.health) { CropHealth.excellent => 'Excellent', CropHealth.good => 'Good', CropHealth.attention => 'Needs attention', CropHealth.critical => 'Critical' };
}

class _Info extends StatelessWidget {
  final IconData icon; final String label, value;
  const _Info({required this.icon, required this.label, required this.value});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: .35))), child: Row(children: [Icon(icon, color: AppColors.primary, size: 20), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)), Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))]))]));
}

class _TimelineRow extends StatelessWidget {
  final String title; final DateTime date; final bool done;
  const _TimelineRow({required this.title, required this.date, required this.done});
  @override Widget build(BuildContext context) => ListTile(leading: Icon(done ? Icons.check_circle_rounded : Icons.circle_outlined, color: done ? AppColors.primary : AppColors.textSecondary), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text('${date.day}/${date.month}/${date.year}'));
}

class _Task extends StatelessWidget { final String title, time; final IconData icon; const _Task({required this.title, required this.time, required this.icon}); @override Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(leading: CircleAvatar(backgroundColor: AppColors.mint, child: Icon(icon, color: AppColors.primary)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(time), trailing: Checkbox(value: false, onChanged: (_) {}))); }
class _Bullet extends StatelessWidget { final String title, value; const _Bullet({required this.title, required this.value}); @override Widget build(BuildContext context) => ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.check_circle_outline, color: AppColors.primary), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), trailing: Text(value, style: const TextStyle(color: AppColors.textSecondary))); }

class _TabDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabs; const _TabDelegate(this.tabs);
  @override double get minExtent => tabs.preferredSize.height;
  @override double get maxExtent => tabs.preferredSize.height;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Container(color: Theme.of(context).scaffoldBackgroundColor, child: tabs);
  @override bool shouldRebuild(covariant _TabDelegate oldDelegate) => false;
}
