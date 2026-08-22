import 'package:flutter/material.dart';
import '../services/codehub_state.dart';

enum IssueFilterTab {
  open,
  closed,
  assignedToMe,
  mentioned,
  labels,
}

class IssueModel {
  final String id;
  final int number;
  final String title;
  final String repo;
  final String author;
  final String timeAgo;
  final bool isOpen;
  final bool isAssignedToMe;
  final bool isMentioned;
  final bool needsAttention;
  final int commentsCount;
  final List<String> labels;

  const IssueModel({
    required this.id,
    required this.number,
    required this.title,
    required this.repo,
    required this.author,
    required this.timeAgo,
    required this.isOpen,
    required this.isAssignedToMe,
    required this.isMentioned,
    this.needsAttention = false,
    required this.commentsCount,
    required this.labels,
  });
}

class IssuesScreen extends StatefulWidget {
  final CodeHubState state;

  const IssuesScreen({super.key, required this.state});

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  IssueFilterTab _activeTab = IssueFilterTab.open;
  String _selectedLabel = 'all';
  String _searchQuery = '';

  final List<IssueModel> _allIssues = const [
    IssueModel(
      id: 'iss-124',
      number: 124,
      title: 'P2P sync timeout when seeding large chunk files over Kademlia DHT',
      repo: 'codehub-core-p2p',
      author: 'GranthikSom',
      timeAgo: '2 hours ago',
      isOpen: true,
      isAssignedToMe: true,
      isMentioned: true,
      needsAttention: true,
      commentsCount: 7,
      labels: ['bug', 'p2p-sync', 'critical'],
    ),
    IssueModel(
      id: 'iss-121',
      number: 121,
      title: 'Windows node crash on Rabin fingerprint chunk boundary calculation',
      repo: 'codehub-core-p2p',
      author: 'TokyoNodePeer',
      timeAgo: '4 hours ago',
      isOpen: true,
      isAssignedToMe: true,
      isMentioned: false,
      needsAttention: true,
      commentsCount: 12,
      labels: ['bug', 'critical'],
    ),
    IssueModel(
      id: 'iss-118',
      number: 118,
      title: 'DAG rendering issue in Flutter graph visualizer during high depth zoom',
      repo: 'flutter-dag-visualizer',
      author: 'SohamMondal',
      timeAgo: '6 hours ago',
      isOpen: true,
      isAssignedToMe: false,
      isMentioned: true,
      needsAttention: false,
      commentsCount: 3,
      labels: ['rendering', 'ui'],
    ),
    IssueModel(
      id: 'iss-115',
      number: 115,
      title: 'Argon2id hashing benchmark optimization on ARM64 Linux nodes',
      repo: 'codehub-core-p2p',
      author: 'BerlinPeer',
      timeAgo: '1 day ago',
      isOpen: true,
      isAssignedToMe: true,
      isMentioned: false,
      needsAttention: false,
      commentsCount: 5,
      labels: ['feature', 'performance'],
    ),
    IssueModel(
      id: 'iss-110',
      number: 110,
      title: 'Add Gossipsub pub/sub topic for real-time pull request announcements',
      repo: 'kademlia-dht-relay',
      author: 'SohamMondal',
      timeAgo: '2 days ago',
      isOpen: true,
      isAssignedToMe: true,
      isMentioned: false,
      needsAttention: false,
      commentsCount: 9,
      labels: ['feature', 'p2p-sync'],
    ),
    IssueModel(
      id: 'iss-105',
      number: 105,
      title: 'Fix routing table staleness on network disconnects',
      repo: 'kademlia-dht-relay',
      author: 'GranthikSom',
      timeAgo: '3 days ago',
      isOpen: false,
      isAssignedToMe: false,
      isMentioned: false,
      needsAttention: false,
      commentsCount: 14,
      labels: ['bug', 'closed'],
    ),
  ];

  List<IssueModel> get _filteredIssues {
    List<IssueModel> list;
    switch (_activeTab) {
      case IssueFilterTab.open:
        list = _allIssues.where((i) => i.isOpen).toList();
        break;
      case IssueFilterTab.closed:
        list = _allIssues.where((i) => !i.isOpen).toList();
        break;
      case IssueFilterTab.assignedToMe:
        list = _allIssues.where((i) => i.isAssignedToMe && i.isOpen).toList();
        break;
      case IssueFilterTab.mentioned:
        list = _allIssues.where((i) => i.isMentioned && i.isOpen).toList();
        break;
      case IssueFilterTab.labels:
        if (_selectedLabel == 'all') {
          list = _allIssues;
        } else {
          list = _allIssues.where((i) => i.labels.contains(_selectedLabel)).toList();
        }
        break;
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((i) {
        return i.title.toLowerCase().contains(q) ||
            i.repo.toLowerCase().contains(q) ||
            '#${i.number}'.contains(q) ||
            i.labels.any((l) => l.toLowerCase().contains(q));
      }).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final openCount = _allIssues.where((i) => i.isOpen).length;
    final assignedCount = _allIssues.where((i) => i.isAssignedToMe && i.isOpen).length;
    final attentionCount = _allIssues.where((i) => i.needsAttention && i.isOpen).length;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Screen Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bug_report_rounded, color: Color(0xFF38BDF8), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Swarm Issues & Task Tracker',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Track bugs, feature requests, and community discussions across P2P repositories.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showCreateIssueDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF238636),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New Issue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // DASHBOARD ISSUES CARD (Exact user requested layout)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.adjust_rounded, color: Color(0xFF38BDF8), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'ISSUES SUMMARY',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$openCount Total Open',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF38BDF8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Stat Metric Columns Row
                Row(
                  children: [
                    _buildStatBox(context, 'Open Issues', '$openCount', const Color(0xFF38BDF8)),
                    const SizedBox(width: 14),
                    _buildStatBox(context, 'Assigned to You', '$assignedCount', const Color(0xFFA371F7)),
                    const SizedBox(width: 14),
                    _buildStatBox(context, 'Needs Attention', '$attentionCount', const Color(0xFFF85149)),
                  ],
                ),
                const SizedBox(height: 16),

                const Divider(height: 1),
                const SizedBox(height: 14),

                // Featured Urgent Issues List
                Text(
                  'HIGH PRIORITY ISSUES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 10),

                ..._allIssues.where((i) => i.needsAttention || i.isAssignedToMe).take(3).map(
                  (issue) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: isDark ? const Color(0xFF21262D) : Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '#${issue.number}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: Color(0xFF38BDF8),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            issue.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF85149).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            issue.repo,
                            style: const TextStyle(
                              fontSize: 10,
                              fontFamily: 'monospace',
                              color: Color(0xFFF85149),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Filter Controls & Search Row
          Row(
            children: [
              // Search Input
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Search issues by title, label (#bug), or issue #...',
                      hintStyle: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF8B949E) : Colors.grey),
                      prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF8B949E)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF161B22) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Filter Chips / Tabs
              _buildTabButton('Open ($openCount)', IssueFilterTab.open, Icons.adjust_rounded, const Color(0xFF38BDF8)),
              const SizedBox(width: 6),
              _buildTabButton('Closed', IssueFilterTab.closed, Icons.check_circle_outline_rounded, const Color(0xFF8957E5)),
              const SizedBox(width: 6),
              _buildTabButton('Assigned ($assignedCount)', IssueFilterTab.assignedToMe, Icons.person_outline_rounded, const Color(0xFFA371F7)),
              const SizedBox(width: 6),
              _buildTabButton('Mentioned', IssueFilterTab.mentioned, Icons.alternate_email_rounded, const Color(0xFFD29922)),
              const SizedBox(width: 6),
              _buildTabButton('Labels', IssueFilterTab.labels, Icons.label_outlined, const Color(0xFF238636)),
            ],
          ),

          // Optional Label Selector when Labels tab active
          if (_activeTab == IssueFilterTab.labels) ...[
            const SizedBox(height: 10),
            Row(
              children: ['all', 'bug', 'p2p-sync', 'rendering', 'critical', 'feature'].map((l) {
                final isSelected = _selectedLabel == l;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: FilterChip(
                    showCheckmark: false,
                    selected: isSelected,
                    label: Text('#$l', style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.blueAccent)),
                    selectedColor: const Color(0xFF2F81F7),
                    backgroundColor: isDark ? const Color(0xFF161B22) : Colors.grey.shade200,
                    onSelected: (_) {
                      setState(() {
                        _selectedLabel = l;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 14),

          // Main Issue List View
          Expanded(
            child: _filteredIssues.isEmpty
                ? Center(
                    child: Text(
                      'No issues found matching criteria.',
                      style: TextStyle(color: isDark ? const Color(0xFF8B949E) : Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredIssues.length,
                    itemBuilder: (context, index) {
                      final issue = _filteredIssues[index];
                      return _buildIssueTile(context, issue);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(BuildContext context, String label, String value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? const Color(0xFF21262D) : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, IssueFilterTab tab, IconData icon, Color color) {
    final isSelected = _activeTab == tab;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        setState(() {
          _activeTab = tab;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : (isDark ? const Color(0xFF161B22) : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? color : (isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSelected ? color : (isDark ? const Color(0xFF8B949E) : Colors.grey.shade700)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueTile(BuildContext context, IssueModel issue) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            issue.isOpen ? Icons.adjust_rounded : Icons.check_circle_outline_rounded,
            color: issue.isOpen ? const Color(0xFF3FB950) : const Color(0xFFA371F7),
            size: 18,
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '#${issue.number}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: Color(0xFF38BDF8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        issue.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Labels & Details Row
                Row(
                  children: [
                    Text(
                      '${issue.repo} • opened ${issue.timeAgo} by ',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      issue.author,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF58A6FF),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Issue Label Chips
                    ...issue.labels.map((lbl) => Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getLabelColor(lbl).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: _getLabelColor(lbl).withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            lbl,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getLabelColor(lbl),
                            ),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Right Comments & Assignee Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 14, color: isDark ? const Color(0xFF8B949E) : Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${issue.commentsCount}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              if (issue.isAssignedToMe) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA371F7).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Assigned to You',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFA371F7),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getLabelColor(String label) {
    switch (label) {
      case 'bug':
        return const Color(0xFFF85149);
      case 'critical':
        return const Color(0xFFDA3633);
      case 'p2p-sync':
        return const Color(0xFF38BDF8);
      case 'rendering':
      case 'ui':
        return const Color(0xFFA371F7);
      case 'feature':
        return const Color(0xFF238636);
      default:
        return const Color(0xFF58A6FF);
    }
  }

  void _showCreateIssueDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161B22),
          title: const Text('Create New P2P Swarm Issue', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Description / Reproduce Steps',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF238636)),
              onPressed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Issue broadcasted to P2P Swarm Nodes!')),
                );
              },
              child: const Text('Submit Issue'),
            ),
          ],
        );
      },
    );
  }
}
