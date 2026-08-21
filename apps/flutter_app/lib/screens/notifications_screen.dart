import 'package:flutter/material.dart';
import '../services/codehub_state.dart';

class NotificationsScreen extends StatefulWidget {
  final CodeHubState state;

  const NotificationsScreen({super.key, required this.state});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'n1',
      'title': 'New Swarm Peer Connected',
      'body': 'Peer 12D3KooWControlRelayServer connected to your local node.',
      'type': 'peer',
      'read': false,
      'time': '15 mins ago',
    },
    {
      'id': 'n2',
      'title': 'Replication Quota Synced',
      'body': 'Your node successfully pinned codehub-core-p2p (2.45 GB).',
      'type': 'storage',
      'read': false,
      'time': '1 hour ago',
    },
    {
      'id': 'n3',
      'title': 'Pull Request Review Request',
      'body': 'SohamMondal requested your review on PR #201: Kademlia DHT.',
      'type': 'pr',
      'read': true,
      'time': '3 hours ago',
    },
    {
      'id': 'n4',
      'title': 'Garbage Collection Advisory',
      'body': '14 unreferenced block candidates ready for 30-day grace period cleanup.',
      'type': 'gc',
      'read': true,
      'time': '1 day ago',
    },
  ];

  void _markAllRead() {
    setState(() {
      for (var n in _notifications) {
        n['read'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unreadCount = _notifications.where((n) => !(n['read'] as bool)).length;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_rounded, color: Color(0xFF58A6FF), size: 28),
                  const SizedBox(width: 10),
                  Text(
                    'Notifications & System Alerts',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$unreadCount New',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _markAllRead,
                icon: const Icon(Icons.done_all, size: 16),
                label: const Text('Mark all as read'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final item = _notifications[index];
                final isRead = item['read'] as bool;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? (isRead ? const Color(0xFF161B22) : const Color(0xFF21262D))
                        : (isRead ? Colors.white : Colors.blue.shade50),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isRead
                          ? (isDark ? const Color(0xFF30363D) : Colors.grey.shade300)
                          : Colors.blueAccent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isRead ? Icons.mark_email_read_outlined : Icons.mark_email_unread_rounded,
                        color: isRead ? (isDark ? const Color(0xFF8B949E) : Colors.grey) : Colors.blueAccent,
                        size: 22,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] as String,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['body'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item['time'] as String,
                        style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
