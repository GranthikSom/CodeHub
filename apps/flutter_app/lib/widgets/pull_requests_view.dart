import 'package:flutter/material.dart';

class PullRequestsView extends StatefulWidget {
  final String repoName;
  final String owner;

  const PullRequestsView({
    super.key,
    required this.repoName,
    required this.owner,
  });

  @override
  State<PullRequestsView> createState() => _PullRequestsViewState();
}

class _PullRequestsViewState extends State<PullRequestsView> {
  final List<Map<String, dynamic>> _prs = [
    {
      'id': '#201',
      'title': 'feat: implement Kademlia DHT peer discovery protocol',
      'author': 'GranthikSom',
      'status': 'open',
      'head': 'feature/dht-routing',
      'base': 'main',
      'created': '2 hours ago',
      'reviews': '2 Approvals',
    },
    {
      'id': '#194',
      'title': 'refactor: Rust-native SHA-256 blockstore chunking algorithm',
      'author': 'SohamMondal',
      'status': 'merged',
      'head': 'refactor/blockstore',
      'base': 'main',
      'created': '2 days ago',
      'reviews': 'Merged',
    },
  ];

  void _showNewPRDialog() {
    final titleController = TextEditingController(text: 'feat: add Noise TLS handshake');
    final headController = TextEditingController(text: 'feature/dht-routing');

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
          title: const Text('Open Pull Request'),
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
                controller: headController,
                decoration: const InputDecoration(
                  labelText: 'Head Branch',
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
                    _prs.insert(0, {
                      'id': '#${202 + _prs.length}',
                      'title': titleController.text,
                      'author': 'GranthikSom',
                      'status': 'open',
                      'head': headController.text,
                      'base': 'main',
                      'created': 'Just now',
                      'reviews': 'Pending Review',
                    });
                  });
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Create Pull Request'),
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
                  const Icon(Icons.merge_type, color: Color(0xFF58A6FF), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Pull Requests',
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
                      '${_prs.where((p) => p['status'] == 'open').length} Open',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF58A6FF)),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showNewPRDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF238636),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New Pull Request', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: _prs.length,
              itemBuilder: (context, index) {
                final pr = _prs[index];
                final isOpen = pr['status'] == 'open';

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
                        isOpen ? Icons.call_merge : Icons.done_all,
                        color: isOpen ? const Color(0xFF3FB950) : const Color(0xFF8250DF),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pr['title'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${pr['id']} want to merge into ${pr['base']} from ${pr['head']} • ${pr['created']} by ${pr['author']}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOpen
                              ? const Color(0xFF238636).withValues(alpha: 0.15)
                              : const Color(0xFF8250DF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isOpen ? const Color(0xFF3FB950) : const Color(0xFF8250DF),
                          ),
                        ),
                        child: Text(
                          pr['reviews'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isOpen ? const Color(0xFF3FB950) : const Color(0xFF8250DF),
                          ),
                        ),
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
