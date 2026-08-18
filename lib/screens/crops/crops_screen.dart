import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/crop.dart';
import '../../providers/crop_provider.dart';
import '../../services/mock_api_service.dart';
import 'add_crop_screen.dart';
import 'crop_details_screen.dart';

class CropsScreen extends StatelessWidget {
  const CropsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CropProvider(MockApiService())..load(),
      child: const _CropsView(),
    );
  }
}

class _CropsView extends StatelessWidget {
  const _CropsView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CropProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('My crops', style: TextStyle(fontWeight: FontWeight.w800))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final crop = await Navigator.push<Crop>(context, MaterialPageRoute(builder: (_) => const AddCropScreen()));
          if (crop != null) provider.addCrop(crop);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add crop'),
      ),
      body: RefreshIndicator(
        onRefresh: provider.load,
        color: AppColors.primary,
        child: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
            ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(provider.error!, textAlign: TextAlign.center), const SizedBox(height: 14), FilledButton(onPressed: provider.load, child: const Text('Retry'))])) )
            : provider.crops.isEmpty
              ? ListView(children: const [SizedBox(height: 180), Center(child: Text('No crops yet. Add your first crop.'))])
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
                  itemCount: provider.crops.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _CropCard(crop: provider.crops[index], onDelete: () => provider.deleteCrop(provider.crops[index].id)),
                ),
      ),
    );
  }
}

class _CropCard extends StatelessWidget {
  final Crop crop;
  final VoidCallback onDelete;
  const _CropCard({required this.crop, required this.onDelete});

  Color _healthColor() => switch (crop.health) {
    CropHealth.excellent => AppColors.primary,
    CropHealth.good => AppColors.primaryLight,
    CropHealth.attention => AppColors.warning,
    CropHealth.critical => AppColors.error,
  };

  String _healthLabel() => switch (crop.health) {
    CropHealth.excellent => 'Excellent', CropHealth.good => 'Good', CropHealth.attention => 'Needs attention', CropHealth.critical => 'Critical'
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CropDetailsScreen(crop: crop))),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 54, height: 54, decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.eco_rounded, color: AppColors.primary, size: 28)),
              const SizedBox(width: 13),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(crop.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), Text('${crop.variety} • ${crop.farmName}', style: const TextStyle(color: AppColors.textSecondary))])),
              PopupMenuButton<String>(onSelected: (value) { if (value == 'delete') onDelete(); }, itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Text('Delete crop'))]),
            ]),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Growth progress', style: Theme.of(context).textTheme.bodySmall), Text('${(crop.progress * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w800))]),
            const SizedBox(height: 8),
            ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: crop.progress, minHeight: 9, color: AppColors.primary, backgroundColor: Theme.of(context).dividerColor.withValues(alpha: .32))),
            const SizedBox(height: 14),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: _healthColor().withValues(alpha: .12), borderRadius: BorderRadius.circular(10)), child: Text(_healthLabel(), style: TextStyle(color: _healthColor(), fontWeight: FontWeight.w700, fontSize: 12))),
              const Spacer(),
              Text('${crop.areaAcres.toStringAsFixed(1)} acres', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ]),
          ]),
        ),
      ),
    );
  }
}
