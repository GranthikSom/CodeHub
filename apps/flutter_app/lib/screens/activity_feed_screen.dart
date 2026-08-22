import 'package:flutter/material.dart';
import '../services/codehub_state.dart';
import '../widgets/activity_feed_card.dart';

class ActivityFeedScreen extends StatefulWidget {
  final CodeHubState state;

  const ActivityFeedScreen({super.key, required this.state});

  @override
  State<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen> {
  ActivityCategory _selectedCategory = ActivityCategory.all;

  final List<ActivityItem> _allActivities = const [
    ActivityItem(
      id: 'act-1',
      category: ActivityCategory.pushes,
      typeLabel: 'Pushes',
      title: 'Soham pushed 3 commits',
      repoOrTarget: 'codehub-core-p2p',
      timeAgo: '2 minutes ago',
      shaOrMeta: 'main..3a4f89',
      detail: 'feat: implement delta sync calculation & commit DAG visualizer',
    ),
    ActivityItem(
      id: 'act-2',
      category: ActivityCategory.prs,
      typeLabel: 'PRs',
      title: 'PR #24 opened by SohamMondal',
      repoOrTarget: 'flutter-dag-visualizer',
      timeAgo: '8 minutes ago',
      shaOrMeta: 'PR #24',
      detail: 'feat: add interactive DAG node graph view with live zooming',
    ),
    ActivityItem(
      id: 'act-3',
      category: ActivityCategory.replication,
      typeLabel: 'Replication',
      title: 'Repository replicated to Node #42',
      repoOrTarget: 'codehub-core-p2p',
      timeAgo: '12 minutes ago',
      shaOrMeta: 'Node #42',
      detail: '380 Git Blobs (42.1 MB) synchronized with 9-replica redundancy target',
    ),
    ActivityItem(
      id: 'act-4',
      category: ActivityCategory.peer,
      typeLabel: 'Peer Events',
      title: 'New peer joined your swarm',
      repoOrTarget: 'Peer: 12D3KooWControlRelayServer',
      timeAgo: '15 minutes ago',
      shaOrMeta: 'libp2p DHT',
      detail: 'Connected via Noise TLS encrypted transport on port 4001',
    ),
    ActivityItem(
      id: 'act-5',
      category: ActivityCategory.issues,
      typeLabel: 'Issues',
      title: 'Issue #18 closed',
      repoOrTarget: 'kademlia-dht-relay',
      timeAgo: '21 minutes ago',
      shaOrMeta: 'Issue #18',
      detail: 'Resolved routing table staleness on network reconnects',
    ),
    ActivityItem(
      id: 'act-6',
      category: ActivityCategory.commits,
      typeLabel: 'Commits',
      title: 'Granthik committed 8f2a1b9c',
      repoOrTarget: 'codehub-core-p2p',
      timeAgo: '34 minutes ago',
      shaOrMeta: '8f2a1b9c',
      detail: 'security: Argon2id zero-plain-password identity verification',
    ),
    ActivityItem(
      id: 'act-7',
      category: ActivityCategory.repo,
      typeLabel: 'Repository',
      title: 'New repository flutter-dag-visualizer created',
      repoOrTarget: 'flutter-dag-visualizer',
      timeAgo: '45 minutes ago',
      shaOrMeta: 'SHA-256 Catalog',
      detail: 'Initial root commit registered in global P2P content-addressed store',
    ),
    ActivityItem(
      id: 'act-8',
      category: ActivityCategory.replication,
      typeLabel: 'Replication',
      title: 'TokyoNodePeer completed 100% replication pin',
      repoOrTarget: 'codehub-core-p2p',
      timeAgo: '1 hour ago',
      shaOrMeta: 'Pin Target',
      detail: 'Seeding 14 active swarm peers over libp2p Gossipsub pub/sub channel',
    ),
  ];

  List<ActivityItem> get _filteredActivities {
    if (_selectedCategory == ActivityCategory.all) {
      return _allActivities;
    }
    return _allActivities.where((a) => a.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categoryTabs = [
      {'label': 'All Activity', 'cat': ActivityCategory.all, 'icon': Icons.timeline_rounded},
      {'label': 'Pushes', 'cat': ActivityCategory.pushes, 'icon': Icons.upload_rounded},
      {'label': 'Commits', 'cat': ActivityCategory.commits, 'icon': Icons.commit_rounded},
      {'label': 'PRs', 'cat': ActivityCategory.prs, 'icon': Icons.merge_type_rounded},
      {'label': 'Issues', 'cat': ActivityCategory.issues, 'icon': Icons.adjust_rounded},
      {'label': 'Repository', 'cat': ActivityCategory.repo, 'icon': Icons.folder_outlined},
      {'label': 'Peer Events', 'cat': ActivityCategory.peer, 'icon': Icons.hub_rounded},
      {'label': 'Replication', 'cat': ActivityCategory.replication, 'icon': Icons.cloud_sync_rounded},
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
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
                        'Swarm Activity Feed',
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
                    'What happened while you were away? Pushes, PRs, issues, replication & peer mesh updates.',
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
                      'Live Gossipsub Stream',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3FB950)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Category Filter Chips Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categoryTabs.map((tab) {
                final category = tab['cat'] as ActivityCategory;
                final isSelected = _selectedCategory == category;
                final icon = tab['icon'] as IconData;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    showCheckmark: false,
                    selected: isSelected,
                    avatar: Icon(
                      icon,
                      size: 16,
                      color: isSelected ? Colors.white : (isDark ? const Color(0xFF8B949E) : Colors.grey.shade700),
                    ),
                    label: Text(tab['label'] as String),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    ),
                    backgroundColor: isDark ? const Color(0xFF161B22) : Colors.grey.shade200,
                    selectedColor: const Color(0xFF2F81F7),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF2F81F7)
                          : (isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),

          // Feed List View
          Expanded(
            child: _filteredActivities.isEmpty
                ? Center(
                    child: Text(
                      'No events in this category yet.',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF8B949E) : Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredActivities.length,
                    itemBuilder: (context, index) {
                      return ActivityFeedCard(item: _filteredActivities[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
