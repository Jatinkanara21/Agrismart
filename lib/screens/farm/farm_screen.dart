import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/farm.dart';
import '../../providers/dashboard_provider.dart';
import '../../services/mock_api_service.dart';

class FarmScreen extends StatelessWidget {
  const FarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardProvider(MockApiService())..load(),
      child: const _FarmView(),
    );
  }
}

class _FarmView extends StatelessWidget {
  const _FarmView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('My farms', style: TextStyle(fontWeight: FontWeight.w800)), actions: [IconButton(onPressed: () => _showAddFarm(context), icon: const Icon(Icons.add_rounded))]),
      body: RefreshIndicator(
        onRefresh: provider.load,
        color: AppColors.primary,
        child: provider.loading && provider.farms.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.farms.isEmpty
            ? ListView(children: const [SizedBox(height: 200), Center(child: Text('No farms configured.'))])
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: provider.farms.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _FarmCard(farm: provider.farms[index]),
              ),
      ),
    );
  }

  Future<void> _showAddFarm(BuildContext context) async {
    final name = TextEditingController();
    final location = TextEditingController();
    final area = TextEditingController();
    await showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (_) => Padding(padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 20), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Align(alignment: Alignment.centerLeft, child: Text('Add a farm', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))), const SizedBox(height: 16),
      TextField(controller: name, decoration: const InputDecoration(labelText: 'Farm name')), const SizedBox(height: 10),
      TextField(controller: location, decoration: const InputDecoration(labelText: 'Location')), const SizedBox(height: 10),
      TextField(controller: area, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Area in acres')), const SizedBox(height: 16),
      ElevatedButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${name.text.isEmpty ? 'Farm' : name.text} added to your workspace'))); }, child: const Text('Save farm')),
    ])));
    name.dispose(); location.dispose(); area.dispose();
  }
}

class _FarmCard extends StatelessWidget {
  final Farm farm;
  const _FarmCard({required this.farm});

  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.terrain_rounded, color: AppColors.primary)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(farm.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), Text(farm.location, style: const TextStyle(color: AppColors.textSecondary))])), const Icon(Icons.more_horiz_rounded)]),
    const SizedBox(height: 18),
    Row(children: [Expanded(child: _Metric(icon: Icons.square_foot_rounded, label: 'Area', value: '${farm.areaAcres.toStringAsFixed(1)} ac')), Expanded(child: _Metric(icon: Icons.layers_outlined, label: 'Soil', value: farm.soilType)), Expanded(child: _Metric(icon: Icons.opacity_outlined, label: 'Moisture', value: '${farm.soilMoisture}%'))]),
    const SizedBox(height: 16),
    Row(children: [Expanded(child: Text('Soil pH ${farm.ph.toStringAsFixed(1)}', style: const TextStyle(color: AppColors.textSecondary))), FilledButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening ${farm.name} details'))), child: const Text('Details'))]),
  ])));
}

class _Metric extends StatelessWidget { final IconData icon; final String label, value; const _Metric({required this.icon, required this.label, required this.value}); @override Widget build(BuildContext context) => Row(children: [Icon(icon, size: 18, color: AppColors.primary), const SizedBox(width: 7), Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontWeight: FontWeight.w800)), Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11))]))]); }
