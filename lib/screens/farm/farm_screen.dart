import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FarmScreen extends StatelessWidget {
  const FarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> farms = [
      {'name': 'North Valley Farm', 'location': 'California', 'size': '50 Acres', 'crops': 5, 'soil': 'Loamy'},
      {'name': 'Green Hill Field', 'location': 'Oregon', 'size': '25 Acres', 'crops': 3, 'soil': 'Clay'},
      {'name': 'East Riverside', 'location': 'California', 'size': '100 Acres', 'crops': 8, 'soil': 'Sandy'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Farms'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: farms.length,
        itemBuilder: (context, index) {
          final farm = farms[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(farm['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Icon(Icons.more_vert),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(farm['location'], style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFarmStat(Icons.square_foot, 'Size', farm['size']),
                      _buildFarmStat(Icons.grass, 'Crops', farm['crops'].toString()),
                      _buildFarmStat(Icons.layers, 'Soil', farm['soil']),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                    ),
                    child: const Text('View Crops in this Farm'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFarmStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
