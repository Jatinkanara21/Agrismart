import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Irrigation Reminder',
        'message': 'Time to irrigate your Tomato field. Optimal time is now.',
        'time': '10 mins ago',
        'type': 'alert',
        'isRead': false,
      },
      {
        'title': 'Weather Warning',
        'message': 'Heavy rain expected tomorrow. Secure your greenhouse.',
        'time': '2 hours ago',
        'type': 'weather',
        'isRead': false,
      },
      {
        'title': 'Price Update',
        'message': 'Market price for Corn increased by 5%.',
        'time': '5 hours ago',
        'type': 'market',
        'isRead': true,
      },
      {
        'title': 'Fertilizer Time',
        'message': 'Scheduled fertilizer application for Wheat field.',
        'time': '1 day ago',
        'type': 'crop',
        'isRead': true,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Container(
            color: notification['isRead'] ? Colors.transparent : AppColors.primary.withOpacity(0.05),
            child: ListTile(
              leading: _getIcon(notification['type']),
              title: Text(notification['title'], style: TextStyle(fontWeight: notification['isRead'] ? FontWeight.normal : FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification['message']),
                  const SizedBox(height: 4),
                  Text(notification['time'], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              isThreeLine: true,
              onTap: () {},
            ),
          );
        },
      ),
    );
  }

  Widget _getIcon(String type) {
    IconData icon;
    Color color;
    switch (type) {
      case 'alert':
        icon = Icons.warning_amber_rounded;
        color = Colors.orange;
        break;
      case 'weather':
        icon = Icons.cloudy_snowing;
        color = Colors.blue;
        break;
      case 'market':
        icon = Icons.trending_up;
        color = Colors.green;
        break;
      default:
        icon = Icons.info_outline;
        color = AppColors.primary;
    }
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
