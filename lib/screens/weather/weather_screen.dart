import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Weather Forecast'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildCurrentWeather(),
            const SizedBox(height: 24),
            _buildRecommendationCard(),
            const SizedBox(height: 24),
            _buildForecastList(),
            const SizedBox(height: 24),
            _buildWeatherDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeather() {
    return Column(
      children: [
        const Text('California, USA', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Text('Monday, 20 May', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 20),
        const Icon(Icons.wb_sunny, size: 80, color: Colors.orange),
        const SizedBox(height: 10),
        const Text('28°', style: TextStyle(fontSize: 64, fontWeight: FontWeight.w300)),
        const Text('Mostly Sunny', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildRecommendationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: AppColors.primary),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Good day for irrigation and applying fertilizers. Avoid spraying pesticides due to moderate wind.',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastList() {
    final days = ['Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('7-Day Forecast', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            itemBuilder: (context, index) {
              return Container(
                width: 70,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(days[index], style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    const Icon(Icons.wb_cloudy_outlined, size: 24, color: Colors.blue),
                    const SizedBox(height: 8),
                    const Text('24°', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 2,
        children: [
          _buildDetail('Humidity', '65%', Icons.water_drop),
          _buildDetail('Wind', '12 km/h', Icons.air),
          _buildDetail('UV Index', 'Low (2)', Icons.wb_sunny),
          _buildDetail('Rain', '10%', Icons.umbrella),
          _buildDetail('Sunrise', '06:12 AM', Icons.wb_twilight),
          _buildDetail('Sunset', '07:45 PM', Icons.nights_stay),
        ],
      ),
    );
  }

  Widget _buildDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
