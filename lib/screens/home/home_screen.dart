import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../weather/weather_screen.dart';
import '../notifications/notifications_screen.dart';

import '../crops/add_crop_screen.dart';
import '../disease_detection/disease_detection_screen.dart';
import '../farm/farm_screen.dart';
import '../market/market_screen.dart';

import '../recommendations/recommendations_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
            icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildWeatherCard(context),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildAIRecommendationBanner(context),
              const SizedBox(height: 24),
              _buildFarmOverview(),
              const SizedBox(height: 24),
              _buildTasksSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIRecommendationBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RecommendationsScreen())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.secondary,
              child: Icon(Icons.psychology, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('AI Recommendations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('3 new insights for your farm', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Good Morning,', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
            Text('Farmer John', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
        const CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=farmer'),
        ),
      ],
    );
  }

  Widget _buildWeatherCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WeatherScreen())),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Sunny Day', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                    Text('California, USA', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
                const Icon(Icons.wb_sunny, color: AppColors.accent, size: 40),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildWeatherStat(Icons.thermostat, '28°C', 'Temp'),
                _buildWeatherStat(Icons.water_drop, '65%', 'Humidity'),
                _buildWeatherStat(Icons.air, '12 km/h', 'Wind'),
                _buildWeatherStat(Icons.umbrella, '10%', 'Rain'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      {'icon': Icons.add_circle_outline, 'label': 'Add Crop', 'color': Colors.blue, 'screen': const AddCropScreen()},
      {'icon': Icons.qr_code_scanner, 'label': 'Scan', 'color': Colors.orange, 'screen': const DiseaseDetectionScreen()},
      {'icon': Icons.wb_sunny_outlined, 'label': 'Weather', 'color': Colors.amber, 'screen': const WeatherScreen()},
      {'icon': Icons.landscape, 'label': 'Farm', 'color': Colors.green, 'screen': const FarmScreen()},
      {'icon': Icons.storefront, 'label': 'Market', 'color': Colors.purple, 'screen': const MarketScreen()},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: actions.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => actions[index]['screen'])),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: (actions[index]['color'] as Color).withOpacity(0.1),
                        child: Icon(actions[index]['icon'] as IconData, color: actions[index]['color'] as Color),
                      ),
                      const SizedBox(height: 8),
                      Text(actions[index]['label'] as String, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFarmOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Farm Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildOverviewCard('Total Crops', '12', Icons.grass, Colors.green)),
            const SizedBox(width: 16),
            Expanded(child: _buildOverviewCard('Active Tasks', '5', Icons.task_alt, Colors.orange)),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tasks for Today', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        _buildTaskItem('Irrigate Tomato Field', '08:00 AM', Icons.water_drop, Colors.blue),
        _buildTaskItem('Apply Fertilizer to Corn', '10:30 AM', Icons.science, Colors.purple),
        _buildTaskItem('Check Pest Trap', '02:00 PM', Icons.bug_report, Colors.red),
      ],
    );
  }

  Widget _buildTaskItem(String title, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(time, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
