import 'package:flutter/material.dart';

import '../widgets/branches_view.dart';
import '../widgets/code_browser_view.dart';
import '../widgets/git_object_dag_view.dart';
import '../widgets/issues_view.dart';
import '../widgets/pull_requests_view.dart';
import '../widgets/repo_tab_views.dart';
import '../widgets/repository_network_view.dart';

class RepositoryDetailScreen extends StatefulWidget {
  final String repoName;
  final String owner;

  const RepositoryDetailScreen({
    super.key,
    required this.repoName,
    required this.owner,
  });

  @override
  State<RepositoryDetailScreen> createState() => _RepositoryDetailScreenState();
}

class _RepositoryDetailScreenState extends State<RepositoryDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = [
    'Code',
    'Issues',
    'Pull Requests',
    'Actions',
    'Projects',
    'Security',
    'Insights',
    'Commits',
    'Branches',
    'Swarm Network',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.folder_special, color: Colors.blueAccent),
            const SizedBox(width: 10),
            Text('${widget.owner} / ${widget.repoName}'),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
          indicatorColor: Colors.blueAccent,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Code View
          CodeBrowserView(repoName: widget.repoName, owner: widget.owner),

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
        ],
      ),
    );
  }
}
