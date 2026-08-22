import 'package:flutter/material.dart';
import '../services/codehub_state.dart';

class PullRequestsScreen extends StatefulWidget {
  final CodeHubState state;

  const PullRequestsScreen({super.key, required this.state});

  @override
  State<PullRequestsScreen> createState() => _PullRequestsScreenState();
}

class _PullRequestsScreenState extends State<PullRequestsScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _prs = [
    {
      'id': '#42',
      'title': 'Improve peer discovery',
      'repo': 'GranthikSom / CodeHub',
      'author': 'GranthikSom',
      'authorAvatar': 'G',
      'status': 'open',
      'head': 'feature/peer-discovery',
      'base': 'main',
      'created': '10 mins ago',
      'reviews': '2 Approvals',
      'category': 'your',
      'diff': '+142 -18 lines • 4 files changed',
      'signature': 'Ed25519 Verified (0x9948...a812)',
      'description': 'Refactors Kademlia DHT routing table to improve peer lookup speeds by 40% over local swarms.',
    },
    {
      'id': '#39',
      'title': 'Fix chunk verification',
      'repo': 'GranthikSom / CodeHub',
      'author': 'node_beta',
      'authorAvatar': 'N',
      'status': 'waiting_review',
      'head': 'fix/chunk-verifier',
      'base': 'main',
      'created': '2 hours ago',
      'reviews': 'Waiting for review',
      'category': 'waiting',
      'diff': '+38 -12 lines • 2 files changed',
      'signature': 'Ed25519 Verified (0x7721...c901)',
      'description': 'Fixes corner case in SHA-256 chunk boundary calculation for binary files over 500MB.',
    },
    {
      'id': '#37',
      'title': 'Add repository encryption',
      'repo': 'GranthikSom / P2P-Storage',
      'author': 'GranthikSom',
      'authorAvatar': 'G',
      'status': 'merged',
      'head': 'feat/repo-crypto',
      'base': 'main',
      'created': 'Yesterday',
      'reviews': 'Merged by GranthikSom',
      'category': 'merged',
      'diff': '+280 -45 lines • 8 files changed',
      'signature': 'Ed25519 Verified (0x1189...f042)',
      'description': 'Introduces AES-256-GCM envelope encryption for private P2P repository chunks.',
    },
    {
      'id': '#35',
      'title': 'Implement delta compression sync',
      'repo': 'GranthikSom / CodeHub',
      'author': 'soham_dev',
      'authorAvatar': 'S',
      'status': 'review_requested',
      'head': 'feat/delta-sync',
      'base': 'main',
      'created': '3 hours ago',
      'reviews': 'Review requested from you',
      'category': 'requested',
      'diff': '+195 -60 lines • 6 files changed',
      'signature': 'Ed25519 Verified (0x4432...b110)',
      'description': 'Optimizes P2P object sync using vcdiff delta encoding to reduce bandwidth by 99%.',
    },
    {
      'id': '#31',
      'title': 'Zero-knowledge proof authentication',
      'repo': 'GranthikSom / P2P-Storage',
      'author': 'crypto_master',
      'authorAvatar': 'C',
      'status': 'merged',
      'head': 'feat/zkp-auth',
      'base': 'main',
      'created': '3 days ago',
      'reviews': 'Merged',
      'category': 'merged',
      'diff': '+310 -15 lines • 7 files changed',
      'signature': 'Ed25519 Verified (0x8892...e331)',
      'description': 'Adds Schnorr zero-knowledge identity challenge for relay node auth.',
    },
    {
      'id': '#28',
      'title': 'Hardened Argon2id password hashing',
      'repo': 'GranthikSom / CodeHub',
      'author': 'GranthikSom',
      'authorAvatar': 'G',
      'status': 'merged',
      'head': 'security/argon2id',
      'base': 'main',
      'created': '5 days ago',
      'reviews': 'Merged by GranthikSom',
      'category': 'merged',
      'diff': '+95 -40 lines • 3 files changed',
      'signature': 'Ed25519 Verified (0x3341...d992)',
      'description': 'Replaces insecure fallback auth with memory-hard Argon2id password hashing in Rust Axum server.',
    },
  ];

  int get _yourPrsCount => _prs.where((p) => p['author'] == 'GranthikSom').length;
  int get _waitingReviewCount => _prs.where((p) => p['status'] == 'waiting_review').length;
  int get _reviewRequestedCount => _prs.where((p) => p['status'] == 'review_requested').length;
  int get _mergedCount => _prs.where((p) => p['status'] == 'merged').length;

  List<Map<String, dynamic>> get _filteredPrs {
    return _prs.where((pr) {
      final matchesSearch = _searchQuery.isEmpty ||
          pr['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pr['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pr['author'].toString().toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (_selectedFilter == 'your') return pr['author'] == 'GranthikSom';
      if (_selectedFilter == 'waiting') return pr['status'] == 'waiting_review';
      if (_selectedFilter == 'requested') return pr['status'] == 'review_requested';
      if (_selectedFilter == 'merged') return pr['status'] == 'merged';
      if (_selectedFilter == 'open') return pr['status'] == 'open' || pr['status'] == 'waiting_review' || pr['status'] == 'review_requested';

      return true;
    }).toList();
  }

  void _showNewPRDialog() {
    final titleController = TextEditingController();
    final repoController = TextEditingController(text: 'GranthikSom / CodeHub');
    final headController = TextEditingController(text: 'feature/new-improvement');
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.call_merge_rounded, color: Color(0xFF58A6FF)),
              SizedBox(width: 10),
              Text('Create New Pull Request'),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: repoController,
                  decoration: const InputDecoration(
                    labelText: 'Target Repository',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Pull Request Title',
                    hintText: 'e.g. #43 Implement WebSockets admin panel',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: headController,
                  decoration: const InputDecoration(
                    labelText: 'Head Branch (Source)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description & Technical Context',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF238636),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    _prs.insert(0, {
                      'id': '#${43 + _prs.length}',
                      'title': titleController.text,
                      'repo': repoController.text,
                      'author': widget.state.api.currentUsername ?? 'GranthikSom',
                      'authorAvatar': (widget.state.api.currentUsername ?? 'G')[0].toUpperCase(),
                      'status': 'open',
                      'head': headController.text,
                      'base': 'main',
                      'created': 'Just now',
                      'reviews': '1 Approval needed',
                      'category': 'your',
                      'diff': '+45 -5 lines • 2 files changed',
                      'signature': 'Ed25519 Verified',
                      'description': descController.text.isNotEmpty ? descController.text : 'New pull request submitted.',
                    });
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pull Request submitted successfully'),
                      backgroundColor: Color(0xFF238636),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Create Pull Request'),
            ),
          ],
        );
      },
    );
  }

  void _showPRDetailsModal(Map<String, dynamic> pr) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final isOpen = pr['status'] == 'open' || pr['status'] == 'waiting_review' || pr['status'] == 'review_requested';
        final isMerged = pr['status'] == 'merged';

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isMerged
                      ? const Color(0xFF8250DF).withValues(alpha: 0.2)
                      : const Color(0xFF238636).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isMerged ? const Color(0xFF8250DF) : const Color(0xFF3FB950),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isMerged ? Icons.done_all_rounded : Icons.call_merge_rounded,
                      size: 14,
                      color: isMerged ? const Color(0xFFBC8CFF) : const Color(0xFF3FB950),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isMerged ? 'MERGED' : 'OPEN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isMerged ? const Color(0xFFBC8CFF) : const Color(0xFF3FB950),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${pr['id']} ${pr['title']}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 550,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Repository: ${pr['repo']}',
                  style: const TextStyle(fontSize: 12, color: Colors.blueAccent, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('Branch: ', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(pr['head'] as String, style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
                    ),
                    const Text('  ➔  ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(pr['base'] as String, style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFF30363D)),
                const SizedBox(height: 8),
                Text(
                  pr['description'] as String,
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF30363D)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.compare_arrows_rounded, size: 16, color: Color(0xFF58A6FF)),
                          const SizedBox(width: 8),
                          Text(pr['diff'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.verified_user_outlined, size: 16, color: Color(0xFF3FB950)),
                          const SizedBox(width: 8),
                          Text(pr['signature'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF3FB950))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
            if (isOpen)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8250DF),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    pr['status'] = 'merged';
                    pr['reviews'] = 'Merged by ${widget.state.api.currentUsername ?? 'GranthikSom'}';
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pull Request ${pr['id']} merged into main!'),
                      backgroundColor: const Color(0xFF8250DF),
                    ),
                  );
                },
                icon: const Icon(Icons.done_all_rounded, size: 16),
                label: const Text('Merge Pull Request'),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FA),
      child: SafeArea(
        child: Column(
          children: [
            // Top Header Bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B22) : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.call_merge_rounded, size: 28, color: Color(0xFF58A6FF)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pull Requests',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        'P2P Code review, commit DAG merges, and pull request tracking',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _showNewPRDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF238636),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Pull Request', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Metrics Cards Grid (4 Specified Cards)
                    Row(
                      children: [
                        _buildMetricCard(
                          context: context,
                          title: 'Your PRs',
                          count: _yourPrsCount,
                          icon: Icons.call_merge_rounded,
                          color: const Color(0xFF58A6FF),
                          onTap: () => setState(() => _selectedFilter = 'your'),
                          isSelected: _selectedFilter == 'your',
                        ),
                        const SizedBox(width: 16),
                        _buildMetricCard(
                          context: context,
                          title: 'Waiting for review',
                          count: _waitingReviewCount,
                          icon: Icons.hourglass_empty_rounded,
                          color: const Color(0xFFD29922),
                          onTap: () => setState(() => _selectedFilter = 'waiting'),
                          isSelected: _selectedFilter == 'waiting',
                        ),
                        const SizedBox(width: 16),
                        _buildMetricCard(
                          context: context,
                          title: 'Review requested from you',
                          count: _reviewRequestedCount,
                          icon: Icons.rate_review_outlined,
                          color: const Color(0xFFBC8CFF),
                          onTap: () => setState(() => _selectedFilter = 'requested'),
                          isSelected: _selectedFilter == 'requested',
                        ),
                        const SizedBox(width: 16),
                        _buildMetricCard(
                          context: context,
                          title: 'Merged',
                          count: _mergedCount,
                          icon: Icons.done_all_rounded,
                          color: const Color(0xFF3FB950),
                          onTap: () => setState(() => _selectedFilter = 'merged'),
                          isSelected: _selectedFilter == 'merged',
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Search & Filter Controls Bar
                    Row(
                      children: [
                        // Search Field
                        Expanded(
                          child: TextField(
                            onChanged: (val) => setState(() => _searchQuery = val),
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Search pull requests by title, #ID, or branch...',
                              prefixIcon: const Icon(Icons.search, size: 18),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF161B22) : Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Filter Pills
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterPill('All PRs', 'all'),
                              const SizedBox(width: 8),
                              _buildFilterPill('Open', 'open'),
                              const SizedBox(width: 8),
                              _buildFilterPill('Your PRs', 'your'),
                              const SizedBox(width: 8),
                              _buildFilterPill('Waiting Review', 'waiting'),
                              const SizedBox(width: 8),
                              _buildFilterPill('Merged', 'merged'),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // PR List View
                    if (_filteredPrs.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(40),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF161B22) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.call_merge, size: 48, color: isDark ? Colors.white24 : Colors.black26),
                            const SizedBox(height: 12),
                            Text(
                              'No pull requests found',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredPrs.length,
                        itemBuilder: (context, index) {
                          final pr = _filteredPrs[index];
                          final isMerged = pr['status'] == 'merged';

                          Color statusColor = const Color(0xFF3FB950);
                          IconData statusIcon = Icons.call_merge_rounded;

                          if (isMerged) {
                            statusColor = const Color(0xFF8250DF);
                            statusIcon = Icons.done_all_rounded;
                          } else if (pr['status'] == 'waiting_review') {
                            statusColor = const Color(0xFFD29922);
                            statusIcon = Icons.hourglass_empty_rounded;
                          } else if (pr['status'] == 'review_requested') {
                            statusColor = const Color(0xFFBC8CFF);
                            statusIcon = Icons.rate_review_outlined;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF161B22) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                            ),
                            child: InkWell(
                              onTap: () => _showPRDetailsModal(pr),
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Status Icon
                                    Icon(statusIcon, color: statusColor, size: 20),
                                    const SizedBox(width: 14),

                                    // Content Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '${pr['id']} ${pr['title']}',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark ? Colors.white : Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: isDark ? const Color(0xFF21262D) : Colors.grey.shade200,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  pr['repo'] as String,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Text(
                                                '${pr['head']} ➔ ${pr['base']}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontFamily: 'monospace',
                                                  color: isDark ? const Color(0xFF58A6FF) : Colors.blue.shade700,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'opened ${pr['created']} by ',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                                                ),
                                              ),
                                              CircleAvatar(
                                                radius: 8,
                                                backgroundColor: const Color(0xFF238636),
                                                child: Text(
                                                  pr['authorAvatar'] as String,
                                                  style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                pr['author'] as String,
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
                                    ),

                                    // Right Status Badge & Diff
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: statusColor.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: statusColor),
                                          ),
                                          child: Text(
                                            pr['reviews'] as String,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: statusColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          pr['diff'] as String,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : (isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label, String value) {
    final isSelected = _selectedFilter == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = value;
          });
        }
      },
      selectedColor: const Color(0xFF58A6FF).withValues(alpha: 0.2),
      backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected
            ? const Color(0xFF58A6FF)
            : (isDark ? const Color(0xFF8B949E) : Colors.grey.shade700),
      ),
      side: BorderSide(
        color: isSelected
            ? const Color(0xFF58A6FF)
            : (isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
      ),
    );
  }
}
