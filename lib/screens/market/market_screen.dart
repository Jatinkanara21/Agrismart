import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/market_price.dart';
import '../../providers/dashboard_provider.dart';
import '../../services/mock_api_service.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});
  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  int selected = 0;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardProvider(MockApiService())..load(),
      child: Builder(builder: (context) {
        final provider = context.watch<DashboardProvider>();
        if (provider.loading && provider.markets.isEmpty) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        if (provider.markets.isEmpty) return Scaffold(appBar: AppBar(title: const Text('Market')), body: const Center(child: Text('Market data unavailable.')));
        final item = provider.markets[selected.clamp(0, provider.markets.length - 1)];
        return Scaffold(
          appBar: AppBar(title: const Text('Market intelligence', style: TextStyle(fontWeight: FontWeight.w800))),
          body: RefreshIndicator(onRefresh: provider.load, color: AppColors.primary, child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 110), physics: const AlwaysScrollableScrollPhysics(), children: [
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: .4))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Price trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), Container(padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(12)), child: DropdownButtonHideUnderline(child: DropdownButton<int>(value: selected, items: List.generate(provider.markets.length, (i) => DropdownMenuItem(value: i, child: Text(provider.markets[i].crop))), onChanged: (v) => setState(() => selected = v ?? 0))))]),
              const SizedBox(height: 12),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('₹${item.currentPrice.toStringAsFixed(1)}', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)), const SizedBox(width: 8), Padding(padding: const EdgeInsets.only(bottom: 7), child: Text('${item.changePercent >= 0 ? '+' : ''}${item.changePercent.toStringAsFixed(1)}%', style: TextStyle(color: item.changePercent >= 0 ? AppColors.primary : AppColors.error, fontWeight: FontWeight.w800)))]),
              Text('per ${item.unit == '₹/kg' ? 'kg' : 'unit'}', style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 18),
              SizedBox(height: 200, child: LineChart(LineChartData(minY: item.trend.map((e) => e.price).reduce((a,b) => a < b ? a : b) - 2, maxY: item.trend.map((e) => e.price).reduce((a,b) => a > b ? a : b) + 2, gridData: const FlGridData(show: false), titlesData: const FlTitlesData(show: false), borderData: FlBorderData(show: false), lineBarsData: [LineChartBarData(spots: [for (int i = 0; i < item.trend.length; i++) FlSpot(i.toDouble(), item.trend[i].price)], isCurved: true, color: AppColors.primary, barWidth: 4, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: AppColors.primaryLight.withValues(alpha: .16)))]))),
            ])),
            const SizedBox(height: 18),
            const Text('Market snapshot', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 10),
            ...provider.markets.asMap().entries.map((entry) { final i = entry.key; final price = entry.value; final up = price.changePercent >= 0; return Card(child: ListTile(onTap: () => setState(() => selected = i), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5), leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.agriculture_outlined, color: AppColors.primary)), title: Text(price.crop, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(price.unit == '₹/kg' ? 'Local wholesale' : 'Regional market'), trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text('₹${price.currentPrice.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.w800)), Text('${up ? '+' : ''}${price.changePercent.toStringAsFixed(1)}%', style: TextStyle(color: up ? AppColors.primary : AppColors.error, fontSize: 12, fontWeight: FontWeight.w700))]))); }),
          ])),
        );
      }),
    );
  }
}
