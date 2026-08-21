import 'package:flutter/material.dart';

class BranchesView extends StatelessWidget {
  final String repoName;
  final String owner;

  const BranchesView({
    super.key,
    required this.repoName,
    required this.owner,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final branches = [
      {'name': 'main', 'isDefault': true, 'author': 'GranthikSom', 'sha': '8f2a1b9', 'updated': '10 mins ago'},
      {'name': 'feature/dht-routing', 'isDefault': false, 'author': 'SohamMondal', 'sha': '3c19d4f', 'updated': '2 hours ago'},
      {'name': 'release/v1.0', 'isDefault': false, 'author': 'GranthikSom', 'sha': '1a72e8b', 'updated': '1 day ago'},
    ];

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
                  const Icon(Icons.alt_route, color: Color(0xFFBC8CFF), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Branches & Pull Requests',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF238636),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New Branch', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: branches.length,
              itemBuilder: (context, index) {
                final b = branches[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161B22) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            b['isDefault'] as bool ? Icons.star_border : Icons.call_split,
                            color: b['isDefault'] as bool ? const Color(0xFFD29922) : const Color(0xFF58A6FF),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    b['name'] as String,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  if (b['isDefault'] as bool) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF58A6FF).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: const Color(0xFF58A6FF), width: 0.8),
                                      ),
                                      child: const Text(
                                        'default',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF58A6FF)),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Updated ${b['updated']} by ${b['author']} • SHA ${b['sha']}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : Colors.black87,
                          side: BorderSide(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                        ),
                        child: const Text('Compare & Pull Request'),
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
