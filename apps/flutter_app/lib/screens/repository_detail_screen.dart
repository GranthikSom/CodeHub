import 'package:flutter/material.dart';

import '../widgets/git_object_dag_view.dart';
import '../widgets/local_storage_panel.dart';
import '../widgets/repository_network_view.dart';

class RepositoryDetailScreen extends StatefulWidget {
  final String repoName;
  final String owner;

  const RepositoryDetailScreen({
    super.key,
    required this.repoName,
    required this.owner,
  });

  @override
  State<RepositoryDetailScreen> createState() => _RepositoryDetailScreenState();
}

class _RepositoryDetailScreenState extends State<RepositoryDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = [
    'Code',
    'Commits',
    'Branches',
    'Tags',
    'Issues',
    'Pull Requests',
    'Members',
    'Releases',
    'Network',
    'Storage',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this, initialIndex: 8); // Default to Network tab (USP)
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.folder_special, color: Colors.blueAccent),
            const SizedBox(width: 10),
            Text('${widget.owner} / ${widget.repoName}'),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
          indicatorColor: Colors.blueAccent,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Code View
          _buildPlaceholderTab(context, title: 'Code Explorer', icon: Icons.code, subtitle: 'lib/src/main.dart, Cargo.toml, README.md'),

          // 2. Commits (Git Object DAG View)
          const GitObjectDagView(),

          // 3. Branches
          _buildPlaceholderTab(context, title: 'Branches', icon: Icons.alt_route, subtitle: 'main (default), feature/dht-routing, release/v1.0'),

          // 4. Tags
          _buildPlaceholderTab(context, title: 'Tags & Signatures', icon: Icons.label_important, subtitle: 'v1.0.0, v0.9.4-beta'),

          // 5. Issues
          _buildPlaceholderTab(context, title: 'Issue Tracker', icon: Icons.bug_report, subtitle: '#101 Support QUIC multiplexing over libp2p'),

          // 6. Pull Requests
          _buildPlaceholderTab(context, title: 'Pull Requests', icon: Icons.merge_type, subtitle: '#201 feat: implement Kademlia DHT peer discovery'),

          // 7. Members & Permissions
          _buildPlaceholderTab(context, title: 'Repository Members', icon: Icons.people, subtitle: 'GranthikSom (Owner), SohamMondal (Maintainer)'),

          // 8. Releases
          _buildPlaceholderTab(context, title: 'Releases & Assets', icon: Icons.rocket_launch, subtitle: 'v1.0.0 Stable Release — SHA256: 8f2a1b9c...'),

          // 9. Network (USP Tab)
          RepositoryNetworkView(repoName: widget.repoName),

          // 10. Storage
          const LocalStoragePanel(),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.blueAccent),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
