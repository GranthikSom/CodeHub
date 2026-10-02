import 'package:flutter/material.dart';

import '../models/repository_model.dart';
import '../widgets/branches_view.dart';
import '../widgets/code_browser_view.dart';
import '../widgets/git_object_dag_view.dart';
import '../widgets/issues_view.dart';
import '../widgets/permissions_view.dart';
import '../widgets/pull_requests_view.dart';
import '../widgets/repo_tab_views.dart';
import '../widgets/repository_network_view.dart';

class RepositoryDetailScreen extends StatefulWidget {
  final String repoName;
  final String owner;
  final CodeRepository? repository;
  final int initialTabIndex;

  const RepositoryDetailScreen({
    super.key,
    required this.repoName,
    required this.owner,
    this.repository,
    this.initialTabIndex = 0,
  });

  @override
  State<RepositoryDetailScreen> createState() => _RepositoryDetailScreenState();
}

class _RepositoryDetailScreenState extends State<RepositoryDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late bool _isPinned;
  late bool _isStarred;
  late int _starsCount;
  int _watchersCount = 15;
  int _forksCount = 4;
  String _watchStatus = 'Participating and @mentions';

  final List<Map<String, dynamic>> _tabsData = [
    {'title': 'Code', 'icon': Icons.code, 'badge': null},
    {'title': 'Issues', 'icon': Icons.adjust_rounded, 'badge': '18'},
    {'title': 'Pull requests', 'icon': Icons.call_split_rounded, 'badge': '3'},
    {'title': 'Actions', 'icon': Icons.play_circle_outline_rounded, 'badge': null},
    {'title': 'Projects', 'icon': Icons.table_chart_outlined, 'badge': null},
    {'title': 'Security', 'icon': Icons.security_outlined, 'badge': null},
    {'title': 'Insights', 'icon': Icons.insights_rounded, 'badge': null},
    {'title': 'Commits', 'icon': Icons.history_rounded, 'badge': '24'},
    {'title': 'Branches', 'icon': Icons.alt_route_rounded, 'badge': '3'},
    {'title': 'Swarm Network', 'icon': Icons.wifi_tethering_rounded, 'badge': 'Live', 'isLive': true},
    {'title': 'Settings (Access)', 'icon': Icons.settings_outlined, 'badge': null},
  ];

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialTabIndex.clamp(0, _tabsData.length - 1);
    _tabController = TabController(
      length: _tabsData.length,
      vsync: this,
      initialIndex: initialIndex,
    );

    _isPinned = widget.repository?.isPinnedLocally ?? true;
    _isStarred = false;
    _starsCount = widget.repository?.stars ?? 42;
    _forksCount = widget.repository?.forks ?? 4;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _togglePin() {
    setState(() {
      _isPinned = !_isPinned;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isPinned
              ? 'Repository pinned to local node. Serving 3 peers over Kademlia DHT.'
              : 'Repository unpinned. Cached chunks marked for 30-day GC grace period.',
        ),
        backgroundColor: _isPinned ? const Color(0xFF238636) : const Color(0xFF6E7681),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _toggleStar() {
    setState(() {
      _isStarred = !_isStarred;
      _starsCount += _isStarred ? 1 : -1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isStarred
              ? 'Starred ${widget.owner}/${widget.repoName}!'
              : 'Unstarred ${widget.owner}/${widget.repoName}.',
        ),
        backgroundColor: _isStarred ? const Color(0xFF1F6FEB) : const Color(0xFF6E7681),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showForkDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
          ),
          title: const Text('Create a new fork', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A fork is a copy of a repository. Forking a repository allows you to freely experiment with changes without affecting the original decentralized project.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.fork_right_outlined, size: 18, color: Color(0xFF58A6FF)),
                    const SizedBox(width: 8),
                    Text(
                      'cyberduck / ${widget.repoName}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _forksCount += 1;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Fork created in your personal namespace: cyberduck/${widget.repoName}'),
                    backgroundColor: const Color(0xFF238636),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF238636),
                foregroundColor: Colors.white,
              ),
              child: const Text('Create fork'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPrivate = widget.repository?.isPrivate ?? false;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // 1. GitHub Top Repository Header & Actions Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FA),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Back Button, Breadcrumb Title (owner / repo), Pill Badge, and Action Buttons
                  Row(
                    children: [
                      // Back Button
                      IconButton(
                        icon: const Icon(Icons.arrow_back, size: 20),
                        tooltip: 'Back to repositories',
                        onPressed: () => Navigator.of(context).pop(),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),

                      // Repo Bookmark Icon
                      Icon(
                        Icons.bookmark_outline,
                        size: 18,
                        color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),

                      // Owner Link
                      InkWell(
                        onTap: () {},
                        child: Text(
                          widget.owner,
                          style: TextStyle(
                            fontSize: 18,
                            color: isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      Text(
                        ' / ',
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                        ),
                      ),
                      // Repo Name (Bold)
                      InkWell(
                        onTap: () {
                          _tabController.animateTo(0);
                        },
                        child: Text(
                          widget.repoName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Public / Private Pill Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          isPrivate ? 'Private' : 'Public',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Top Right Action Buttons (GitHub Style)
                      // 1. Pin / Seed Button (CodeHub P2P Highlight)
                      OutlinedButton.icon(
                        onPressed: _togglePin,
                        icon: Icon(
                          _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                          size: 14,
                          color: _isPinned ? const Color(0xFF3FB950) : null,
                        ),
                        label: Text(
                          _isPinned ? 'Pinned (3 peers)' : 'Pin / Seed',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _isPinned ? const Color(0xFF3FB950) : null,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _isPinned
                              ? (isDark ? const Color(0xFF238636).withValues(alpha: 0.15) : Colors.green.shade50)
                              : (isDark ? const Color(0xFF21262D) : Colors.white),
                          foregroundColor: isDark ? const Color(0xFFC9D1D9) : Colors.black87,
                          side: BorderSide(
                            color: _isPinned
                                ? const Color(0xFF238636)
                                : (isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 2. Watch Button with Dropdown
                      PopupMenuButton<String>(
                        initialValue: _watchStatus,
                        onSelected: (val) {
                          setState(() {
                            if (_watchStatus != val) {
                              if (val == 'All Activity') _watchersCount += 1;
                              if (val == 'Ignore' && _watchStatus != 'Ignore') _watchersCount = (_watchersCount - 1).clamp(0, 9999);
                            }
                            _watchStatus = val;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Watch status updated to: $val'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'Participating and @mentions',
                            child: Text('Participating and @mentions'),
                          ),
                          const PopupMenuItem(
                            value: 'All Activity',
                            child: Text('All Activity'),
                          ),
                          const PopupMenuItem(
                            value: 'Ignore',
                            child: Text('Ignore'),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF21262D) : Colors.white,
                            border: Border.all(
                              color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.remove_red_eye_outlined,
                                size: 14,
                                color: isDark ? const Color(0xFFC9D1D9) : Colors.black87,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Watch',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFFC9D1D9) : Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF30363D) : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$_watchersCount',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down, size: 14),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 3. Fork Button
                      OutlinedButton(
                        onPressed: _showForkDialog,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF21262D) : Colors.white,
                          foregroundColor: isDark ? const Color(0xFFC9D1D9) : Colors.black87,
                          side: BorderSide(
                            color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.fork_right_outlined, size: 14),
                            const SizedBox(width: 6),
                            const Text(
                              'Fork',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF30363D) : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$_forksCount',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 4. Star Button (Interactive Toggle)
                      OutlinedButton(
                        onPressed: _toggleStar,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _isStarred
                              ? (isDark ? const Color(0xFF1F6FEB).withValues(alpha: 0.2) : Colors.blue.shade50)
                              : (isDark ? const Color(0xFF21262D) : Colors.white),
                          foregroundColor: isDark ? const Color(0xFFC9D1D9) : Colors.black87,
                          side: BorderSide(
                            color: _isStarred
                                ? const Color(0xFF58A6FF)
                                : (isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isStarred ? Icons.star : Icons.star_border,
                              size: 15,
                              color: _isStarred ? Colors.amber : null,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isStarred ? 'Starred' : 'Star',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _isStarred ? const Color(0xFF58A6FF) : null,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF30363D) : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$_starsCount',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Row 2: GitHub Repository Sub-navigation TabBar
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: isDark ? Colors.white : Colors.black87,
                    unselectedLabelColor: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                    indicatorColor: const Color(0xFFF78166), // Signature GitHub tab underline
                    indicatorWeight: 2,
                    dividerColor: Colors.transparent,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 14),
                    tabs: _tabsData.map((tab) {
                      final title = tab['title'] as String;
                      final icon = tab['icon'] as IconData;
                      final badge = tab['badge'] as String?;
                      final isLive = tab['isLive'] == true;

                      return Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 16),
                            const SizedBox(width: 6),
                            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            if (badge != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isLive
                                      ? const Color(0xFF238636).withValues(alpha: 0.2)
                                      : (isDark ? const Color(0xFF30363D) : Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(10),
                                  border: isLive
                                      ? Border.all(color: const Color(0xFF3FB950).withValues(alpha: 0.5))
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isLive) ...[
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF3FB950),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      badge,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isLive
                                            ? const Color(0xFF3FB950)
                                            : (isDark ? const Color(0xFFC9D1D9) : Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // 2. Tab Bar Views Body
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 1. Code View (Full GitHub Code tab)
                  CodeBrowserView(
                    repoName: widget.repoName,
                    owner: widget.owner,
                    repository: widget.repository,
                    onSelectTab: (idx) => _tabController.animateTo(idx),
                  ),

                  // 2. Issues Tracker
                  IssuesView(repoName: widget.repoName, owner: widget.owner),

                  // 3. Pull Requests
                  PullRequestsView(repoName: widget.repoName, owner: widget.owner),

                  // 4. Actions Workflows
                  ActionsView(repoName: widget.repoName, owner: widget.owner),

                  // 5. Projects Kanban Board
                  ProjectsView(repoName: widget.repoName, owner: widget.owner),

                  // 6. Security Overview
                  SecurityView(repoName: widget.repoName, owner: widget.owner),

                  // 7. Insights Metrics
                  InsightsView(repoName: widget.repoName, owner: widget.owner),

                  // 8. Commits & Git DAG
                  const GitObjectDagView(),

                  // 9. Branches & Tags
                  BranchesView(repoName: widget.repoName, owner: widget.owner),

                  // 10. Swarm Network & Telemetry
                  RepositoryNetworkView(repoName: widget.repoName),

                  // 11. Settings ➔ Access & Permissions
                  PermissionsView(repoName: widget.repoName, owner: widget.owner),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
