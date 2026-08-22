import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/codehub_state.dart';
import 'splash_screen.dart';

class SettingsScreen extends StatefulWidget {
  final CodeHubState state;

  const SettingsScreen({super.key, required this.state});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedCategoryIndex = 0;
  int _profileSubTab = 0; // 0: Profile Details, 1: Profile README.md, 2: Pinned Repos, 3: Live Preview
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Form Controllers
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  late TextEditingController _emailController;
  late TextEditingController _deviceNameController;
  late TextEditingController _gitNameController;
  late TextEditingController _gitEmailController;

  // GitHub Profile Customization Controllers
  late TextEditingController _statusEmojiController;
  late TextEditingController _statusTextController;
  late TextEditingController _companyController;
  late TextEditingController _locationController;
  late TextEditingController _websiteController;
  late TextEditingController _twitterController;
  late TextEditingController _readmeController;
  bool _enableProfileReadme = true;

  final List<Map<String, dynamic>> _pinnedRepoItems = [
    {
      'id': 'codehub-engine',
      'name': 'codehub-engine',
      'desc': 'Sovereign P2P git replication & Kademlia DHT blockstore engine in Rust.',
      'lang': 'Rust',
      'langColor': const Color(0xFFDEA584),
      'stars': 142,
      'forks': 28,
      'isPinned': true,
    },
    {
      'id': 'libp2p-rust-core',
      'name': 'libp2p-rust-core',
      'desc': 'Custom Noise-TLS transport layer and NAT-PMP hole punching protocol stack.',
      'lang': 'Rust',
      'langColor': const Color(0xFFDEA584),
      'stars': 98,
      'forks': 14,
      'isPinned': true,
    },
    {
      'id': 'codehub-flutter-app',
      'name': 'codehub-flutter-app',
      'desc': 'High-performance Flutter Desktop GUI for managing P2P swarms & repositories.',
      'lang': 'Dart',
      'langColor': const Color(0xFF00B4AB),
      'stars': 76,
      'forks': 11,
      'isPinned': true,
    },
    {
      'id': 'sovereign-storage-cluster',
      'name': 'sovereign-storage-cluster',
      'desc': 'Multi-node dedicated storage cluster pinning daemon and garbage collection worker.',
      'lang': 'Rust',
      'langColor': const Color(0xFFDEA584),
      'stars': 54,
      'forks': 8,
      'isPinned': true,
    },
    {
      'id': 'dag-chunk-verifier',
      'name': 'dag-chunk-verifier',
      'desc': 'SHA-256 Merkle DAG chunk integrity verification and delta sync suite.',
      'lang': 'C++',
      'langColor': const Color(0xFFF34B7D),
      'stars': 39,
      'forks': 5,
      'isPinned': false,
    },
  ];

  // Interactive Security Lists State
  final List<Map<String, String>> _sshKeys = [
    {
      'title': 'ed25519-sk-soham-laptop',
      'fp': 'SHA256:4a8f9c9b1a203f4e5d6c7b8a901e9a',
      'added': 'Added 3 days ago',
    },
    {
      'title': 'id_rsa_workstation',
      'fp': 'SHA256:99f1a2b3c4d5e6f7a8b9c0d1e2f3a4',
      'added': 'Added 2 weeks ago',
    },
  ];

  final List<Map<String, String>> _accessTokens = [
    {
      'name': 'codehub_pat_live_99831',
      'scopes': 'repo:read, write:packages, swarm:pin',
      'expires': 'Expires in 89 days',
    },
  ];

  // Settings State Toggles
  bool _p2pSwarmEnabled = true;
  bool _upnpPortForwarding = true;
  bool _autoReplicatePinned = true;
  bool _prioritySeedOwner = true;
  bool _runOnStartup = true;
  bool _notifyPullRequests = true;
  bool _notifyIssues = true;
  bool _notifyP2PAlerts = true;
  bool _notifySecurity = true;
  bool _requireCommitSigning = true;
  bool _publicProfileVisibility = true;
  bool _stealthMode = false;
  int _targetReplicaCount = 3;
  String _selectedAccentColor = 'Electric Blue';

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Account',
      'icon': Icons.person_outline,
      'color': const Color(0xFF58A6FF),
      'subItems': ['Profile & README', 'Account', 'Email & Verification', 'Password', 'Connected Accounts'],
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
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.state.api.currentUsername ?? 'Soham Mondal');
    _bioController = TextEditingController(text: 'Sovereign P2P Infrastructure Developer & Systems Engineer.');
    _emailController = TextEditingController(text: widget.state.api.currentEmail ?? 'soham@codehub.io');
    _deviceNameController = TextEditingController(text: "Soham's VivoBook Laptop (ASUS K3402ZA)");
    _gitNameController = TextEditingController(text: 'Soham Mondal');
    _gitEmailController = TextEditingController(text: 'soham@codehub.io');

    // Profile Customization Initializers
    _statusEmojiController = TextEditingController(text: '🚀');
    _statusTextController = TextEditingController(text: 'Building P2P Sovereign Engine');
    _companyController = TextEditingController(text: '@CodeHub-P2P');
    _locationController = TextEditingController(text: 'Kolkata, India');
    _websiteController = TextEditingController(text: 'https://codehub.io');
    _twitterController = TextEditingController(text: '@GranthikSom');

    _readmeController = TextEditingController(
      text: '''# Hi there, I'm Soham 👋 (@GranthikSom)

> Sovereign P2P Infrastructure Architect & Distributed Systems Engineer

### 🚀 About Me
- 🔭 Working on **CodeHub**: Decentralized Sovereign P2P Code Collaboration Platform.
- ⚡ Deeply passionate about **Rust**, **libp2p**, **Kademlia DHT**, and **Flutter Desktop**.
- 💬 Ask me about **DAG replication**, **chunk verification**, and **p2p swarm routing**.
- 📫 Reach me at **soham@codehub.io** | ENS: **soham.eth**

### 🛠️ Tech Stack & Tooling
`Rust` `Go` `Dart/Flutter` `TypeScript` `libp2p` `IPFS` `WebSockets` `Linux Kernel`

### 📊 Sovereign Swarm Contributions
- **Seeded Objects**: 4,290 Chunks (17.2 GB)
- **Replication Health**: 99.98%
- **Swarm Peer Rank**: Top 1% Pioneer Seeder''',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _displayNameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _deviceNameController.dispose();
    _gitNameController.dispose();
    _gitEmailController.dispose();

    _statusEmojiController.dispose();
    _statusTextController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _twitterController.dispose();
    _readmeController.dispose();
    super.dispose();
  }

  void _showNotification(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF238636),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
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
  // 1. Account Settings View (with GitHub-Style Profile & README.md Editor)
  // ---------------------------------------------------------------------------
  Widget _buildAccountSettings(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Navigation Sub-Tabs
        Row(
          children: [
            _buildSubTabButton(0, '👤 Profile Details'),
            const SizedBox(width: 8),
            _buildSubTabButton(1, '📝 Profile README.md'),
            const SizedBox(width: 8),
            _buildSubTabButton(2, '📌 Pinned Repositories'),
            const SizedBox(width: 8),
            _buildSubTabButton(3, '👁️ Live Profile Preview'),
          ],
        ),
        const SizedBox(height: 24),

        // Sub-Tab Content Router
        if (_profileSubTab == 0) _buildProfileDetailsTab(context, isDark),
        if (_profileSubTab == 1) _buildProfileReadmeTab(context, isDark),
        if (_profileSubTab == 2) _buildPinnedReposTab(context, isDark),
        if (_profileSubTab == 3) _buildLiveProfilePreviewTab(context, isDark),
      ],
    );
  }

  Widget _buildSubTabButton(int index, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _profileSubTab == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          setState(() {
            _profileSubTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF58A6FF).withValues(alpha: 0.15)
                : (isDark ? const Color(0xFF161B22) : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF58A6FF)
                  : (isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF58A6FF)
                  : (isDark ? const Color(0xFFC9D1D9) : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  // 1a. Profile Details Form Tab
  Widget _buildProfileDetailsTab(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('👤 Profile Customization', 'Public details and social highlights shown on your sovereign profile.'),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
                  child: const Text('SM', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Color(0xFF238636), shape: BoxShape.circle),
                    child: const Icon(Icons.check, size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _showNotification('Avatar image updated!');
                  },
                  icon: const Icon(Icons.upload, size: 16),
                  label: const Text('Change Avatar Image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF21262D) : Colors.grey.shade200,
                    foregroundColor: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text('PNG, JPG or SVG avatar. Max 5MB.', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildFormInput('Display Name', _displayNameController),
        const SizedBox(height: 16),
        Row(
          children: [
            SizedBox(
              width: 80,
              child: _buildFormInput('Emoji', _statusEmojiController),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFormInput('Custom Status Message', _statusTextController),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildFormInput('Bio Description', _bioController, maxLines: 2),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildFormInput('Company / Org', _companyController)),
            const SizedBox(width: 16),
            Expanded(child: _buildFormInput('Location', _locationController)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildFormInput('Website / Blog URL', _websiteController)),
            const SizedBox(width: 16),
            Expanded(child: _buildFormInput('Twitter / X Handle', _twitterController)),
          ],
        ),
        const SizedBox(height: 16),
        _buildFormInput('Public Email', _emailController),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () async {
            final res = await widget.state.api.updateMyProfile(
              displayName: _displayNameController.text,
              bio: _bioController.text,
              email: _emailController.text,
            );
            _showNotification(res['message'] ?? 'Profile details saved!');
          },
          icon: const Icon(Icons.save, size: 16),
          label: const Text('Save Profile Details'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF238636),
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 32),

        _buildSectionHeader('Connected Identity Providers', 'Linked web3 wallets and accounts.'),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.code, color: Colors.purpleAccent),
          title: const Text('GitHub Account Connected'),
          subtitle: const Text('@GranthikSom (Synced 42 Repositories)'),
          trailing: OutlinedButton(
            onPressed: () => _showNotification('GitHub account re-synced.'),
            child: const Text('Sync GitHub'),
          ),
        ),
      ],
    );
  }

  // 1b. Special Profile README.md Editor Tab
  Widget _buildProfileReadmeTab(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          '📝 Profile README.md (GranthikSom/GranthikSom)',
          'Special repository README displayed prominently at the top of your public profile.',
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Enable Special Profile README.md'),
          subtitle: const Text('Render GranthikSom/README.md on your sovereign profile landing page'),
          value: _enableProfileReadme,
          onChanged: (val) {
            setState(() {
              _enableProfileReadme = val;
            });
            _showNotification('Profile README ${val ? 'enabled' : 'disabled'}.');
          },
        ),
        const SizedBox(height: 16),

        // Quick Markdown Template Helpers
        Text('Quick Markdown Snippets:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ActionChip(
              avatar: const Icon(Icons.add, size: 14, color: Colors.blueAccent),
              label: const Text('Insert Bio Header'),
              onPressed: () {
                _readmeController.text += '\n\n# Hi there 👋 I am ${_displayNameController.text}';
                _showNotification('Bio header inserted!');
              },
            ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 14, color: Colors.greenAccent),
              label: const Text('Insert Tech Stack Badges'),
              onPressed: () {
                _readmeController.text += '\n\n### 🛠️ Tech Stack\n`Rust` `Go` `Dart` `Flutter` `libp2p` `IPFS`';
                _showNotification('Tech Stack inserted!');
              },
            ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 14, color: Colors.purpleAccent),
              label: const Text('Insert Swarm Stats'),
              onPressed: () {
                _readmeController.text += '\n\n### 📊 Swarm Stats\n- **Seeded Chunks**: 4,290\n- **Health Rank**: 99.98%';
                _showNotification('Swarm stats inserted!');
              },
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Markdown Code Editor & Live Preview Card
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Code Editor
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('README.md Source Editor', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _readmeController,
                    maxLines: 16,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? const Color(0xFF161B22) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),

            // Live Render Preview Box
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Live Profile README Preview', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
                  const SizedBox(height: 6),
                  Container(
                    height: 330,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0D1117) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.book_outlined, size: 16, color: Color(0xFF58A6FF)),
                              const SizedBox(width: 8),
                              Text('GranthikSom / README.md', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF58A6FF) : Colors.blue.shade700)),
                              const Spacer(),
                              const Icon(Icons.star_outline, size: 14, color: Colors.grey),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(
                            _readmeController.text,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: isDark ? const Color(0xFFC9D1D9) : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {
            _showNotification('Profile README.md saved & published to swarm!');
          },
          icon: const Icon(Icons.publish, size: 16),
          label: const Text('Save & Commit README.md'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF238636),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  // 1c. Pinned Repositories Tab
  Widget _buildPinnedReposTab(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          '📌 Pinned Repositories',
          'Select up to 6 repositories to showcase on your profile page.',
        ),
        const SizedBox(height: 16),
        ..._pinnedRepoItems.map((repo) {
          final bool isPinned = repo['isPinned'];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.bookmark_outline, color: repo['langColor'], size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(repo['name'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: (repo['langColor'] as Color).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                            child: Text(repo['lang'], style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: repo['langColor'])),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(repo['desc'], style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600)),
                    ],
                  ),
                ),
                Text('⭐ ${repo['stars']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(width: 16),
                Switch(
                  value: isPinned,
                  activeTrackColor: const Color(0xFF58A6FF),
                  onChanged: (val) {
                    setState(() {
                      repo['isPinned'] = val;
                    });
                    _showNotification('${repo['name']} ${val ? 'pinned to' : 'unpinned from'} profile.');
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // 1d. Live GitHub-Style Public Profile Preview Tab
  Widget _buildLiveProfilePreviewTab(BuildContext context, bool isDark) {
    final pinned = _pinnedRepoItems.where((r) => r['isPinned'] == true).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('👁️ Public Profile Live Preview', 'Exact representation of how peer developers see your profile on CodeHub.'),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0D1117) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column Sidebar (Avatar, Bio, Social Info, Badges)
              SizedBox(
                width: 260,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
                      child: const Text('SM', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _displayNameController.text,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                    ),
                    Text(
                      '@GranthikSom',
                      style: TextStyle(fontSize: 15, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161B22) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_statusEmojiController.text, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _statusTextController.text,
                              style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(_bioController.text, style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFC9D1D9) : Colors.black87)),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        const Icon(Icons.people_outline, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700),
                            children: const [
                              TextSpan(text: '142 ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              TextSpan(text: 'followers • '),
                              TextSpan(text: '89 ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              TextSpan(text: 'following'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),

                    _buildProfileMetaItem(Icons.business, _companyController.text, isDark),
                    _buildProfileMetaItem(Icons.location_on_outlined, _locationController.text, isDark),
                    _buildProfileMetaItem(Icons.link, _websiteController.text, isDark),
                    _buildProfileMetaItem(Icons.alternate_email, _twitterController.text, isDark),
                    const SizedBox(height: 20),

                    // Achievement Badges
                    Text('Achievements', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildBadgeChip('🛠️ Early Adopter', Colors.amber),
                        _buildBadgeChip('⚡ Swarm Seeder', Colors.greenAccent),
                        _buildBadgeChip('🔐 Security Auditor', Colors.purpleAccent),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 32),

              // Right Main Profile Display Area (README + Pinned Repos + Activity Grid)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Render Profile README.md
                    if (_enableProfileReadme) ...[
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
                                const Icon(Icons.book_outlined, size: 16, color: Color(0xFF58A6FF)),
                                const SizedBox(width: 8),
                                Text('GranthikSom / README.md', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF58A6FF) : Colors.blue.shade700)),
                              ],
                            ),
                            const Divider(height: 20),
                            Text(
                              _readmeController.text,
                              style: TextStyle(fontSize: 13, height: 1.5, color: isDark ? const Color(0xFFC9D1D9) : Colors.black87),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Pinned Repositories Grid Header
                    Row(
                      children: [
                        Text('Pinned Repositories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                        const Spacer(),
                        Text('Customize pins', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF58A6FF) : Colors.blue.shade700)),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Pinned Repositories 2-Column Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 2.2,
                      ),
                      itemCount: pinned.length,
                      itemBuilder: (context, idx) {
                        final repo = pinned[idx];
                        return Container(
                          padding: const EdgeInsets.all(14),
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
                                  const Icon(Icons.bookmark_outline, size: 16, color: Color(0xFF8B949E)),
                                  const SizedBox(width: 6),
                                  Text(repo['name'], style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF58A6FF) : Colors.blue.shade700)),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: (isDark ? Colors.white10 : Colors.grey.shade200), borderRadius: BorderRadius.circular(4)),
                                    child: const Text('Public', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Expanded(
                                child: Text(
                                  repo['desc'],
                                  style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                children: [
                                  CircleAvatar(radius: 4, backgroundColor: repo['langColor']),
                                  const SizedBox(width: 6),
                                  Text(repo['lang'], style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600)),
                                  const SizedBox(width: 14),
                                  const Icon(Icons.star_outline, size: 12, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text('${repo['stars']}', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600)),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.call_split, size: 12, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text('${repo['forks']}', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600)),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Contribution Heatmap Section
                    Text('1,420 contributions in the last year', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161B22) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 3,
                            runSpacing: 3,
                            children: List.generate(120, (index) {
                              final level = (index * 7 + 3) % 5;
                              Color c = isDark ? const Color(0xFF161B22) : Colors.grey.shade200;
                              if (level == 1) c = const Color(0xFF0E4429);
                              if (level == 2) c = const Color(0xFF006D32);
                              if (level == 3) c = const Color(0xFF26A641);
                              if (level == 4) c = const Color(0xFF39D353);

                              return Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2)),
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Less ', style: TextStyle(fontSize: 10, color: isDark ? Colors.grey : Colors.black54)),
                              Container(width: 8, height: 8, color: const Color(0xFF161B22)),
                              const SizedBox(width: 2),
                              Container(width: 8, height: 8, color: const Color(0xFF0E4429)),
                              const SizedBox(width: 2),
                              Container(width: 8, height: 8, color: const Color(0xFF006D32)),
                              const SizedBox(width: 2),
                              Container(width: 8, height: 8, color: const Color(0xFF26A641)),
                              const SizedBox(width: 2),
                              Container(width: 8, height: 8, color: const Color(0xFF39D353)),
                              const SizedBox(width: 2),
                              Text(' More', style: TextStyle(fontSize: 10, color: isDark ? Colors.grey : Colors.black54)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileMetaItem(IconData icon, String text, bool isDark) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFFC9D1D9) : Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeChip(String label, Color color) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      backgroundColor: color.withValues(alpha: 0.15),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
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
        ..._sshKeys.map((key) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.vpn_key_outlined, color: Colors.blueAccent),
            title: Text(key['title']!),
            subtitle: Text('${key['fp']} • ${key['added']}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () {
                setState(() {
                  _sshKeys.remove(key);
                });
                _showNotification('SSH Key removed.');
              },
            ),
          );
        }),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _showAddSshKeyDialog,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add New SSH Key'),
        ),
        const SizedBox(height: 32),

        _buildSectionHeader('🎟️ Access Tokens & API Keys', 'Personal Access Tokens (PATs) for CLI & API engine.'),
        const SizedBox(height: 12),
        ..._accessTokens.map((token) {
          return _buildInfoCard(
            icon: Icons.key_outlined,
            title: token['name']!,
            subtitle: 'Scopes: ${token['scopes']} • ${token['expires']}',
            color: const Color(0xFFBC8CFF),
          );
        }),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _showGenerateTokenDialog,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Generate New Access Token'),
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
          value: _p2pSwarmEnabled,
          onChanged: (val) {
            setState(() {
              _p2pSwarmEnabled = val;
            });
            _showNotification('P2P Swarm Engine ${val ? 'enabled' : 'disabled'}.');
          },
        ),
        SwitchListTile(
          title: const Text('UPnP / NAT-PMP Port Forwarding'),
          subtitle: const Text('Automatically open TCP/UDP port 4001 on local router'),
          value: _upnpPortForwarding,
          onChanged: (val) {
            setState(() {
              _upnpPortForwarding = val;
            });
            _showNotification('UPnP Port Forwarding ${val ? 'enabled' : 'disabled'}.');
          },
        ),
        const SizedBox(height: 24),

        _buildSectionHeader('🆔 Peer Identity Keypair', 'Your cryptographic Ed25519 node ID on Kademlia DHT.'),
        const SizedBox(height: 12),
        _buildFormInput('Node Peer ID', TextEditingController(text: '12D3KooWControlRelayServer99aF81c'), enabled: false),
        const SizedBox(height: 12),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: '12D3KooWControlRelayServer99aF81c'));
                _showNotification('Peer ID copied to clipboard!');
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy Peer ID'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () {
                _showNotification('Ed25519 Peer Identity keypair regenerated!');
              },
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
          title: 'Target Peer Replica Count: $_targetReplicaCount Replicas Minimum',
          subtitle: 'Auto-replication active across participating seeders.',
          color: const Color(0xFF38BDF8),
        ),
        const SizedBox(height: 20),
        Text('Minimum Swarm Replica Target: $_targetReplicaCount Replicas'),
        Slider(
          value: _targetReplicaCount.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: '$_targetReplicaCount Replicas',
          onChanged: (val) {
            setState(() {
              _targetReplicaCount = val.toInt();
            });
          },
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          title: const Text('Auto-Replicate Pinned Repositories'),
          subtitle: const Text('Background push object chunks when connected to high-speed Ethernet/Wi-Fi'),
          value: _autoReplicatePinned,
          onChanged: (val) {
            setState(() {
              _autoReplicatePinned = val;
            });
            _showNotification('Auto-replication ${val ? 'enabled' : 'disabled'}.');
          },
        ),
        SwitchListTile(
          title: const Text('Priority Seed Owner Repositories'),
          subtitle: const Text('Give maximum upload bandwidth to your personal repositories'),
          value: _prioritySeedOwner,
          onChanged: (val) {
            setState(() {
              _prioritySeedOwner = val;
            });
            _showNotification('Priority seeding ${val ? 'enabled' : 'disabled'}.');
          },
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
        _buildFormInput('Device Name', _deviceNameController),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            _showNotification('Device name updated to "${_deviceNameController.text}".');
          },
          icon: const Icon(Icons.save, size: 16),
          label: const Text('Update Device Name'),
        ),
        const SizedBox(height: 20),
        _buildFormInput('Host Operating System', TextEditingController(text: 'Linux Ubuntu 26.04 LTS (x86_64 Kernel 7.0.0)'), enabled: false),
        const SizedBox(height: 24),
        SwitchListTile(
          title: const Text('Run Engine on System Startup'),
          subtitle: const Text('Start background P2P seeder service automatically on boot'),
          value: _runOnStartup,
          onChanged: (val) {
            setState(() {
              _runOnStartup = val;
            });
            _showNotification('Startup daemon ${val ? 'enabled' : 'disabled'}.');
          },
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
          value: _notifyPullRequests,
          onChanged: (val) {
            setState(() {
              _notifyPullRequests = val;
            });
            _showNotification('PR notifications updated.');
          },
        ),
        SwitchListTile(
          title: const Text('Issues & Direct Mentions (@username)'),
          subtitle: const Text('Notify when mentioned in repository discussions'),
          value: _notifyIssues,
          onChanged: (val) {
            setState(() {
              _notifyIssues = val;
            });
            _showNotification('Issue notifications updated.');
          },
        ),
        SwitchListTile(
          title: const Text('P2P Swarm Network Alerts'),
          subtitle: const Text('Alert when repository replica count drops below health threshold'),
          value: _notifyP2PAlerts,
          onChanged: (val) {
            setState(() {
              _notifyP2PAlerts = val;
            });
            _showNotification('Swarm alerts updated.');
          },
        ),
        SwitchListTile(
          title: const Text('Security & SSH Alerts'),
          subtitle: const Text('Alert on new key additions or login attempts'),
          value: _notifySecurity,
          onChanged: (val) {
            setState(() {
              _notifySecurity = val;
            });
            _showNotification('Security alerts updated.');
          },
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
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildColorChip(const Color(0xFF58A6FF), 'Electric Blue'),
            _buildColorChip(const Color(0xFF3FB950), 'Emerald Green'),
            _buildColorChip(const Color(0xFFBC8CFF), 'Cyber Purple'),
            _buildColorChip(const Color(0xFFD29922), 'Amber'),
            _buildColorChip(const Color(0xFFF85149), 'Crimson'),
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
        _buildFormInput('Git User Name', _gitNameController),
        const SizedBox(height: 16),
        _buildFormInput('Git User Email', _gitEmailController),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            _showNotification('Git global config updated.');
          },
          icon: const Icon(Icons.save, size: 16),
          label: const Text('Save Git Configuration'),
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          title: const Text('Require GPG / Ed25519 Commit Signing'),
          subtitle: const Text('Auto-sign all DAG commits created via CodeHub desktop interface'),
          value: _requireCommitSigning,
          onChanged: (val) {
            setState(() {
              _requireCommitSigning = val;
            });
            _showNotification('Commit signing requirement ${val ? 'enabled' : 'disabled'}.');
          },
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
          value: _publicProfileVisibility,
          onChanged: (val) {
            setState(() {
              _publicProfileVisibility = val;
            });
            _showNotification('Profile visibility updated.');
          },
        ),
        SwitchListTile(
          title: const Text('Stealth Mode (Hide Peer Online Status)'),
          subtitle: const Text('Participate in swarm seeding without broadcasting node IP to public indexers'),
          value: _stealthMode,
          onChanged: (val) {
            setState(() {
              _stealthMode = val;
            });
            _showNotification('Stealth mode ${val ? 'activated' : 'deactivated'}.');
          },
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
          onPressed: () {
            _showNotification('Temporary object cache cleared (340 MB freed).');
          },
          icon: const Icon(Icons.delete_sweep, size: 16, color: Colors.orangeAccent),
          label: const Text('Clear Temporary Object Cache (340 MB)'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            _showNotification('Exporting full user data archive (ZIP)...');
          },
          icon: const Icon(Icons.download, size: 16),
          label: const Text('Export Data Package'),
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
                  onPressed: () => _confirmActionDialog('Revoke All Sessions', 'Are you sure you want to force logout across all active sessions?'),
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
                  onPressed: () => _confirmActionDialog('Remove Local Device Node', 'This will stop seeding and unregister this device from the swarm.'),
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
                  onPressed: () => _confirmActionDialog('Delete Sovereign Account', 'CRITICAL WARNING: This action is permanent and cannot be undone!', onConfirm: () {
                    widget.state.logoutUser();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => SplashScreen(state: widget.state)),
                    );
                  }),
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
  // Dialogs & Helper Modals
  // ---------------------------------------------------------------------------
  void _showAddSshKeyDialog() {
    final titleCtrl = TextEditingController();
    final keyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add New SSH Key'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Key Title (e.g. Workstation Laptop)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: keyCtrl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Public Key (ssh-ed25519 AAAAC3...)', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isNotEmpty && keyCtrl.text.isNotEmpty) {
                  setState(() {
                    _sshKeys.add({
                      'title': titleCtrl.text,
                      'fp': 'SHA256:${keyCtrl.text.hashCode.abs().toRadixString(16)}',
                      'added': 'Added just now',
                    });
                  });
                  Navigator.pop(ctx);
                  _showNotification('SSH Key "${titleCtrl.text}" added!');
                }
              },
              child: const Text('Add Key'),
            ),
          ],
        );
      },
    );
  }

  void _showGenerateTokenDialog() {
    final tokenNameCtrl = TextEditingController(text: 'new_access_token');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Generate Personal Access Token'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tokenNameCtrl,
                decoration: const InputDecoration(labelText: 'Token Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              const CheckboxListTile(value: true, onChanged: null, title: Text('repo:read (Read repository objects)')),
              const CheckboxListTile(value: true, onChanged: null, title: Text('write:packages (Push P2P DAG objects)')),
              const CheckboxListTile(value: true, onChanged: null, title: Text('swarm:pin (Pin & auto-replicate)')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final newToken = 'codehub_pat_live_${DateTime.now().millisecondsSinceEpoch}';
                setState(() {
                  _accessTokens.add({
                    'name': tokenNameCtrl.text,
                    'scopes': 'repo:read, write:packages, swarm:pin',
                    'expires': 'Expires in 90 days',
                  });
                });
                Navigator.pop(ctx);
                Clipboard.setData(ClipboardData(text: newToken));
                _showNotification('Token generated & copied to clipboard: $newToken');
              },
              child: const Text('Generate Token'),
            ),
          ],
        );
      },
    );
  }

  void _confirmActionDialog(String title, String message, {VoidCallback? onConfirm}) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(color: Colors.redAccent)),
          content: Text(message),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(ctx);
                if (onConfirm != null) {
                  onConfirm();
                } else {
                  _showNotification('$title performed successfully.');
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  // Helper Form Inputs & Widgets
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

  Widget _buildFormInput(String label, TextEditingController controller, {bool enabled = true, int maxLines = 1}) {
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
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
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

  Widget _buildColorChip(Color color, String label) {
    final isSelected = _selectedAccentColor == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedAccentColor = label;
        });
        _showNotification('Accent color changed to $label.');
      },
      child: Chip(
        avatar: CircleAvatar(backgroundColor: color, radius: 6),
        label: Text(label),
        backgroundColor: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
        side: BorderSide(color: isSelected ? color : Colors.grey.shade600),
      ),
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
