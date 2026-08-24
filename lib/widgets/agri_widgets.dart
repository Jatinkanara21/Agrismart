import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class AgriCard extends StatelessWidget {
  const AgriCard({super.key, required this.child, this.padding = const EdgeInsets.all(18)});
  final Widget child;
  final EdgeInsets padding;
  @override Widget build(BuildContext context) => Card(child: Padding(padding: padding, child: child));
}

class ScoreRing extends StatelessWidget {
  const ScoreRing({super.key, required this.value, required this.label});
  final double value; final String label;
  @override Widget build(BuildContext context) => SizedBox(width: 82, height: 82, child: Stack(alignment: Alignment.center, children: [
    CircularProgressIndicator(value: value, strokeWidth: 7, backgroundColor: AppTheme.freshGreen.withOpacity(.16), color: AppTheme.green),
    Column(mainAxisSize: MainAxisSize.min, children: [Text('${(value*100).round()}%', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), Text(label, style: const TextStyle(fontSize: 10))])
  ]));
}

class MetricTile extends StatelessWidget {
  const MetricTile({super.key, required this.icon, required this.title, required this.value, required this.subtitle});
  final IconData icon; final String title, value, subtitle;
  @override Widget build(BuildContext context) => AgriCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: AppTheme.green), const SizedBox(height: 12), Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)), const SizedBox(height: 4), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.black54))]));
}

class FeatureTile extends StatelessWidget {
  const FeatureTile({super.key, required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon; final String title, subtitle; final VoidCallback onTap;
  @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: AgriCard(child: Row(children: [Container(width: 46, height: 46, decoration: BoxDecoration(color: AppTheme.green.withOpacity(.1), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: AppTheme.green)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54))])), const Icon(Icons.chevron_right)])));
}
