import 'package:flutter/material.dart';
import '../services/codehub_state.dart';

class ActivityFeedScreen extends StatefulWidget {
  final CodeHubState state;

  const ActivityFeedScreen({super.key, required this.state});

  @override
  State<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen> {
  final List<Map<String, dynamic>> _activities = [
    {
      'type': 'commit',
      'user': 'GranthikSom',
      'repo': 'codehub-core-p2p',
      'action': 'pushed 3 commits to branch',
      'branch': 'main',
      'time': '10 mins ago',
      'sha': '8f2a1b9c',
      'msg': 'feat: implement delta sync calculation & commit DAG visualizer',
    },
    {
      'type': 'replication',
      'user': 'TokyoNodePeer',
      'repo': 'flutter-dag-visualizer',
      'action': 'completed 100% replication pin',
      'branch': 'main',
      'time': '25 mins ago',
      'sha': '3c19d4f2',
      'msg': 'Replicated 380 Git objects (42.1 MB) across 3 peer nodes',
    },
    {
      'type': 'pr',
      'user': 'SohamMondal',
      'repo': 'codehub-core-p2p',
      'action': 'opened pull request #201',
      'branch': 'feature/dht-routing',
      'time': '1 hour ago',
      'sha': '1a72e8b9',
      'msg': 'feat: implement Kademlia DHT peer discovery protocol',
    },
    {
      'type': 'star',
      'user': 'SanFranciscoPeer',
      'repo': 'codehub-core-p2p',
      'action': 'starred repository',
      'branch': 'main',
      'time': '2 hours ago',
      'sha': 'root_c4b0c2a',
      'msg': 'Added to pinned seeding favorites',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timeline_rounded, color: Color(0xFFBC8CFF), size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'Live P2P Swarm Activity Feed',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Real-time pub/sub replication announcements broadcast over libp2p Gossipsub channel.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF238636).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF238636)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.sensors, color: Color(0xFF3FB950), size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Gossipsub PubSub Active',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3FB950)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView.builder(
              itemCount: _activities.length,
              itemBuilder: (context, index) {
                final item = _activities[index];
                IconData icon;
                Color iconColor;

                switch (item['type']) {
                  case 'commit':
                    icon = Icons.commit;
                    iconColor = const Color(0xFF58A6FF);
                    break;
                  case 'replication':
                    icon = Icons.sync_rounded;
                    iconColor = const Color(0xFF3FB950);
                    break;
                  case 'pr':
                    icon = Icons.call_merge;
                    iconColor = const Color(0xFFBC8CFF);
                    break;
                  case 'star':
                  default:
                    icon = Icons.star_border_rounded;
                    iconColor = const Color(0xFFD29922);
                    break;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161B22) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: iconColor, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                children: [
                                  TextSpan(
                                    text: item['user'] as String,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: ' ${item['action']} '),
                                  TextSpan(
                                    text: item['repo'] as String,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF58A6FF)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF21262D) : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item['sha'] as String,
                                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold, color: Color(0xFF58A6FF)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item['msg'] as String,
                                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
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
