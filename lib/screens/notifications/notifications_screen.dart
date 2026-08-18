import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/app_notification.dart';
import '../../services/mock_api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = MockApiService();
  List<AppNotification> items = const [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final data = await _service.fetchNotifications();
    if (!mounted) return;
    setState(() {
      items = data;
      loading = false;
    });
  }

  void _markRead(int index) {
    setState(() {
      items[index] = items[index].copyWith(isRead: true);
    });
  }

  IconData _icon(NotificationType type) => switch (type) {
        NotificationType.weather => Icons.cloud_outlined,
        NotificationType.crop => Icons.eco_outlined,
        NotificationType.market => Icons.trending_up_rounded,
        NotificationType.system => Icons.info_outline_rounded,
      };

  Color _color(NotificationType type) => switch (type) {
        NotificationType.weather => AppColors.info,
        NotificationType.crop => AppColors.primary,
        NotificationType.market => AppColors.warning,
        NotificationType.system => AppColors.secondary,
      };

  @override
  Widget build(BuildContext context) {
    final unread = items.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          unread > 0 ? 'Notifications ($unread)' : 'Notifications',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: items.isEmpty
                ? null
                : () => setState(() {
                      items = [
                        for (final item in items) item.copyWith(isRead: true),
                      ];
                    }),
            icon: const Icon(Icons.done_all_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : items.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 200),
                      Center(child: Text('You are all caught up.')),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 30),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 7),
                    itemBuilder: (context, index) {
                      final n = items[index];
                      final color = _color(n.type);

                      return Card(
                        color: n.isRead ? null : color.withValues(alpha: .06),
                        child: ListTile(
                          onTap: () => _markRead(index),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: .11),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(_icon(n.type), color: color),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  n.title,
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                              if (!n.isRead)
                                const SizedBox(
                                  width: 8,
                                  height: 8,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${n.message}\n${_relative(n.createdAt)}',
                              style: const TextStyle(height: 1.4),
                            ),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  String _relative(DateTime time) {
    final delta = DateTime.now().difference(time);
    if (delta.inMinutes < 60) return '${delta.inMinutes}m ago';
    if (delta.inHours < 24) return '${delta.inHours}h ago';
    return '${delta.inDays}d ago';
  }
}
