import 'package:flutter/material.dart';

import '../widgets/branches_view.dart';
import '../widgets/code_browser_view.dart';
import '../widgets/git_object_dag_view.dart';
import '../widgets/issues_view.dart';
import '../widgets/local_storage_panel.dart';
import '../widgets/permissions_view.dart';
import '../widgets/pull_requests_view.dart';
import '../widgets/repository_network_view.dart';
import '../widgets/tags_view.dart';
import '../widgets/releases_view.dart';

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
    'Commits',
    'Branches',
    'Tags',
    'Issues',
    'Pull Requests',
    'Members',
    'Releases',
    'Network',
    'Storage',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this, initialIndex: 0); // Default to Code tab
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
          // 1. Code View (Phase 1 Code Browser)
          CodeBrowserView(repoName: widget.repoName, owner: widget.owner),

          // 2. Commits (Phase 1 Commit History & Git Object DAG View)
          const GitObjectDagView(),

          // 3. Branches (Phase 1 Branch Manager & PRs)
          BranchesView(repoName: widget.repoName, owner: widget.owner),

          // 4. Tags & Signatures (Phase 2 Signed Tags)
          TagsView(repoName: widget.repoName, owner: widget.owner),

          // 5. Issues (Phase 2 Issue Tracker)
          IssuesView(repoName: widget.repoName, owner: widget.owner),

          // 6. Pull Requests (Phase 2 Pull Requests)
          PullRequestsView(repoName: widget.repoName, owner: widget.owner),

          // 7. Members & Permissions (Phase 2 Key Permissions & Access Control)
          PermissionsView(repoName: widget.repoName, owner: widget.owner),

          // 8. Releases & Binary Assets (Phase 2 Binary Assets)
          ReleasesView(repoName: widget.repoName, owner: widget.owner),

          // 9. Network (USP Tab)
          RepositoryNetworkView(repoName: widget.repoName),

          // 10. Storage
          const LocalStoragePanel(),
        ],
      ),
    );
  }
}
