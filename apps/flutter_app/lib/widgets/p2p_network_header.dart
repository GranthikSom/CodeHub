import 'package:flutter/material.dart';
import '../services/codehub_state.dart';

class P2PNetworkHeader extends StatelessWidget {
  final CodeHubState state;

  const P2PNetworkHeader({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Logo & Platform Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF58A6FF), Color(0xFFBC8CFF)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.hub_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'CodeHub',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF238636).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF238636), width: 1),
                            ),
                            child: const Text(
                              'DECENTRALIZED P2P',
                              style: TextStyle(
                                color: Color(0xFF3FB950),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Content-Addressed Git Swarm Network',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 32),

              // Search Bar
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
                    ),
                  ),
                  child: TextField(
                    onChanged: (value) => state.setSearchQuery(value),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search repositories, SHA-256 object hashes, peer Node IDs...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade500,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade500,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(top: 8),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 24),

              // P2P Live Telemetry Indicator Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3FB950),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'P2P Swarm Online',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.arrow_upward_rounded, size: 14, color: const Color(0xFF58A6FF)),
                    Text(
                      '${state.currentUploadMbps} MB/s',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF58A6FF), fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_downward_rounded, size: 14, color: const Color(0xFFBC8CFF)),
                    Text(
                      '${state.currentDownloadMbps} MB/s',
                      style: const TextStyle(fontSize: 11, color: Color(0xFFBC8CFF), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Theme Mode Toggle Button (Light/Dark)
              Tooltip(
                message: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                child: InkWell(
                  onTap: () => state.toggleThemeMode(),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
                      ),
                    ),
                    child: Icon(
                      isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                      size: 18,
                      color: isDark ? const Color(0xFFD29922) : Colors.indigo.shade700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tab Navigation Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTabButton(
                  context: context,
                  tab: ActiveTab.overview,
                  label: 'Swarm Overview',
                  icon: Icons.dashboard_outlined,
                  isSelected: state.activeTab == ActiveTab.overview,
                  badgeText: '${state.repositories.length} Repos',
                ),
                const SizedBox(width: 8),
                _buildTabButton(
                  context: context,
                  tab: ActiveTab.repos,
                  label: 'Repositories & Objects',
                  icon: Icons.folder_copy_outlined,
                  isSelected: state.activeTab == ActiveTab.repos,
                ),
                const SizedBox(width: 8),
                _buildTabButton(
                  context: context,
                  tab: ActiveTab.dagExplorer,
                  label: 'Git DAG Explorer',
                  icon: Icons.account_tree_outlined,
                  isSelected: state.activeTab == ActiveTab.dagExplorer,
                  badgeText: 'SHA-256 DAG',
                ),
                const SizedBox(width: 8),
                _buildTabButton(
                  context: context,
                  tab: ActiveTab.networkTopology,
                  label: 'P2P Network Topology',
                  icon: Icons.lan_outlined,
                  isSelected: state.activeTab == ActiveTab.networkTopology,
                  badgeText: '${state.nodes.length} Nodes',
                ),
                const SizedBox(width: 8),
                _buildTabButton(
                  context: context,
                  tab: ActiveTab.storageSettings,
                  label: 'Local Node Pinning',
                  icon: Icons.push_pin_outlined,
                  isSelected: state.activeTab == ActiveTab.storageSettings,
                  badgeText: '${state.localNode.storageUsedGb} GB',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required BuildContext context,
    required ActiveTab tab,
    required String label,
    required IconData icon,
    required bool isSelected,
    String? badgeText,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => state.setActiveTab(tab),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF21262D) : Colors.blue.shade50)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? (isDark ? const Color(0xFF58A6FF) : Colors.blue)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? (isDark ? const Color(0xFF58A6FF) : Colors.blue)
                  : (isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? (isDark ? Colors.white : Colors.blue.shade900)
                    : (isDark ? const Color(0xFF8B949E) : Colors.grey.shade700),
              ),
            ),
            if (badgeText != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF30363D) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
