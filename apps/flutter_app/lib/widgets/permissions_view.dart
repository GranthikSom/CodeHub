import 'package:flutter/material.dart';

class PermissionsView extends StatefulWidget {
  final String repoName;
  final String owner;

  const PermissionsView({
    super.key,
    required this.repoName,
    required this.owner,
  });

  @override
  State<PermissionsView> createState() => _PermissionsViewState();
}

class _PermissionsViewState extends State<PermissionsView> {
  final List<Map<String, String>> _members = [
    {'name': 'GranthikSom', 'role': 'Owner / Admin', 'keyId': 'key_ed25519_994a', 'access': 'Full Control (Read/Write/Pin)'},
    {'name': 'SohamMondal', 'role': 'Maintainer', 'keyId': 'key_ed25519_3c19', 'access': 'Write & Seeding Access'},
    {'name': 'SanFranciscoPeer', 'role': 'Replica Node', 'keyId': 'key_secp256k1_88f0', 'access': 'Read & Swarm Seeding Only'},
  ];

  void _showGrantKeyDialog() {
    final nameController = TextEditingController(text: 'TokyoNodePeer');
    String selectedRole = 'Maintainer';

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
          title: const Text('Grant Access Key'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Developer Username or Node Peer ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                items: const [
                  DropdownMenuItem(value: 'Maintainer', child: Text('Maintainer (Write/Pin)')),
                  DropdownMenuItem(value: 'Contributor', child: Text('Contributor (Write)')),
                  DropdownMenuItem(value: 'Seeder', child: Text('Seeder Node (Read Only)')),
                ],
                onChanged: (val) {
                  if (val != null) selectedRole = val;
                },
                decoration: const InputDecoration(
                  labelText: 'Permission Role',
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
                    _members.add({
                      'name': nameController.text,
                      'role': selectedRole,
                      'keyId': 'key_ed25519_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                      'access': 'Read & Write Access',
                    });
                  });
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Grant Access Key'),
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
                  const Icon(Icons.shield_outlined, color: Color(0xFFBC8CFF), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Repository Members & Access Keys',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showGrantKeyDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF238636),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.key, size: 16),
                label: const Text('Grant Access Key', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: _members.length,
              itemBuilder: (context, index) {
                final member = _members[index];

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
                      CircleAvatar(
                        backgroundColor: isDark ? const Color(0xFF21262D) : Colors.grey.shade200,
                        child: Text(
                          member['name']![0].toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF58A6FF)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  member['name']!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFBC8CFF).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFFBC8CFF), width: 0.8),
                                  ),
                                  child: Text(
                                    member['role']!,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFBC8CFF)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Key ID: ${member['keyId']} • Permission: ${member['access']}',
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : Colors.black87,
                          side: BorderSide(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                        ),
                        child: const Text('Manage Key'),
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
