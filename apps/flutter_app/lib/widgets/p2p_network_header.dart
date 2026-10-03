import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/codehub_state.dart';
import '../screens/auth_screen.dart';
import '../screens/profile_screen.dart';
import 'create_repository_dialog.dart';

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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
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

              // + New Repository Button
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
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('New Repo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),

              const SizedBox(width: 12),

              // User Profile & JWT Auth Account Button
              Builder(
                builder: (context) {
                  final isAuth = state.api.isAuthenticated;
                  final username = state.api.currentUsername ?? 'Developer';
                  final role = state.api.currentRole ?? 'developer';

                  if (!isAuth) {
                    return Tooltip(
                      message: 'Sign In / Register Account',
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => AuthScreen(state: state)),
                          );
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFF58A6FF),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.account_circle_outlined,
                                size: 18,
                                color: Color(0xFF58A6FF),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return Tooltip(
                    message: 'Authenticated as @$username ($role)',
                    child: InkWell(
                      onTap: () => _showUserProfileModal(context, state),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF161B22) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF238636)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 11,
                              backgroundColor: const Color(0xFF238636),
                              child: Text(
                                username.isNotEmpty ? username[0].toUpperCase() : 'U',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              username,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: role == 'admin' ? Colors.purple.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                role.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: role == 'admin' ? const Color(0xFFBC8CFF) : const Color(0xFF58A6FF),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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

void _showUserProfileModal(BuildContext context, CodeHubState state) {
  final profile = state.userProfile;
  final username = profile.username;
  final displayName = profile.displayName.isNotEmpty ? profile.displayName : username;
  final email = profile.email;
  final role = profile.role;
  final peerId = profile.peerId;
  final repoCount = state.repositories.length;
  final starredCount = state.repositories.where((r) => r.stars > 0).length;
  final pinnedCount = state.repositories.where((r) => r.isPinnedLocally).length;

  showDialog(
    context: context,
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      return Dialog(
        backgroundColor: Colors.transparent,
        alignment: Alignment.topRight,
        insetPadding: const EdgeInsets.only(top: 60, right: 24, bottom: 20),
        child: Container(
          width: 340,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. User Identity Header (GitHub Style)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF238636),
                      child: Text(
                        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  displayName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: role == 'admin' ? const Color(0xFF8957E5).withValues(alpha: 0.2) : const Color(0xFF1F6FEB).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  role.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: role == 'admin' ? const Color(0xFFBC8CFF) : const Color(0xFF58A6FF),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text('@$username', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600)),
                          Text(email, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade500), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Status line (GitHub style)
              if (profile.statusText.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE)),
                  ),
                  child: Row(
                    children: [
                      Text(profile.statusEmoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          profile.statusText,
                          style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFFC9D1D9) : Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 10),
              Divider(height: 1, color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE)),

              // 2. Navigation Actions List
              _buildMenuItem(
                icon: Icons.person_outline_rounded,
                title: 'Your profile',
                subtitle: 'View GitHub-style profile & contributions',
                onTap: () {
                  Navigator.pop(ctx);
                  state.navigateToProfile();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProfileScreen(state: state)),
                  );
                },
                isDark: isDark,
              ),
              _buildMenuItem(
                icon: Icons.source_outlined,
                title: 'Your repositories',
                badgeText: '$repoCount',
                onTap: () {
                  Navigator.pop(ctx);
                  state.setDashboardNavIndex(0);
                  state.setActiveTab(ActiveTab.repos);
                },
                isDark: isDark,
              ),
              _buildMenuItem(
                icon: Icons.star_outline_rounded,
                title: 'Your stars',
                badgeText: '$starredCount',
                onTap: () {
                  Navigator.pop(ctx);
                  state.navigateToProfile();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProfileScreen(state: state)),
                  );
                },
                isDark: isDark,
              ),
              _buildMenuItem(
                icon: Icons.pin_outlined,
                title: 'Your pinned swarm nodes',
                badgeText: '$pinnedCount',
                onTap: () {
                  Navigator.pop(ctx);
                  state.setDashboardNavIndex(0);
                  state.setActiveTab(ActiveTab.storageSettings);
                },
                isDark: isDark,
              ),

              Divider(height: 1, color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE)),

              // 3. Sovereign P2P Identity Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.key_rounded, size: 13, color: Color(0xFF58A6FF)),
                        const SizedBox(width: 6),
                        Text(
                          'Ed25519 Peer Identity',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: peerId));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ed25519 Peer Key copied to clipboard!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: const Icon(Icons.copy_rounded, size: 13, color: Color(0xFF58A6FF)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      peerId,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Color(0xFF7EE787)),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.verified, size: 13, color: Color(0xFF238636)),
                        const SizedBox(width: 6),
                        Text(
                          'Argon2id Session Active',
                          style: TextStyle(fontSize: 10, color: const Color(0xFF7EE787), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE)),

              // 4. Settings Item
              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  Navigator.pop(ctx);
                  state.setDashboardNavIndex(7);
                },
                isDark: isDark,
              ),

              Divider(height: 1, color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE)),

              // 5. Sign Out Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF85149),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () {
                        state.logoutUser();
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Signed out successfully'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.logout, size: 14),
                      label: const Text('Sign out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildMenuItem({
  required IconData icon,
  required String title,
  String? subtitle,
  String? badgeText,
  required VoidCallback onTap,
  required bool isDark,
}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFFC9D1D9) : const Color(0xFF24292F),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 10, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade500),
                  ),
              ],
            ),
          ),
          if (badgeText != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF21262D) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badgeText,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700),
              ),
            ),
        ],
      ),
    ),
  );
}
