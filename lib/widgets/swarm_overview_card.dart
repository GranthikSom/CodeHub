import 'package:flutter/material.dart';
import '../services/codehub_state.dart';
import '../models/p2p_node.dart';

class SwarmOverviewCard extends StatelessWidget {
  final CodeHubState state;

  const SwarmOverviewCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalNodes = state.nodes.length;
    final seeders = state.nodes.where((n) => n.type == NodeType.seedNode || n.type == NodeType.peerDevice).length;
    final totalPinned = state.repositories.where((r) => r.isPinnedLocally).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF58A6FF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.hub_outlined,
                      color: Color(0xFF58A6FF),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'P2P Git Replication Architecture',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        'Repositories are content-addressed DAGs stored across peer devices rather than a central monolith server.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => state.setActiveTab(ActiveTab.networkTopology),
                icon: const Icon(Icons.share_outlined, size: 16),
                label: const Text('View Node Swarm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF21262D) : Colors.blue.shade50,
                  foregroundColor: isDark ? const Color(0xFF58A6FF) : Colors.blue.shade900,
                  elevation: 0,
                  side: BorderSide(color: isDark ? const Color(0xFF30363D) : Colors.blue.shade200),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stat Cards Grid
          Row(
            children: [
              Expanded(
                child: _buildStatTile(
                  context: context,
                  title: 'Participating Swarm Nodes',
                  value: '$totalNodes Nodes',
                  subtitle: '$seeders Seeding Devices + 1 Relay',
                  icon: Icons.devices_outlined,
                  color: const Color(0xFF58A6FF),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatTile(
                  context: context,
                  title: 'Git Object Blobs Replicated',
                  value: '${state.totalSwarmObjects}',
                  subtitle: 'Immutable SHA-256 DAG Hashes',
                  icon: Icons.account_tree_outlined,
                  color: const Color(0xFFBC8CFF),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatTile(
                  context: context,
                  title: 'Local Node Seeding Quota',
                  value: '${state.localNode.storageUsedGb} GB / ${state.localNode.storageAllocatedGb} GB',
                  subtitle: '$totalPinned Repositories Pinned',
                  icon: Icons.push_pin_outlined,
                  color: const Color(0xFF3FB950),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatTile(
                  context: context,
                  title: 'Control Plane Discovery',
                  value: 'Active Relay',
                  subtitle: 'Auth & Repo Indexing Synced',
                  icon: Icons.cloud_done_outlined,
                  color: const Color(0xFFD29922),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Visual Node Topology Strip
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: state.nodes.map((node) {
                final isLocal = node.isLocal;
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isLocal
                            ? const Color(0xFF238636).withValues(alpha: 0.2)
                            : (isDark ? const Color(0xFF161B22) : Colors.white),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isLocal
                              ? const Color(0xFF3FB950)
                              : (isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            node.type == NodeType.localNode
                                ? Icons.laptop_chromebook
                                : (node.type == NodeType.controlRelay
                                    ? Icons.dns
                                    : Icons.dns_outlined),
                            size: 16,
                            color: isLocal
                                ? const Color(0xFF3FB950)
                                : (isDark ? const Color(0xFF58A6FF) : Colors.blue),
                          ),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${node.name.split(' ').first} ${node.name.contains('(') ? node.name.substring(node.name.indexOf('(')) : ''}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                '${node.pingMs} ms • ${node.pinnedRepoIds.length} Repos',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (node != state.nodes.last) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.swap_horiz_rounded,
                        size: 16,
                        color: isDark ? const Color(0xFF30363D) : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF21262D) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
