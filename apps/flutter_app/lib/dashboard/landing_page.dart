import 'package:flutter/material.dart';
import '../services/codehub_state.dart';
import '../widgets/p2p_network_header.dart';
import '../widgets/swarm_overview_card.dart';
import '../widgets/repo_card.dart';
import '../widgets/git_object_dag_view.dart';
import '../widgets/local_storage_panel.dart';
import '../widgets/network_topology_view.dart';
import '../widgets/create_repository_dialog.dart';

class Landingpage extends StatelessWidget {
  final CodeHubState state;

  const Landingpage({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation & Swarm Header Bar
            P2PNetworkHeader(state: state),

            // Main Tab Body Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: _buildActiveTabContent(context, state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(BuildContext context, CodeHubState state) {
    switch (state.activeTab) {
      case ActiveTab.overview:
        return _buildOverviewTab(context, state);
      case ActiveTab.repos:
        return _buildReposTab(context, state);
      case ActiveTab.dagExplorer:
        return GitObjectDagView(state: state);
      case ActiveTab.networkTopology:
        return NetworkTopologyView(state: state);
      case ActiveTab.storageSettings:
        return LocalStoragePanel(state: state);
    }
  }

  Widget _buildOverviewTab(BuildContext context, CodeHubState state) {
    final filtered = state.filteredRepositories;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Swarm Telemetry & Node Architecture Header Banner
          SwarmOverviewCard(state: state),
          const SizedBox(height: 24),

          // Featured Repositories List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FEATURED DECENTRALIZED REPOSITORIES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${filtered.length} Repositories Synced to Swarm',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF58A6FF),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => CreateRepositoryDialog(state: state),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF238636),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text('New Repository', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (filtered.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B22) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Icon(Icons.folder_open_rounded, size: 48, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade500),
                  const SizedBox(height: 12),
                  Text(
                    'No repositories created yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Create your first sovereign Git repository to begin seeding across the P2P swarm.',
                    style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => CreateRepositoryDialog(state: state),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF238636),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Create Repository', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          else
            ...filtered.map((repo) => RepoCard(repo: repo, state: state)),
        ],
      ),
    );
  }

  Widget _buildReposTab(BuildContext context, CodeHubState state) {
    final filtered = state.filteredRepositories;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ALL REPOSITORIES IN P2P SWARM (${filtered.length})',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
              ),
            ),
            Row(
              children: [
                Text(
                  'Total Objects: ${state.totalSwarmObjects} Blobs/Trees',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: Color(0xFFBC8CFF),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => CreateRepositoryDialog(state: state),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF238636),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('New Repository', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.source_outlined, size: 48, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade500),
                      const SizedBox(height: 12),
                      Text(
                        'Swarm repository index is currently empty',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Initialize or clone a repository to connect with distributed peers.',
                        style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return RepoCard(repo: filtered[index], state: state);
                  },
                ),
        ),
      ],
    );
  }
}