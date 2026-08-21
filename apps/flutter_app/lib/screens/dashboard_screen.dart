import 'package:flutter/material.dart';

import '../dashboard/landing_page.dart';
import '../services/codehub_state.dart';
import 'explore_screen.dart';
import 'activity_feed_screen.dart';
import 'notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  final CodeHubState? state;
  const DashboardScreen({super.key, this.state});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  late CodeHubState _state;
  bool _isOwnedState = false;

  @override
  void initState() {
    super.initState();
    if (widget.state != null) {
      _state = widget.state!;
      _isOwnedState = false;
    } else {
      _state = CodeHubState();
      _isOwnedState = true;
    }
  }

  @override
  void dispose() {
    if (_isOwnedState) {
      _state.dispose();
    }
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
                    ExploreScreen(state: _state),

                    // 2. Activity Feed
                    ActivityFeedScreen(state: _state),

                    // 3. System Notifications & Alerts
                    NotificationsScreen(state: _state),

                    // 4. Settings & Storage Control
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
