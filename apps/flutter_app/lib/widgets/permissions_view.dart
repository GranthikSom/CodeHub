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

class _PermissionsViewState extends State<PermissionsView> with SingleTickerProviderStateMixin {
  late TabController _subTabController;

  // Collaborators List
  final List<Map<String, String>> _collaborators = [
    {'handle': '@soham', 'name': 'Soham Mondal', 'role': 'Owner'},
    {'handle': '@rahul', 'name': 'Rahul Sharma', 'role': 'Maintainer'},
    {'handle': '@developer1', 'name': 'Alex Developer', 'role': 'Developer'},
    {'handle': '@designer1', 'name': 'Elena Designer', 'role': 'Viewer'},
    {'handle': '@GranthikSom', 'name': 'Granthik Som', 'role': 'Owner'},
  ];

  // Teams List
  final List<Map<String, String>> _teams = [
    {'name': '@core-team', 'members': '8 members', 'permission': 'Admin'},
    {'name': '@frontend-devs', 'members': '14 members', 'permission': 'Write'},
    {'name': '@security-auditors', 'members': '4 members', 'permission': 'Read'},
  ];

  // Deploy Keys List
  final List<Map<String, dynamic>> _deployKeys = [
    {
      'title': 'Production Server Runner (ec2-us-east-1)',
      'fingerprint': 'SHA256:e94a8...d9921 (Ed25519)',
      'readOnly': false,
      'created': 'Added 12 days ago',
    },
    {
      'title': 'CI/CD Build Pipeline (GitHub Actions)',
      'fingerprint': 'SHA256:7721c...a1109 (RSA 4096)',
      'readOnly': true,
      'created': 'Added 1 month ago',
    },
  ];

  // Access Tokens List
  final List<Map<String, dynamic>> _accessTokens = [
    {
      'name': 'P2P CLI Daemon Token',
      'token': 'chp_live_89a42...99f01',
      'scopes': ['repo:read', 'repo:write', 'p2p:seed'],
      'expires': 'Expires in 28 days',
    },
    {
      'name': 'VS Code Integration Key',
      'token': 'chp_live_3310b...a4412',
      'scopes': ['repo:read'],
      'expires': 'Expires in 90 days',
    },
  ];

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  void _showAddCollaboratorDialog() {
    final handleController = TextEditingController();
    String selectedRole = 'Developer';

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF58A6FF)),
              SizedBox(width: 10),
              Text('Add Collaborator'),
            ],
          ),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: handleController,
                  decoration: const InputDecoration(
                    labelText: 'Username or Peer Handle (e.g. @developer2)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                StatefulBuilder(
                  builder: (context, setDialogState) {
                    return DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      items: const [
                        DropdownMenuItem(value: 'Viewer', child: Text('Viewer (Read access)')),
                        DropdownMenuItem(value: 'Developer', child: Text('Developer (Read & Write access)')),
                        DropdownMenuItem(value: 'Maintainer', child: Text('Maintainer (Write, Merge & Manage)')),
                        DropdownMenuItem(value: 'Owner', child: Text('Owner / Admin (Full Repository Access)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedRole = val);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Permission Level',
                        border: OutlineInputBorder(),
                      ),
                    );
                  },
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
                if (handleController.text.isNotEmpty) {
                  final handle = handleController.text.startsWith('@')
                      ? handleController.text
                      : '@${handleController.text}';
                  setState(() {
                    _collaborators.add({
                      'handle': handle,
                      'name': handle.replaceAll('@', ''),
                      'role': selectedRole,
                    });
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added $handle as $selectedRole'),
                      backgroundColor: const Color(0xFF238636),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Add Collaborator'),
            ),
          ],
        );
      },
    );
  }

  void _showAddDeployKeyDialog() {
    final titleController = TextEditingController();
    final keyController = TextEditingController();
    bool readOnly = true;

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.key_rounded, color: Color(0xFFBC8CFF)),
              SizedBox(width: 10),
              Text('Add Deploy Key'),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Key Title',
                        hintText: 'e.g. Staging Server Key',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: keyController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Public Key Data (ssh-ed25519 ...)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: const Text('Allow write access', style: TextStyle(fontSize: 13)),
                      subtitle: const Text('If unchecked, key will be limited to read-only sync.', style: TextStyle(fontSize: 11)),
                      value: !readOnly,
                      onChanged: (val) {
                        setDialogState(() => readOnly = !(val ?? false));
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
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
                    _deployKeys.add({
                      'title': titleController.text,
                      'fingerprint': 'SHA256:9901f...${DateTime.now().millisecondsSinceEpoch.toString().substring(9)} (Ed25519)',
                      'readOnly': readOnly,
                      'created': 'Added just now',
                    });
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add Deploy Key'),
            ),
          ],
        );
      },
    );
  }

  void _showGenerateTokenDialog() {
    final tokenNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.token_rounded, color: Color(0xFFD29922)),
              SizedBox(width: 10),
              Text('Generate Access Token'),
            ],
          ),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tokenNameController,
                  decoration: const InputDecoration(
                    labelText: 'Token Name',
                    hintText: 'e.g. Node Sync Key',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Default Scopes: repo:read, repo:write, p2p:seed (Valid for 30 days)',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF238636),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (tokenNameController.text.isNotEmpty) {
                  setState(() {
                    _accessTokens.add({
                      'name': tokenNameController.text,
                      'token': 'chp_live_${DateTime.now().millisecondsSinceEpoch}a',
                      'scopes': ['repo:read', 'repo:write'],
                      'expires': 'Expires in 30 days',
                    });
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Generate Token'),
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
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            children: [
              const Icon(Icons.admin_panel_settings_outlined, color: Color(0xFF58A6FF), size: 26),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Repository Settings ➔ Access & Permissions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    'Manage collaborators, roles (Read/Write/Maintain/Admin), teams, deploy keys, and access tokens',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Navigation Sub-TabBar
          TabBar(
            controller: _subTabController,
            isScrollable: true,
            labelColor: const Color(0xFF58A6FF),
            unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
            indicatorColor: const Color(0xFF58A6FF),
            tabs: const [
              Tab(text: 'Collaborators'),
              Tab(text: 'Permissions Matrix'),
              Tab(text: 'Teams'),
              Tab(text: 'Organizations'),
              Tab(text: 'Deploy Keys'),
              Tab(text: 'Access Tokens'),
            ],
          ),

          const SizedBox(height: 20),

          // Sub-Tab Views
          Expanded(
            child: TabBarView(
              controller: _subTabController,
              children: [
                // 1. Collaborators View
                _buildCollaboratorsTab(isDark),

                // 2. Permissions RBAC Matrix View
                _buildPermissionsMatrixTab(isDark),

                // 3. Teams View
                _buildTeamsTab(isDark),

                // 4. Organizations View
                _buildOrganizationsTab(isDark),

                // 5. Deploy Keys View
                _buildDeployKeysTab(isDark),

                // 6. Personal Access Tokens View
                _buildAccessTokensTab(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. Collaborators Tab Component
  Widget _buildCollaboratorsTab(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Repository Collaborators (${_collaborators.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _showAddCollaboratorDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF238636),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
              label: const Text('Add Collaborator'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ListView.builder(
            itemCount: _collaborators.length,
            itemBuilder: (ctx, index) {
              final c = _collaborators[index];
              final role = c['role']!;

              Color roleColor = const Color(0xFF58A6FF);
              if (role == 'Owner') roleColor = const Color(0xFFBC8CFF);
              if (role == 'Maintainer') roleColor = const Color(0xFF3FB950);
              if (role == 'Viewer') roleColor = const Color(0xFFD29922);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161B22) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: roleColor.withValues(alpha: 0.2),
                      child: Text(
                        c['handle']!.substring(1, 2).toUpperCase(),
                        style: TextStyle(fontWeight: FontWeight.bold, color: roleColor),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                c['handle']!,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                c['name']!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Access: $role Level Permissions',
                            style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    DropdownButton<String>(
                      value: role,
                      underline: const SizedBox(),
                      dropdownColor: isDark ? const Color(0xFF161B22) : Colors.white,
                      items: const [
                        DropdownMenuItem(value: 'Owner', child: Text('Owner')),
                        DropdownMenuItem(value: 'Maintainer', child: Text('Maintainer')),
                        DropdownMenuItem(value: 'Developer', child: Text('Developer')),
                        DropdownMenuItem(value: 'Viewer', child: Text('Viewer')),
                      ],
                      onChanged: (newRole) {
                        if (newRole != null) {
                          setState(() {
                            c['role'] = newRole;
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      onPressed: () {
                        setState(() {
                          _collaborators.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 2. Permissions RBAC Matrix View
  Widget _buildPermissionsMatrixTab(bool isDark) {
    return ListView(
      children: [
        Text(
          'Role-Based Access Control (RBAC) Matrix',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Summary of actions permitted for each collaborator role level',
          style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        Table(
          border: TableBorder.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
          children: [
            TableRow(
              decoration: BoxDecoration(color: isDark ? const Color(0xFF161B22) : Colors.grey.shade200),
              children: [
                _buildTableCell('Capability / Action', isHeader: true, isDark: isDark),
                _buildTableCell('Read (Viewer)', isHeader: true, isDark: isDark),
                _buildTableCell('Write (Developer)', isHeader: true, isDark: isDark),
                _buildTableCell('Maintain (Maintainer)', isHeader: true, isDark: isDark),
                _buildTableCell('Admin (Owner)', isHeader: true, isDark: isDark),
              ],
            ),
            _buildMatrixRow('Clone / Pull Repository Code', true, true, true, true, isDark),
            _buildMatrixRow('View Issues & Pull Requests', true, true, true, true, isDark),
            _buildMatrixRow('Push Code to Feature Branches', false, true, true, true, isDark),
            _buildMatrixRow('Create Pull Requests & Issues', false, true, true, true, isDark),
            _buildMatrixRow('Merge Pull Requests to Main', false, false, true, true, isDark),
            _buildMatrixRow('Manage Release Tags & Binaries', false, false, true, true, isDark),
            _buildMatrixRow('Add / Remove Collaborators', false, false, false, true, isDark),
            _buildMatrixRow('Manage Deploy Keys & PATs', false, false, false, true, isDark),
            _buildMatrixRow('Delete or Transfer Repository', false, false, false, true, isDark),
          ],
        ),
      ],
    );
  }

  TableRow _buildMatrixRow(String capability, bool read, bool write, bool maintain, bool admin, bool isDark) {
    return TableRow(
      children: [
        _buildTableCell(capability, isDark: isDark),
        _buildTableCellIcon(read),
        _buildTableCellIcon(write),
        _buildTableCellIcon(maintain),
        _buildTableCellIcon(admin),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader
              ? (isDark ? const Color(0xFF58A6FF) : Colors.blue.shade800)
              : (isDark ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildTableCellIcon(bool allowed) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Icon(
        allowed ? Icons.check_circle_rounded : Icons.cancel_outlined,
        color: allowed ? const Color(0xFF3FB950) : Colors.grey.shade500,
        size: 18,
      ),
    );
  }

  // 3. Teams Tab Component
  Widget _buildTeamsTab(bool isDark) {
    return ListView(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Organization Teams Access',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF238636), foregroundColor: Colors.white),
              icon: const Icon(Icons.group_add_rounded, size: 16),
              label: const Text('Add Team'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ..._teams.map((t) {
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
                const Icon(Icons.groups_outlined, color: Color(0xFFBC8CFF), size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t['name']!, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                      const SizedBox(height: 4),
                      Text('${t['members']} • Permission: ${t['permission']}', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54)),
                    ],
                  ),
                ),
                OutlinedButton(onPressed: () {}, child: const Text('Manage Team')),
              ],
            ),
          );
        }),
      ],
    );
  }

  // 4. Organizations Tab Component
  Widget _buildOrganizationsTab(bool isDark) {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.corporate_fare_rounded, color: Color(0xFF58A6FF), size: 26),
                  const SizedBox(width: 12),
                  Text('CodeHub Organization Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'This repository belongs to the GranthikSom Organization. Default permissions apply to all organization members unless overridden.',
                style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF58A6FF), foregroundColor: Colors.white),
                    child: const Text('Transfer Ownership'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Configure SAML SSO'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 5. Deploy Keys Tab Component
  Widget _buildDeployKeysTab(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Deploy Keys (${_deployKeys.length})',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
            ),
            ElevatedButton.icon(
              onPressed: _showAddDeployKeyDialog,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF238636), foregroundColor: Colors.white),
              icon: const Icon(Icons.key_rounded, size: 16),
              label: const Text('Add Deploy Key'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ListView.builder(
            itemCount: _deployKeys.length,
            itemBuilder: (ctx, index) {
              final key = _deployKeys[index];
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
                    const Icon(Icons.vpn_key_outlined, color: Color(0xFFBC8CFF), size: 22),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(key['title'] as String, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                          const SizedBox(height: 4),
                          Text('${key['fingerprint']} • ${key['created']}', style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (key['readOnly'] as bool ? const Color(0xFFD29922) : const Color(0xFF3FB950)).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: key['readOnly'] as bool ? const Color(0xFFD29922) : const Color(0xFF3FB950)),
                      ),
                      child: Text(
                        key['readOnly'] as bool ? 'Read-only' : 'Read/Write',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: key['readOnly'] as bool ? const Color(0xFFD29922) : const Color(0xFF3FB950)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      onPressed: () => setState(() => _deployKeys.removeAt(index)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 6. Access Tokens Tab Component
  Widget _buildAccessTokensTab(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Personal Access Tokens (PATs)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
            ),
            ElevatedButton.icon(
              onPressed: _showGenerateTokenDialog,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF238636), foregroundColor: Colors.white),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Generate New Token'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ListView.builder(
            itemCount: _accessTokens.length,
            itemBuilder: (ctx, index) {
              final tok = _accessTokens[index];
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
                    const Icon(Icons.password_rounded, color: Color(0xFFD29922), size: 22),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tok['name'] as String, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                          const SizedBox(height: 4),
                          Text('Token: ${tok['token']} • ${tok['expires']}', style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600)),
                          const SizedBox(height: 6),
                          Row(
                            children: (tok['scopes'] as List<String>).map((s) {
                              return Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF21262D) : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(s, style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Color(0xFF58A6FF))),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      onPressed: () => setState(() => _accessTokens.removeAt(index)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
