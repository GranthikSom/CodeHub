import 'package:flutter/material.dart';

class IssuesView extends StatefulWidget {
  final String repoName;
  final String owner;

  const IssuesView({
    super.key,
    required this.repoName,
    required this.owner,
  });

  @override
  State<IssuesView> createState() => _IssuesViewState();
}

class _IssuesViewState extends State<IssuesView> {
  final List<Map<String, dynamic>> _issues = [
    {
      'id': '#101',
      'title': 'Support QUIC multiplexing over libp2p transport layer',
      'author': 'GranthikSom',
      'status': 'open',
      'created': '3 hours ago',
      'comments': 4,
      'labels': ['enhancement', 'p2p-net'],
    },
    {
      'id': '#98',
      'title': 'Garbage collection candidate purging grace period evaluation',
      'author': 'SohamMondal',
      'status': 'open',
      'created': '1 day ago',
      'comments': 7,
      'labels': ['storage', 'rust'],
    },
    {
      'id': '#85',
      'title': 'Fix SHA-256 block hash mismatch during partial swarm sync',
      'author': 'AlexDev',
      'status': 'closed',
      'created': '3 days ago',
      'comments': 12,
      'labels': ['bug', 'resolved'],
    },
  ];

  void _showNewIssueDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
          title: const Text('Create New Issue'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF238636),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    _issues.insert(0, {
                      'id': '#${102 + _issues.length}',
                      'title': titleController.text,
                      'author': 'GranthikSom',
                      'status': 'open',
                      'created': 'Just now',
                      'comments': 0,
                      'labels': ['community'],
                    });
                  });
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Submit Issue'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.bug_report_outlined, color: Color(0xFFF85149), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Issue Tracker',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF21262D) : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_issues.where((i) => i['status'] == 'open').length} Open',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF3FB950)),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showNewIssueDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF238636),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New Issue', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: _issues.length,
              itemBuilder: (context, index) {
                final issue = _issues[index];
                final isOpen = issue['status'] == 'open';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161B22) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isOpen ? Icons.adjust : Icons.check_circle_outline,
                        color: isOpen ? const Color(0xFF3FB950) : const Color(0xFF8250DF),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  issue['title'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ...((issue['labels'] as List<String>).map((label) => Container(
                                      margin: const EdgeInsets.only(right: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF58A6FF).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: const Color(0xFF58A6FF), width: 0.8),
                                      ),
                                      child: Text(
                                        label,
                                        style: const TextStyle(fontSize: 10, color: Color(0xFF58A6FF), fontWeight: FontWeight.bold),
                                      ),
                                    ))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${issue['id']} opened ${issue['created']} by ${issue['author']}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 14, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '${issue['comments']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
