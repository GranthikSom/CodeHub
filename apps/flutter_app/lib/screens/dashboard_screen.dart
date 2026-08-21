import 'package:flutter/material.dart';

import '../dashboard/landing_page.dart';
import '../services/codehub_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  late CodeHubState _state;

  @override
  void initState() {
    super.initState();
    _state = CodeHubState();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _state,
      builder: (context, _) {
        return Scaffold(
          body: Row(
            children: [
              // Left Navigation Rail
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                labelType: NavigationRailLabelType.selected,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.hub, color: Colors.blueAccent, size: 28),
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.folder),
                    selectedIcon: Icon(Icons.folder_special, color: Colors.blueAccent),
                    label: Text('My Repos'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.explore_outlined),
                    selectedIcon: Icon(Icons.explore, color: Colors.blueAccent),
                    label: Text('Explore'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.timeline_outlined),
                    selectedIcon: Icon(Icons.timeline, color: Colors.blueAccent),
                    label: Text('Activity'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.notifications_outlined),
                    selectedIcon: Icon(Icons.notifications, color: Colors.blueAccent),
                    label: Text('Alerts'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings, color: Colors.blueAccent),
                    label: Text('Settings'),
                  ),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1),

              // Main Active Section View
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    // 0. My Repositories & Swarm Overview
                    Landingpage(state: _state),

                    // 1. Explore Catalog
                    _buildPlaceholderSection(
                      context,
                      title: 'Explore Global P2P Catalog',
                      icon: Icons.explore,
                      subtitle: 'Discover decentralized repositories seeded across participating swarm nodes',
                    ),

                    // 2. Activity Feed
                    _buildPlaceholderSection(
                      context,
                      title: 'Live Activity Feed',
                      icon: Icons.timeline,
                      subtitle: 'Gossipsub pub/sub swarm commit announcements and replication events',
                    ),

                    // 3. Notifications
                    _buildPlaceholderSection(
                      context,
                      title: 'System Notifications',
                      icon: Icons.notifications,
                      subtitle: 'Your local node is actively seeding 2 repositories to 14 peers',
                    ),

                    // 4. Settings
                    _buildSettingsSection(context),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildPlaceholderSection(
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

  Widget _buildSettingsSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        Text(
          'Settings & Preferences',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          title: const Text('Dark Mode Theme'),
          subtitle: const Text('Toggle between dark and light UI color schemes'),
          value: _state.themeMode == ThemeMode.dark,
          onChanged: (val) {
            _state.toggleThemeMode();
          },
        ),
        const Divider(),
        ListTile(
          title: const Text('P2P Bootstrap Relay Node'),
          subtitle: const Text('/dns4/p2p.codehub.com/tcp/4001/p2p/12D3KooWControlRelayServer'),
          trailing: const Icon(Icons.edit_outlined),
        ),
        const Divider(),
        ListTile(
          title: const Text('Local Storage Quota Limit'),
          subtitle: const Text('20 GB Allocated (72% Used)'),
          trailing: const Icon(Icons.storage),
        ),
      ],
    );
  }
}
