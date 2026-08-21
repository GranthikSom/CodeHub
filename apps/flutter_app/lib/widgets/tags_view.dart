import 'package:flutter/material.dart';

class TagsView extends StatefulWidget {
  final String repoName;
  final String owner;

  const TagsView({
    super.key,
    required this.repoName,
    required this.owner,
  });

  @override
  State<TagsView> createState() => _TagsViewState();
}

class _TagsViewState extends State<TagsView> {
  final List<Map<String, String>> _tags = [
    {
      'name': 'v1.0.0',
      'commitSha': '8f2a1b9c',
      'author': 'GranthikSom',
      'date': '2 days ago',
      'signature': 'Verified GPG (Key ID: ed25519_994a)',
    },
    {
      'name': 'v0.9.4-beta',
      'commitSha': '3c19d4f2',
      'author': 'SohamMondal',
      'date': '1 week ago',
      'signature': 'Verified GPG (Key ID: ed25519_3c19)',
    },
  ];

  void _showCreateTagDialog() {
    final nameController = TextEditingController(text: 'v1.1.0-alpha');
    final shaController = TextEditingController(text: '8f2a1b9c');

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
          title: const Text('Create GPG Signed Tag'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tag Name',
                  hintText: 'e.g. v1.1.0',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: shaController,
                decoration: const InputDecoration(
                  labelText: 'Target Commit SHA-256',
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
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    _tags.insert(0, {
                      'name': nameController.text,
                      'commitSha': shaController.text,
                      'author': 'GranthikSom',
                      'date': 'Just now',
                      'signature': 'Verified GPG (Key ID: ed25519_994a)',
                    });
                  });
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Sign & Push Tag'),
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
                  const Icon(Icons.label_important_outline, color: Color(0xFF3FB950), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Repository Tags & Cryptographic Signatures',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showCreateTagDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF238636),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Create Tag', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: _tags.length,
              itemBuilder: (context, index) {
                final tag = _tags[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161B22) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tag, color: Color(0xFF58A6FF), size: 24),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  tag['name']!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF238636).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFF238636), width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.verified_user_outlined, size: 12, color: Color(0xFF3FB950)),
                                      const SizedBox(width: 4),
                                      Text(
                                        tag['signature']!,
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3FB950)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Target SHA: ${tag['commitSha']} • Tagged ${tag['date']} by ${tag['author']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download_rounded, size: 16),
                        label: const Text('zip / tar.gz'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : Colors.black87,
                          side: BorderSide(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
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
