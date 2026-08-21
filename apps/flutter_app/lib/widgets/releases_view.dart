import 'package:flutter/material.dart';

class ReleasesView extends StatefulWidget {
  final String repoName;
  final String owner;

  const ReleasesView({
    super.key,
    required this.repoName,
    required this.owner,
  });

  @override
  State<ReleasesView> createState() => _ReleasesViewState();
}

class _ReleasesViewState extends State<ReleasesView> {
  final List<Map<String, dynamic>> _releases = [
    {
      'title': 'v1.0.0 Sovereign Production Release',
      'tag': 'v1.0.0',
      'author': 'GranthikSom',
      'date': 'Released 2 days ago',
      'isLatest': true,
      'notes': 'First stable production release featuring P2P Git blockstore chunking and Flutter desktop visualizer.',
      'assets': [
        {'name': 'codehub-linux-x64.tar.gz', 'size': '42.5 MB', 'seeders': 14},
        {'name': 'codehub-macos-arm64.zip', 'size': '48.1 MB', 'seeders': 12},
      ],
    },
  ];

  void _showDraftReleaseDialog() {
    final titleController = TextEditingController(text: 'v1.1.0 Feature Release');
    final tagController = TextEditingController(text: 'v1.1.0');
    final notesController = TextEditingController(text: 'Adds Noise TLS encryption and Kademlia DHT peer discovery.');

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
          title: const Text('Draft New Release'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Release Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tagController,
                decoration: const InputDecoration(
                  labelText: 'Tag Version',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Release Notes',
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
                    _releases.insert(0, {
                      'title': titleController.text,
                      'tag': tagController.text,
                      'author': 'GranthikSom',
                      'date': 'Just now',
                      'isLatest': true,
                      'notes': notesController.text,
                      'assets': [
                        {'name': 'codehub-linux-x64.tar.gz', 'size': '45.0 MB', 'seeders': 1},
                      ],
                    });
                  });
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Publish Release'),
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
                  const Icon(Icons.rocket_launch_outlined, color: Color(0xFFBC8CFF), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Releases & Decentralized Binary Assets',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showDraftReleaseDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF238636),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Draft Release', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: _releases.length,
              itemBuilder: (context, index) {
                final rel = _releases[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161B22) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            rel['title'] as String,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (rel['isLatest'] as bool)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF238636).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF238636)),
                              ),
                              child: const Text(
                                'Latest Release',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3FB950)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tag: ${rel['tag']} • ${rel['date']} by ${rel['author']}',
                        style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        rel['notes'] as String,
                        style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Assets (${(rel['assets'] as List).length})',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF58A6FF) : Colors.blue.shade900),
                      ),
                      const SizedBox(height: 8),

                      ...((rel['assets'] as List<Map<String, dynamic>>).map((asset) => Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.insert_drive_file_outlined, size: 16, color: Color(0xFF58A6FF)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    asset['name'] as String,
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                                  ),
                                ),
                                Text(
                                  '${asset['size']} • ${asset['seeders']} Seeders',
                                  style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.file_download_outlined, size: 18, color: Color(0xFF3FB950)),
                              ],
                            ),
                          ))),
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
