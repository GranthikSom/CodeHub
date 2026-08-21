import 'package:flutter/material.dart';
import '../models/p2p_node.dart';
import '../services/codehub_state.dart';

class NetworkTopologyView extends StatelessWidget {
  final CodeHubState state;

  const NetworkTopologyView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner explanation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBC8CFF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.lan_outlined, color: Color(0xFFBC8CFF), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'P2P Swarm Topology & Discovery Relay',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        'Central Control Server handles user auth & peer discovery. Repository block data replicates directly between P2P node devices.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Grid of Node Cards
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: state.nodes.length,
            itemBuilder: (context, index) {
              final node = state.nodes[index];
              return _buildNodeCard(context, node, isDark);
            },
          ),
          const SizedBox(height: 24),

          // Peer Health & Device Reputation System Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : Colors.white,
              borderRadius: BorderRadius.circular(10),
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
                            color: const Color(0xFFD29922).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.star_outline, color: Color(0xFFD29922), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Peer Health & Device Reputation System',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              'CodeHub dynamically measures peer reliability to prefer high-performing seeders for chunk replication.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF238636).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF3FB950)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified, size: 14, color: Color(0xFF3FB950)),
                          SizedBox(width: 6),
                          Text(
                            'Prefer Reliable Peers: ACTIVE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3FB950),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Reputation Cards for Swarm Peers
                ...state.nodes.where((n) => !n.isLocal && n.type != NodeType.controlRelay).map((node) {
                  return _buildPeerReputationCard(node, isDark);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeerReputationCard(P2PNode node, bool isDark) {
    final stars = '★' * node.starRating + '☆' * (5 - node.starRating);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF21262D) : Colors.grey.shade300,
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
                  Text(
                    node.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    stars,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFD29922),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              if (node.isPreferred)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3FB950).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF3FB950), width: 0.8),
                  ),
                  child: const Text(
                    'PREFERRED PEER',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3FB950),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Exact Spec Metrics Grid (Uptime, Availability, Successful transfers, Failed transfers, Average latency)
          Row(
            children: [
              _buildReputationStat('Uptime:', '${node.uptimePercent}%', isDark),
              _buildReputationStat('Availability:', '${node.availabilityPercent}%', isDark),
              _buildReputationStat('Successful transfers:', '${node.successfulTransfers}', isDark),
              _buildReputationStat('Failed transfers:', '${node.failedTransfers}', isDark),
              _buildReputationStat('Average latency:', '${node.pingMs > 0 ? node.pingMs : 42} ms', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReputationStat(String label, String value, bool isDark) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeCard(BuildContext context, P2PNode node, bool isDark) {
    Color typeColor;
    String typeTitle;

    switch (node.type) {
      case NodeType.localNode:
        typeColor = const Color(0xFF3FB950);
        typeTitle = 'Local Device';
        break;
      case NodeType.seedNode:
        typeColor = const Color(0xFF58A6FF);
        typeTitle = 'High-Capacity Seed Node';
        break;
      case NodeType.peerDevice:
        typeColor = const Color(0xFFBC8CFF);
        typeTitle = 'Peer Device';
        break;
      case NodeType.controlRelay:
        typeColor = const Color(0xFFD29922);
        typeTitle = 'Control Relay Server';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: node.isLocal
              ? const Color(0xFF238636)
              : (isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
          width: node.isLocal ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    node.type == NodeType.localNode
                        ? Icons.laptop_mac
                        : (node.type == NodeType.controlRelay ? Icons.dns : Icons.dns_outlined),
                    color: typeColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    node.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: typeColor, width: 0.8),
                ),
                child: Text(
                  typeTitle,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: typeColor,
                  ),
                ),
              ),
            ],
          ),

          Row(
            children: [
              Text(
                'Node ID: ',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                ),
              ),
              Expanded(
                child: Text(
                  node.id,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: isDark ? const Color(0xFF58A6FF) : Colors.blue.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'IP: ${node.ipAddress}',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.network_ping, size: 12, color: typeColor),
                  const SizedBox(width: 4),
                  Text(
                    '${node.pingMs} ms ping',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (node.type != NodeType.controlRelay)
            Row(
              children: [
                Icon(Icons.storage_outlined, size: 12, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${node.storageUsedGb} GB / ${node.storageAllocatedGb} GB Stored',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${node.pinnedRepoIds.length} Pinned Repos',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3FB950),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
