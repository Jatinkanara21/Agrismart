import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recommendations = [
      {
        'title': 'Irrigation Recommendation',
        'priority': 'High',
        'icon': Icons.water_drop,
        'desc': 'Based on soil moisture and upcoming heat wave.',
        'action': 'Irrigate North Farm for 2 hours tonight.',
      },
      {
        'title': 'Fertilizer Optimization',
        'priority': 'Medium',
        'icon': Icons.science,
        'desc': 'Tomato crops are entering flowering stage.',
        'action': 'Apply Nitrogen-rich fertilizer.',
      },
      {
        'title': 'Pest Warning',
        'priority': 'High',
        'icon': Icons.bug_report,
        'desc': 'Nearby farms reported aphid infestations.',
        'action': 'Inspect leaf undersides and apply preventive neem oil.',
      },
      {
        'title': 'Harvest Timing',
        'priority': 'Low',
        'icon': Icons.shopping_basket,
        'desc': 'Wheat moisture levels are nearing optimal.',
        'action': 'Plan harvest for next week Thursday.',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('AI Recommendations')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final rec = recommendations[index];
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
                      Row(
                        children: [
                          Icon(rec['icon'] as IconData, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text(rec['title'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      _buildPriorityTag(rec['priority'] as String),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(rec['desc'] as String, style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 20, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(child: Text(rec['action'] as String, style: const TextStyle(fontWeight: FontWeight.w500))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriorityTag(String priority) {
    Color color;
    switch (priority) {
      case 'High': color = Colors.red; break;
      case 'Medium': color = Colors.orange; break;
      default: color = Colors.blue;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(priority, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
