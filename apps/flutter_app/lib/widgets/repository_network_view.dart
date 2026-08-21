import 'package:flutter/material.dart';

class RepositoryNetworkView extends StatelessWidget {
  final String repoName;

  const RepositoryNetworkView({
    super.key,
    required this.repoName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card with Title & Swarm Health Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Repository Network',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Live P2P Replication Telemetry & Peer Health',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white60 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade400),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Health: Excellent',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Repository Health Card Section
          Card(
            elevation: 0,
            color: isDark ? const Color(0xFF1E2430) : Colors.grey[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey[300]!,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Repository Health',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF238636).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF3FB950)),
                        ),
                        child: const Text(
                          'Status: HEALTHY',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3FB950),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Health Progress ASCII Visualiser Bar: ██████████████████░░
                  Row(
                    children: [
                      Text(
                        'Health Score:  ',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        '██████████████████░░',
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF3FB950) : const Color(0xFF238636),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(90%)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Scores Grid: Replication 5/5, Peer availability 4/5, Integrity 5/5, Network 4/5
                  Row(
                    children: [
                      _buildHealthMetric('Replication', '5/5', const Color(0xFF3FB950), isDark),
                      _buildHealthMetric('Peer availability', '4/5', const Color(0xFF58A6FF), isDark),
                      _buildHealthMetric('Integrity', '5/5', const Color(0xFF3FB950), isDark),
                      _buildHealthMetric('Network', '4/5', const Color(0xFFBC8CFF), isDark),
                    ],
                  ),

                  // Single Replica Critical Alert Toggle / Demonstration Banner
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF85149).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF85149), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Color(0xFFF85149), size: 22),
                            const SizedBox(width: 8),
                            Text(
                              '⚠ CRITICAL REPLICATION ALERT',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFFFF7B72) : const Color(0xFFCF222E),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Only one copy of this repository currently exists on the network.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pin this repository to your node to add a secondary P2P replica and protect code integrity.',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Overview Quick Metrics (Peers, Size, Seeders, Leechers)
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context,
                  icon: Icons.hub,
                  iconColor: Colors.cyanAccent,
                  label: 'Connected Peers',
                  value: '14 Peers',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricTile(
                  context,
                  icon: Icons.sd_storage,
                  iconColor: Colors.amberAccent,
                  label: 'Repository Size',
                  value: '1.42 GB',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricTile(
                  context,
                  icon: Icons.upload_file,
                  iconColor: Colors.greenAccent,
                  label: 'Active Seeders',
                  value: '8 Nodes',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricTile(
                  context,
                  icon: Icons.download_for_offline,
                  iconColor: Colors.orangeAccent,
                  label: 'Active Leechers',
                  value: '3 Nodes',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Storage Allocation & Swarm Replication Meters Card
          Card(
            elevation: 0,
            color: isDark ? const Color(0xFF1E2430) : Colors.grey[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey[300]!,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Storage & Replication Meters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProgressMeter(
                    context,
                    label: 'Local Node Storage Allocation',
                    percent: 0.72,
                    percentText: '72%',
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 16),
                  _buildProgressMeter(
                    context,
                    label: 'P2P Swarm Object Replication',
                    percent: 0.78,
                    percentText: '78%',
                    color: Colors.purpleAccent,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Geographic Available Peers Distribution Card
          Card(
            elevation: 0,
            color: isDark ? const Color(0xFF1E2430) : Colors.grey[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey[300]!,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available Peers by Region',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        'Total Seeded: 1.44 GB',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildGeoPeerRow(context, region: 'India 🇮🇳', size: '650 MB', percent: 0.45, color: Colors.amberAccent),
                  const SizedBox(height: 12),
                  _buildGeoPeerRow(context, region: 'Germany 🇩🇪', size: '420 MB', percent: 0.29, color: Colors.lightBlueAccent),
                  const SizedBox(height: 12),
                  _buildGeoPeerRow(context, region: 'USA 🇺🇸', size: '310 MB', percent: 0.21, color: Colors.greenAccent),
                  const SizedBox(height: 12),
                  _buildGeoPeerRow(context, region: 'Singapore 🇸🇬', size: '60 MB', percent: 0.05, color: Colors.pinkAccent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2430) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressMeter(
    BuildContext context, {
    required String label,
    required double percent,
    required String percentText,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            Text(
              percentText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 10,
            backgroundColor: isDark ? Colors.black26 : Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildGeoPeerRow(
    BuildContext context, {
    required String region,
    required String size,
    required double percent,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            region,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: isDark ? Colors.black26 : Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 70,
          child: Text(
            size,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthMetric(String label, String score, Color color, bool isDark) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            score,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
