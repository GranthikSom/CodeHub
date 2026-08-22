import 'package:flutter/material.dart';
import '../services/codehub_state.dart';

class SettingsScreen extends StatefulWidget {
  final CodeHubState state;

  const SettingsScreen({super.key, required this.state});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Account',
      'icon': Icons.person_outline,
      'color': const Color(0xFF58A6FF),
      'subItems': ['Profile', 'Account', 'Email & Verification', 'Password', 'Connected Accounts'],
    },
    {
      'title': 'Security',
      'icon': Icons.security,
      'color': const Color(0xFF3FB950),
      'subItems': [
        'Two-Factor Authentication',
        'Active Sessions',
        'Devices',
        'SSH Keys',
        'Access Tokens',
        'API Keys',
        'Security Activity'
      ],
    },
    {
      'title': 'P2P Network',
      'icon': Icons.hub_outlined,
      'color': const Color(0xFFBC8CFF),
      'subItems': [
        'Network Preferences',
        'Peer Identity',
        'Peer Discovery',
        'NAT / Relay',
        'Bandwidth',
        'Connection Limits',
        'Network Privacy'
      ],
    },
    {
      'title': 'Storage',
      'icon': Icons.storage_outlined,
      'color': const Color(0xFFD29922),
      'subItems': [
        'Storage Allocation',
        'Repository Pinning',
        'Cache',
        'Garbage Collection',
        'Storage Policies'
      ],
    },
    {
      'title': 'Replication',
      'icon': Icons.sync_outlined,
      'color': const Color(0xFF38BDF8),
      'subItems': [
        'Default Replicas',
        'Repository Replication',
        'Preferred Nodes',
        'Auto Replication',
        'Replication Priority'
      ],
    },
    {
      'title': 'Device',
      'icon': Icons.desktop_windows_outlined,
      'color': const Color(0xFFF78166),
      'subItems': [
        'Device Information',
        'Device Name',
        'Background Service',
        'Startup',
        'Battery',
        'Resource Limits'
      ],
    },
    {
      'title': 'Notifications',
      'icon': Icons.notifications_outlined,
      'color': const Color(0xFFA5D6FF),
      'subItems': [
        'Repository',
        'Pull Requests',
        'Issues',
        'Mentions',
        'P2P Events',
        'Security Alerts'
      ],
    },
    {
      'title': 'Appearance',
      'icon': Icons.palette_outlined,
      'color': const Color(0xFFDB61A2),
      'subItems': ['Theme', 'Accent Color', 'Interface Density', 'Animations'],
    },
    {
      'title': 'Developer',
      'icon': Icons.code_outlined,
      'color': const Color(0xFF7EE787),
      'subItems': [
        'Git Configuration',
        'CLI',
        'SSH',
        'API',
        'Webhooks',
        'Git Signing'
      ],
    },
    {
      'title': 'Privacy',
      'icon': Icons.lock_outline,
      'color': const Color(0xFF79C0FF),
      'subItems': [
        'Profile Visibility',
        'Activity Visibility',
        'Repository Discovery',
        'Peer Visibility',
        'Data Sharing'
      ],
    },
    {
      'title': 'Data & Cache',
      'icon': Icons.cleaning_services_outlined,
      'color': const Color(0xFFFFA657),
      'subItems': [
        'Clear Cache',
        'Local Data',
        'Downloaded Objects',
        'Temporary Files',
        'Export Data'
      ],
    },
    {
      'title': 'Danger Zone',
      'icon': Icons.warning_amber_rounded,
      'color': const Color(0xFFF85149),
      'subItems': [
        'Revoke All Sessions',
        'Remove Device',
        'Delete Account',
        'Delete Local Data'
      ],
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentCategory = _categories[_selectedCategoryIndex];

    final filteredCategories = _searchQuery.isEmpty
        ? _categories
        : _categories.where((cat) {
            final titleMatch = (cat['title'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
            final subMatch = (cat['subItems'] as List<String>).any((sub) => sub.toLowerCase().contains(_searchQuery.toLowerCase()));
            return titleMatch || subMatch;
          }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FA),
      body: Row(
        children: [
          // Left Settings Category Sidebar
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : Colors.white,
              border: Border(
                right: BorderSide(
                  color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _searchController,
                        style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Search settings...',
                          hintStyle: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
                          prefixIcon: const Icon(Icons.search, size: 18),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
                            ),
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, idx) {
                      final cat = filteredCategories[idx];
                      final realIndex = _categories.indexOf(cat);
                      final isSelected = realIndex == _selectedCategoryIndex;
                      final Color catColor = cat['color'];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              setState(() {
                                _selectedCategoryIndex = realIndex;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? catColor.withValues(alpha: 0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: isSelected
                                    ? Border.all(color: catColor.withValues(alpha: 0.4))
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    cat['icon'],
                                    size: 20,
                                    color: isSelected ? catColor : (isDark ? const Color(0xFF8B949E) : Colors.grey.shade700),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      cat['title'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected
                                            ? (isDark ? Colors.white : catColor)
                                            : (isDark ? const Color(0xFFC9D1D9) : Colors.black87),
                                      ),
                                    ),
                                  ),
                                  if (cat['title'] == 'Danger Zone')
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF85149).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        '!',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFF85149),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Right Settings Content View Panel
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (currentCategory['color'] as Color).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          currentCategory['icon'],
                          color: currentCategory['color'],
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentCategory['title'],
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'Manage your sovereign ${currentCategory['title'].toString().toLowerCase()} preferences and system configurations.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 20),

                  // Sub-Item Quick Navigation Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (currentCategory['subItems'] as List<String>).map((sub) {
                      return Chip(
                        label: Text(sub, style: const TextStyle(fontSize: 12)),
                        avatar: Icon(Icons.subdirectory_arrow_right, size: 14, color: currentCategory['color']),
                        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.grey.shade100,
                        side: BorderSide(
                          color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // Category Specific Detail Form & Controls
                  _buildCategoryDetailView(context, currentCategory['title']),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDetailView(BuildContext context, String categoryTitle) {
    switch (categoryTitle) {
      case 'Account':
        return _buildAccountSettings(context);
      case 'Security':
        return _buildSecuritySettings(context);
      case 'P2P Network':
        return _buildP2PNetworkSettings(context);
      case 'Storage':
        return _buildStorageSettings(context);
      case 'Replication':
        return _buildReplicationSettings(context);
      case 'Device':
        return _buildDeviceSettings(context);
      case 'Notifications':
        return _buildNotificationSettings(context);
      case 'Appearance':
        return _buildAppearanceSettings(context);
      case 'Developer':
        return _buildDeveloperSettings(context);
      case 'Privacy':
        return _buildPrivacySettings(context);
      case 'Data & Cache':
        return _buildDataCacheSettings(context);
      case 'Danger Zone':
        return _buildDangerZoneSettings(context);
      default:
        return _buildGenericSettingsPlaceholder(context, categoryTitle);
    }
  }

  // ---------------------------------------------------------------------------
  // 1. Account Settings View
  // ---------------------------------------------------------------------------
  Widget _buildAccountSettings(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('👤 Profile', 'Public details visible to peer collaborators.'),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
              child: const Text('SM', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload, size: 16),
                  label: const Text('Change Avatar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF21262D) : Colors.grey.shade200,
                    foregroundColor: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text('JPG, PNG or GIF. Max 5MB.', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildTextField('Display Name', 'Soham Mondal'),
        const SizedBox(height: 16),
        _buildTextField('Bio', 'Sovereign P2P Infrastructure Developer & Systems Engineer.'),
        const SizedBox(height: 16),
        _buildTextField('Public Email', 'soham@codehub.io'),
        const SizedBox(height: 32),

        _buildSectionHeader('Account & Identity', 'Username and ownership attributes.'),
        const SizedBox(height: 16),
        _buildTextField('Username', '@GranthikSom', enabled: false),
        const SizedBox(height: 16),
        _buildTextField('Account ID', 'usr_9f83a2c077b10', enabled: false),
        const SizedBox(height: 32),

        _buildSectionHeader('Email & Verification', 'Manage registered email addresses.'),
        const SizedBox(height: 12),
        _buildInfoCard(
          icon: Icons.mark_email_read,
          title: 'Primary Email: soham@codehub.io',
          subtitle: 'Verified • Received P2P security notifications.',
          color: const Color(0xFF3FB950),
        ),
        const SizedBox(height: 32),

        _buildSectionHeader('Connected Accounts', 'Linked identity providers and Web3 wallets.'),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.code, color: Colors.purpleAccent),
          title: const Text('GitHub Account Connected'),
          subtitle: const Text('@GranthikSom (Synced 42 Repositories)'),
          trailing: OutlinedButton(onPressed: () {}, child: const Text('Disconnect')),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.account_balance_wallet_outlined, color: Colors.orangeAccent),
          title: const Text('Web3 Wallet / ENS Identity'),
          subtitle: const Text('soham.eth (0x71C...49A)'),
          trailing: OutlinedButton(onPressed: () {}, child: const Text('Manage Wallet')),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Security Settings View
  // ---------------------------------------------------------------------------
  Widget _buildSecuritySettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('🔐 Two-Factor Authentication (2FA)', 'Protect your sovereign developer account.'),
        const SizedBox(height: 12),
        _buildInfoCard(
          icon: Icons.verified_user,
          title: 'TOTP Authenticator App: Enabled',
          subtitle: 'YubiKey WebAuthn / FIDO2 security key active.',
          color: const Color(0xFF3FB950),
        ),
        const SizedBox(height: 24),

        _buildSectionHeader('🔑 SSH & Signing Keys', 'Keys authorized to push DAG commits to P2P swarm.'),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.vpn_key_outlined, color: Colors.blueAccent),
          title: const Text('ed25519-sk-soham-laptop'),
          subtitle: const Text('SHA256:4a8f9c...01e9a • Added 3 days ago'),
          trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () {}),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add New SSH Key'),
        ),
        const SizedBox(height: 32),

        _buildSectionHeader('🎟️ Access Tokens & API Keys', 'Personal Access Tokens (PATs) for CLI & API engine.'),
        const SizedBox(height: 12),
        _buildInfoCard(
          icon: Icons.key_outlined,
          title: 'Active PAT: codehub_pat_live_99831',
          subtitle: 'Scopes: repo:read, write:packages, swarm:pin • Expires in 89 days',
          color: const Color(0xFFBC8CFF),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 3. P2P Network Settings View
  // ---------------------------------------------------------------------------
  Widget _buildP2PNetworkSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('🌐 Network Preferences & Protocol Stack', 'Configure libp2p transport & NAT traversal.'),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Enable Sovereign P2P Swarm Engine'),
          subtitle: const Text('Directly exchange repository objects with participating peer devices'),
          value: true,
          onChanged: (val) {},
        ),
        SwitchListTile(
          title: const Text('UPnP / NAT-PMP Port Forwarding'),
          subtitle: const Text('Automatically open TCP/UDP port 4001 on local router'),
          value: true,
          onChanged: (val) {},
        ),
        const SizedBox(height: 24),

        _buildSectionHeader('🆔 Peer Identity Keypair', 'Your cryptographic Ed25519 node ID on Kademlia DHT.'),
        const SizedBox(height: 12),
        _buildTextField('Node Peer ID', '12D3KooWControlRelayServer99aF81c', enabled: false),
        const SizedBox(height: 12),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_outlined, size: 16),
              label: const Text('Export Private Key'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Regenerate Peer ID'),
            ),
          ],
        ),
        const SizedBox(height: 32),

        _buildSectionHeader('⚡ Connection Limits & Bandwidth', 'Throttle network resources for background seeding.'),
        const SizedBox(height: 16),
        Text('Max Upload Limit: ${widget.state.uploadLimitMbps.toInt()} Mbps'),
        Slider(
          value: widget.state.uploadLimitMbps,
          min: 1,
          max: 100,
          divisions: 99,
          label: '${widget.state.uploadLimitMbps.toInt()} Mbps',
          onChanged: (val) => widget.state.setUploadLimit(val),
        ),
        const SizedBox(height: 12),
        Text('Max Active Peer Connections: ${widget.state.maxPeersLimit} Peers'),
        Slider(
          value: widget.state.maxPeersLimit.toDouble(),
          min: 5,
          max: 100,
          divisions: 95,
          label: '${widget.state.maxPeersLimit} Peers',
          onChanged: (val) => widget.state.setMaxPeersLimit(val.toInt()),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Storage Settings View
  // ---------------------------------------------------------------------------
  Widget _buildStorageSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('💾 Local Storage Quota & Allocation', 'Disk space contributed to seed P2P DAG objects.'),
        const SizedBox(height: 16),
        _buildInfoCard(
          icon: Icons.sd_storage_outlined,
          title: 'Storage Used: ${widget.state.storageUsedGb} GB / ${widget.state.storageContributedGb} GB Allocated',
          subtitle: 'Reclaimable candidate objects: ${widget.state.reclaimableGb} GB (${widget.state.gcCandidateCount} chunks)',
          color: const Color(0xFFD29922),
        ),
        const SizedBox(height: 20),
        Text('Allocated Seeding Quota: ${widget.state.storageContributedGb.toInt()} GB'),
        Slider(
          value: widget.state.storageContributedGb.clamp(5.0, 200.0),
          min: 5,
          max: 200,
          divisions: 39,
          label: '${widget.state.storageContributedGb.toInt()} GB',
          onChanged: (val) => widget.state.setStoragePreset(StoragePreset.custom, customGb: val),
        ),
        const SizedBox(height: 24),

        _buildSectionHeader('🧹 Garbage Collection & Pruning', 'Reclaim unused object blobs past the 30-day grace period.'),
        const SizedBox(height: 12),
        Text('Status: ${widget.state.gcLastStatus}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: widget.state.isGcRunning ? null : () => widget.state.triggerGarbageCollection(),
          icon: widget.state.isGcRunning
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.cleaning_services, size: 16),
          label: Text(widget.state.isGcRunning ? 'Running Garbage Collector...' : 'Run Garbage Collector Now'),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Replication Settings View
  // ---------------------------------------------------------------------------
  Widget _buildReplicationSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('🔄 Replication Guarantee Policies', 'Configure swarm peer redundancy thresholds.'),
        const SizedBox(height: 16),
        _buildInfoCard(
          icon: Icons.health_and_safety_outlined,
          title: 'Target Peer Replica Count: 3 Replicas Minimum',
          subtitle: 'Auto-replication active across participating seeders.',
          color: const Color(0xFF38BDF8),
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          title: const Text('Auto-Replicate Pinned Repositories'),
          subtitle: const Text('Background push object chunks when connected to high-speed Ethernet/Wi-Fi'),
          value: true,
          onChanged: (val) {},
        ),
        SwitchListTile(
          title: const Text('Priority Seed Owner Repositories'),
          subtitle: const Text('Give maximum upload bandwidth to your personal repositories'),
          value: true,
          onChanged: (val) {},
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 6. Device Settings View
  // ---------------------------------------------------------------------------
  Widget _buildDeviceSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('🖥️ Device Information & Resource Limits', 'Local machine characteristics and daemon options.'),
        const SizedBox(height: 16),
        _buildTextField('Device Name', "Soham's VivoBook Laptop (ASUS K3402ZA)"),
        const SizedBox(height: 16),
        _buildTextField('Host Operating System', 'Linux Ubuntu 26.04 LTS (x86_64 Kernel 7.0.0)', enabled: false),
        const SizedBox(height: 24),
        SwitchListTile(
          title: const Text('Run Engine on System Startup'),
          subtitle: const Text('Start background P2P seeder service automatically on boot'),
          value: true,
          onChanged: (val) {},
        ),
        SwitchListTile(
          title: const Text('Pause Seeding on Battery Power'),
          subtitle: const Text('Save battery when unplugged from power outlet'),
          value: widget.state.seedOnBattery,
          onChanged: (val) => widget.state.setSeedOnBattery(val),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 7. Notification Settings View
  // ---------------------------------------------------------------------------
  Widget _buildNotificationSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('🔔 System & Swarm Alerts', 'Manage desktop notifications & emails.'),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Pull Request & Code Review Alerts'),
          subtitle: const Text('Notify when someone requests review or merges a branch'),
          value: true,
          onChanged: (val) {},
        ),
        SwitchListTile(
          title: const Text('Issues & Direct Mentions (@username)'),
          subtitle: const Text('Notify when mentioned in repository discussions'),
          value: true,
          onChanged: (val) {},
        ),
        SwitchListTile(
          title: const Text('P2P Swarm Network Alerts'),
          subtitle: const Text('Alert when repository replica count drops below health threshold'),
          value: true,
          onChanged: (val) {},
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 8. Appearance Settings View
  // ---------------------------------------------------------------------------
  Widget _buildAppearanceSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('🎨 UI Themes & Visual Styles', 'Customize your CodeHub desktop look and feel.'),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Dark Mode Interface'),
          subtitle: const Text('Use high-contrast GitHub dark theme palette'),
          value: widget.state.isDarkMode,
          onChanged: (val) => widget.state.toggleThemeMode(),
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('Accent Color Palette', 'Primary highlight color across navigation & buttons.'),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildColorChip(const Color(0xFF58A6FF), 'Electric Blue', true),
            const SizedBox(width: 12),
            _buildColorChip(const Color(0xFF3FB950), 'Emerald Green', false),
            const SizedBox(width: 12),
            _buildColorChip(const Color(0xFFBC8CFF), 'Cyber Purple', false),
            const SizedBox(width: 12),
            _buildColorChip(const Color(0xFFD29922), 'Amber', false),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 9. Developer Settings View
  // ---------------------------------------------------------------------------
  Widget _buildDeveloperSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('🧑💻 Git & CLI Configuration', 'Local Git integration and developer tools.'),
        const SizedBox(height: 16),
        _buildTextField('Git User Name', 'Soham Mondal'),
        const SizedBox(height: 16),
        _buildTextField('Git User Email', 'soham@codehub.io'),
        const SizedBox(height: 24),
        SwitchListTile(
          title: const Text('Require GPG / Ed25519 Commit Signing'),
          subtitle: const Text('Auto-sign all DAG commits created via CodeHub desktop interface'),
          value: true,
          onChanged: (val) {},
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 10. Privacy Settings View
  // ---------------------------------------------------------------------------
  Widget _buildPrivacySettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('🔒 Privacy & Peer Visibility', 'Control your discovery exposure on Kademlia DHT.'),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Public Profile Visibility'),
          subtitle: const Text('Allow peers to view your public repositories & profile info'),
          value: true,
          onChanged: (val) {},
        ),
        SwitchListTile(
          title: const Text('Stealth Mode (Hide Peer Online Status)'),
          subtitle: const Text('Participate in swarm seeding without broadcasting node IP to public indexers'),
          value: false,
          onChanged: (val) {},
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 11. Data & Cache Settings View
  // ---------------------------------------------------------------------------
  Widget _buildDataCacheSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('🧹 Data & Cache Management', 'Clear temporary object packfiles and local state.'),
        const SizedBox(height: 16),
        _buildInfoCard(
          icon: Icons.folder_zip_outlined,
          title: 'Local Blockstore Database: 17.2 GB',
          subtitle: 'Cached SHA-256 Blobs & DAG indices.',
          color: const Color(0xFFFFA657),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.delete_sweep, size: 16, color: Colors.orangeAccent),
          label: const Text('Clear Temporary Object Cache (340 MB)'),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 12. Danger Zone Settings View
  // ---------------------------------------------------------------------------
  Widget _buildDangerZoneSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('⚠️ Danger Zone', 'Irreversible actions for account & local data.'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF85149).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFF85149).withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Revoke All Active Sessions', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: const Text('Force logout across all registered desktop & web devices.', style: TextStyle(color: Colors.white60)),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF85149), foregroundColor: Colors.white),
                  onPressed: () {},
                  child: const Text('Revoke Sessions'),
                ),
              ),
              const Divider(color: Color(0xFFF85149)),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Remove Local Device Node', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: const Text('Deregister local peer node identity from P2P swarm.', style: TextStyle(color: Colors.white60)),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF85149), foregroundColor: Colors.white),
                  onPressed: () {},
                  child: const Text('Remove Device'),
                ),
              ),
              const Divider(color: Color(0xFFF85149)),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Delete Sovereign Account', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: const Text('Permanently purge user identity, repositories, and credentials.', style: TextStyle(color: Colors.white60)),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF85149), foregroundColor: Colors.white),
                  onPressed: () {},
                  child: const Text('Delete Account'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Helper Widgets
  // ---------------------------------------------------------------------------
  Widget _buildSectionHeader(String title, String subtitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String value, {bool enabled = true}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFFC9D1D9) : Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          enabled: enabled,
          style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled
                ? (isDark ? const Color(0xFF161B22) : Colors.white)
                : (isDark ? const Color(0xFF0D1117) : Colors.grey.shade100),
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorChip(Color color, String label, bool isSelected) {
    return Chip(
      avatar: CircleAvatar(backgroundColor: color, radius: 6),
      label: Text(label),
      backgroundColor: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
      side: BorderSide(color: isSelected ? color : Colors.grey.shade600),
    );
  }

  Widget _buildGenericSettingsPlaceholder(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title, 'Configuration options for $title.'),
        const SizedBox(height: 20),
        _buildInfoCard(
          icon: Icons.tune,
          title: '$title Preferences Enabled',
          subtitle: 'All default $title parameters synced with native P2P engine.',
          color: Colors.blueAccent,
        ),
      ],
    );
  }
}
