import 'package:flutter/material.dart';

import '../dashboard/landing_page.dart';
import '../services/codehub_state.dart';
import 'auth_screen.dart';
import 'explore_screen.dart';
import 'pull_requests_screen.dart';
import 'activity_feed_screen.dart';
import 'issues_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';

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
        if (!_state.api.isAuthenticated) {
          return Scaffold(
            backgroundColor: const Color(0xFF0D1117),
            body: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF30363D)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_outline_rounded, size: 48, color: Colors.redAccent),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Authentication Required',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Access to the CodeHub P2P Dashboard is restricted. Please sign in or register your identity key to proceed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => AuthScreen(state: _state)),
                          );
                        },
                        icon: const Icon(Icons.login, size: 18),
                        label: const Text('Sign In / Register Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

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
                    icon: Icon(Icons.call_merge_outlined),
                    selectedIcon: Icon(Icons.call_merge_rounded, color: Colors.blueAccent),
                    label: Text('Pull Requests'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.bug_report_outlined),
                    selectedIcon: Icon(Icons.bug_report, color: Colors.blueAccent),
                    label: Text('Issues'),
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

                    // 2. Pull Requests Management
                    PullRequestsScreen(state: _state),

                    // 3. Issues Tracker
                    IssuesScreen(state: _state),

                    // 4. Activity Feed
                    ActivityFeedScreen(state: _state),

                    // 5. System Notifications & Alerts
                    NotificationsScreen(state: _state),

                    // 6. Settings & Storage Control
                    SettingsScreen(state: _state),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
