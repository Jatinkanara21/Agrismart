import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'crop_details_screen.dart';
import 'add_crop_screen.dart';

class CropsScreen extends StatelessWidget {
  const CropsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> crops = [
      {'name': 'Tomato', 'type': 'Vegetable', 'growth': 0.75, 'status': 'Healthy', 'daysLeft': 15, 'image': 'https://images.unsplash.com/photo-1592841208389-52317a70233d?w=500&q=80'},
      {'name': 'Corn', 'type': 'Grain', 'growth': 0.40, 'status': 'Needs Water', 'daysLeft': 45, 'image': 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=500&q=80'},
      {'name': 'Wheat', 'type': 'Grain', 'growth': 0.90, 'status': 'Harvest Ready', 'daysLeft': 2, 'image': 'https://images.unsplash.com/photo-1501430654243-c936ceaaf399?w=500&q=80'},
      {'name': 'Carrot', 'type': 'Vegetable', 'growth': 0.60, 'status': 'Healthy', 'daysLeft': 25, 'image': 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=500&q=80'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Crops'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCropScreen())),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: crops.length,
        itemBuilder: (context, index) {
          final crop = crops[index];
          return _buildCropCard(context, crop);
        },
      ),
    );
  }

  Widget _buildCropCard(BuildContext context, Map<String, dynamic> crop) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CropDetailsScreen(crop: crop))),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Stack(
              children: [
                Image.network(
                  crop['image'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(crop['status']).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      crop['status'],
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(crop['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(crop['type'], style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: crop['growth'],
                          backgroundColor: Colors.grey.shade200,
                          color: AppColors.primary,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('${(crop['growth'] * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem(Icons.calendar_today, 'Planted', 'Mar 12, 2024'),
                      _buildInfoItem(Icons.timer, 'Harvest', 'in ${crop['daysLeft']} days'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Healthy': return Colors.green;
      case 'Needs Water': return Colors.blue;
      case 'Harvest Ready': return Colors.orange;
      default: return Colors.grey;
    }
  }
}
