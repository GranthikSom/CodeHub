import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/repository_model.dart';
import '../services/codehub_state.dart';
import '../widgets/create_repository_dialog.dart';
import 'repository_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  final CodeHubState state;

  const ProfileScreen({super.key, required this.state});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _repoSearchQuery = '';
  String _selectedLanguage = 'All';
  String _selectedRepoType = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showEditProfileDialog() {
    final profile = widget.state.userProfile;
    final nameCtrl = TextEditingController(text: profile.displayName);
    final bioCtrl = TextEditingController(text: profile.bio);
    final companyCtrl = TextEditingController(text: profile.company);
    final locationCtrl = TextEditingController(text: profile.location);
    final websiteCtrl = TextEditingController(text: profile.website);
    final twitterCtrl = TextEditingController(text: profile.twitter);
    final statusTextCtrl = TextEditingController(text: profile.statusText);
    final statusEmojiCtrl = TextEditingController(text: profile.statusEmoji);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              const Icon(Icons.edit_note_rounded, color: Color(0xFF58A6FF)),
              const SizedBox(width: 8),
              const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Row
                  Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: statusEmojiCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Emoji',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: statusTextCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Status message',
                            hintText: "What's happening?",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: bioCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      hintText: 'Add a bio to tell people about yourself',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: companyCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Company / Organization',
                      prefixIcon: Icon(Icons.business_outlined, size: 18),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: locationCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      prefixIcon: Icon(Icons.location_on_outlined, size: 18),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: websiteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Website / Portfolio',
                      prefixIcon: Icon(Icons.link_rounded, size: 18),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: twitterCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Social / Twitter',
                      prefixIcon: Icon(Icons.alternate_email_rounded, size: 18),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
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
                widget.state.updateUserProfile(
                  displayName: nameCtrl.text.trim(),
                  bio: bioCtrl.text.trim(),
                  company: companyCtrl.text.trim(),
                  location: locationCtrl.text.trim(),
                  website: websiteCtrl.text.trim(),
                  twitter: twitterCtrl.text.trim(),
                  statusEmoji: statusEmojiCtrl.text.trim().isEmpty ? '🚀' : statusEmojiCtrl.text.trim(),
                  statusText: statusTextCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully and synced with P2P swarm'),
                    backgroundColor: Color(0xFF238636),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = widget.state.userProfile;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // Top GitHub-style Navigation Breadcrumb Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B22) : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF58A6FF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.person_outline_rounded, color: Color(0xFF58A6FF), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'CodeHub P2P',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    ' / ',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade400,
                    ),
                  ),
                  Text(
                    'users',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    ' / ',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade400,
                    ),
                  ),
                  Text(
                    '@${profile.username}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: 'https://codehub.p2p/users/${profile.username}'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile URL copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? const Color(0xFFC9D1D9) : Colors.black87,
                      side: BorderSide(color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    icon: const Icon(Icons.share_outlined, size: 14),
                    label: const Text('Share Profile', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _showEditProfileDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF21262D) : Colors.grey.shade200,
                      foregroundColor: isDark ? const Color(0xFFC9D1D9) : Colors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: BorderSide(color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE)),
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: const Text('Edit profile', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            // Main Body: 2-Column Responsive GitHub Layout
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 900;
                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left User Profile Sidebar (300px)
                          SizedBox(
                            width: 290,
                            child: _buildProfileSidebar(context, isDark),
                          ),
                          const SizedBox(width: 28),
                          // Right Tabs & Activity Area
                          Expanded(
                            child: _buildMainContentArea(context, isDark),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileSidebar(context, isDark),
                          const SizedBox(height: 24),
                          _buildMainContentArea(context, isDark),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LEFT PROFILE SIDEBAR (GitHub Style)
  // ---------------------------------------------------------------------------
  Widget _buildProfileSidebar(BuildContext context, bool isDark) {
    final profile = widget.state.userProfile;
    final username = profile.username;
    final displayName = profile.displayName.isNotEmpty ? profile.displayName : username;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar + Status Badge
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF238636), Color(0xFF2EA043), Color(0xFF1E3A2B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 88,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Floating Status Emoji Pill
              Positioned(
                bottom: 8,
                right: 12,
                child: InkWell(
                  onTap: _showEditProfileDialog,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161B22) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(profile.statusEmoji, style: const TextStyle(fontSize: 16)),
                        if (profile.statusText.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 140),
                            child: Text(
                              profile.statusText,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFC9D1D9) : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Display Name & Username
        Text(
          displayName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFFF0F6FC) : const Color(0xFF24292F),
          ),
        ),
        Row(
          children: [
            Text(
              '@$username',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? const Color(0xFF8B949E) : const Color(0xFF57606A),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: profile.role == 'admin'
                    ? const Color(0xFF8957E5).withValues(alpha: 0.2)
                    : const Color(0xFF1F6FEB).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: profile.role == 'admin' ? const Color(0xFFBC8CFF) : const Color(0xFF58A6FF),
                  width: 0.8,
                ),
              ),
              child: Text(
                profile.role.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: profile.role == 'admin' ? const Color(0xFFBC8CFF) : const Color(0xFF58A6FF),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Full Width "Edit profile" Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _showEditProfileDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF21262D) : Colors.grey.shade200,
              foregroundColor: isDark ? const Color(0xFFC9D1D9) : Colors.black87,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(
                  color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
                ),
              ),
            ),
            child: const Text('Edit profile', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ),

        const SizedBox(height: 16),

        // Bio
        if (profile.bio.isNotEmpty) ...[
          Text(
            profile.bio,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? const Color(0xFFC9D1D9) : const Color(0xFF24292F),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Followers & Following Row
        Row(
          children: [
            Icon(Icons.people_outline_rounded, size: 16, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              '${profile.followersCount}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white : Colors.black),
            ),
            Text(
              ' followers · ',
              style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
            ),
            Text(
              '${profile.followingCount}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white : Colors.black),
            ),
            Text(
              ' following',
              style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
            ),
          ],
        ),

        const SizedBox(height: 16),
        Divider(color: isDark ? const Color(0xFF21262D) : const Color(0xFFD0D7DE)),
        const SizedBox(height: 12),

        // Metadata list (Company, Location, Website, Twitter)
        _buildMetaRow(Icons.business_rounded, profile.company, isDark),
        _buildMetaRow(Icons.location_on_outlined, profile.location, isDark),
        _buildMetaRow(Icons.link_rounded, profile.website, isDark, isLink: true),
        _buildMetaRow(Icons.alternate_email_rounded, profile.twitter, isDark),
        _buildMetaRow(
          Icons.calendar_today_outlined,
          'Joined ${profile.joinedAt.month == 1 ? "January" : "February"} ${profile.joinedAt.year}',
          isDark,
        ),

        const SizedBox(height: 20),
        Divider(color: isDark ? const Color(0xFF21262D) : const Color(0xFFD0D7DE)),
        const SizedBox(height: 12),

        // Cryptographic P2P Identity Card
        Text(
          'P2P CRYPTOGRAPHIC IDENTITY',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.6,
            color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.key_rounded, size: 14, color: Color(0xFF58A6FF)),
                  const SizedBox(width: 6),
                  const Text('Ed25519 Peer ID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: profile.peerId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ed25519 Peer Key copied to clipboard!'),
                          backgroundColor: Color(0xFF238636),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Icon(Icons.copy_rounded, size: 14, color: Color(0xFF58A6FF)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  profile.peerId,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: Color(0xFF7EE787),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.verified_user_rounded, size: 14, color: Color(0xFF238636)),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Argon2id Session Verified',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF7EE787)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        Divider(color: isDark ? const Color(0xFF21262D) : const Color(0xFFD0D7DE)),
        const SizedBox(height: 12),

        // Achievements Section (GitHub Style)
        Text(
          'ACHIEVEMENTS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.6,
            color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildAchievementBadge(
              emoji: '🦈',
              title: 'Pull Shark',
              subtitle: 'Merged 2 PRs',
              color: const Color(0xFF1F6FEB),
              isDark: isDark,
            ),
            _buildAchievementBadge(
              emoji: '⚡',
              title: 'Quickdraw',
              subtitle: 'Closed issue <5m',
              color: const Color(0xFFD29922),
              isDark: isDark,
            ),
            _buildAchievementBadge(
              emoji: '🌌',
              title: 'Galaxy Brain',
              subtitle: '2 Accepted Answers',
              color: const Color(0xFF8957E5),
              isDark: isDark,
            ),
            _buildAchievementBadge(
              emoji: '❄️',
              title: 'Arctic Vault',
              subtitle: 'SHA-256 Preserved',
              color: const Color(0xFF388BFD),
              isDark: isDark,
            ),
            _buildAchievementBadge(
              emoji: '🌐',
              title: 'Sovereign Pioneer',
              subtitle: 'Seed Node Host',
              color: const Color(0xFF238636),
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetaRow(IconData icon, String text, bool isDark, {bool isLink = false}) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isLink ? const Color(0xFF58A6FF) : (isDark ? const Color(0xFFC9D1D9) : const Color(0xFF24292F)),
                decoration: isLink ? TextDecoration.underline : TextDecoration.none,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge({
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
  }) {
    return Tooltip(
      message: '$title: $subtitle',
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 22)),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RIGHT MAIN CONTENT AREA (GitHub Tabs & Activity)
  // ---------------------------------------------------------------------------
  Widget _buildMainContentArea(BuildContext context, bool isDark) {
    final repos = widget.state.repositories;
    final starredCount = repos.where((r) => r.stars > 0).length;
    final pinnedRepos = repos.where((r) => r.isPinnedLocally).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // GitHub Tabs Bar
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: isDark ? Colors.white : Colors.black87,
            unselectedLabelColor: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
            indicatorColor: const Color(0xFFF78166),
            indicatorWeight: 3,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_outlined, size: 16),
                    const SizedBox(width: 8),
                    const Text('Overview', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  children: [
                    const Icon(Icons.source_outlined, size: 16),
                    const SizedBox(width: 8),
                    const Text('Repositories', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(width: 6),
                    _buildCountPill('${repos.length}', isDark),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  children: [
                    const Icon(Icons.star_outline_rounded, size: 16),
                    const SizedBox(width: 8),
                    const Text('Stars', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(width: 6),
                    _buildCountPill('$starredCount', isDark),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  children: [
                    const Icon(Icons.pin_outlined, size: 16),
                    const SizedBox(width: 8),
                    const Text('P2P Swarm & Pinned', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(width: 6),
                    _buildCountPill('${pinnedRepos.length}', isDark),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  children: [
                    const Icon(Icons.article_outlined, size: 16),
                    const SizedBox(width: 8),
                    const Text('README.md', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Tab Content Views
        SizedBox(
          height: 980,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTabContent(context, isDark),
              _buildRepositoriesTabContent(context, isDark),
              _buildStarsTabContent(context, isDark),
              _buildP2pSwarmTabContent(context, isDark),
              _buildReadmeTabContent(context, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCountPill(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF21262D) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isDark ? const Color(0xFFC9D1D9) : Colors.black87,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. OVERVIEW TAB (Pinned Repos + Contribution Heatmap + Activity)
  // ---------------------------------------------------------------------------
  Widget _buildOverviewTabContent(BuildContext context, bool isDark) {
    final repos = widget.state.repositories;
    final profile = widget.state.userProfile;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pinned Repositories Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pinned',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFC9D1D9) : const Color(0xFF24292F),
                ),
              ),
              TextButton(
                onPressed: () {
                  _tabController.animateTo(1);
                },
                child: const Text('Customize your pins', style: TextStyle(fontSize: 12, color: Color(0xFF58A6FF))),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (repos.isEmpty)
            _buildEmptyPinnedState(context, isDark)
          else
            _buildPinnedGrid(context, repos, isDark),

          const SizedBox(height: 28),

          // 52-Week GitHub Contribution Activity Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '524 contributions in 2026',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFC9D1D9) : const Color(0xFF24292F),
                ),
              ),
              Row(
                children: [
                  Text('Contribution settings', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600)),
                  const Icon(Icons.arrow_drop_down, size: 16),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Heatmap Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContributionHeatmap(isDark),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Learn how we count contributions', style: TextStyle(fontSize: 11, color: Color(0xFF58A6FF))),
                    ),
                    Row(
                      children: [
                        Text('Less ', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600)),
                        _buildHeatmapCellColor(const Color(0xFF161B22), isDark),
                        const SizedBox(width: 3),
                        _buildHeatmapCellColor(const Color(0xFF0E4429), isDark),
                        const SizedBox(width: 3),
                        _buildHeatmapCellColor(const Color(0xFF006D32), isDark),
                        const SizedBox(width: 3),
                        _buildHeatmapCellColor(const Color(0xFF26A641), isDark),
                        const SizedBox(width: 3),
                        _buildHeatmapCellColor(const Color(0xFF39D353), isDark),
                        Text(' More', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Profile README Section (GitHub Profile README.md)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.menu_book_outlined, size: 16, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      '${profile.username} / README.md',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFC9D1D9) : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      onPressed: _showEditProfileDialog,
                      tooltip: 'Edit README',
                    ),
                  ],
                ),
                const Divider(height: 20),
                Text(
                  profile.readmeContent,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    fontFamily: 'sans-serif',
                    color: isDark ? const Color(0xFFC9D1D9) : const Color(0xFF24292F),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Contribution Activity Timeline
          Text(
            'Contribution activity',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFC9D1D9) : const Color(0xFF24292F),
            ),
          ),
          const SizedBox(height: 12),
          _buildActivityTimeline(isDark),
        ],
      ),
    );
  }

  Widget _buildEmptyPinnedState(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE)),
      ),
      child: Column(
        children: [
          Icon(Icons.push_pin_outlined, size: 36, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade500),
          const SizedBox(height: 12),
          Text(
            'No repositories pinned yet',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 6),
          Text(
            'Showcase your favorite sovereign repositories here for the decentralized swarm.',
            style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => CreateRepositoryDialog(state: widget.state),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF238636),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Create New Repository'),
          ),
        ],
      ),
    );
  }

  Widget _buildPinnedGrid(BuildContext context, List<CodeRepository> repos, bool isDark) {
    final pinned = repos.take(6).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 440,
        mainAxisExtent: 140,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: pinned.length,
      itemBuilder: (context, idx) {
        final repo = pinned[idx];
        return _buildPinnedRepoCard(context, repo, isDark);
      },
    );
  }

  Widget _buildPinnedRepoCard(BuildContext context, CodeRepository repo, bool isDark) {
    return InkWell(
      onTap: () {
        widget.state.selectRepository(repo.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RepositoryDetailScreen(
              repoName: repo.name,
              owner: repo.owner,
              repository: repo,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.folder_outlined, size: 16, color: Color(0xFF58A6FF)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${repo.owner}/${repo.name}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF58A6FF),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE)),
                  ),
                  child: Text(
                    repo.isPrivate ? 'Private' : 'Public',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                repo.description.isNotEmpty ? repo.description : 'Sovereign P2P Git decentralized repository.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                // Language indicator dot
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getLanguageColor(repo.language ?? 'Rust'),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  repo.language ?? 'Rust',
                  style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.star_outline_rounded, size: 14, color: Color(0xFFE3B341)),
                const SizedBox(width: 4),
                Text('${repo.stars}', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700)),
                const SizedBox(width: 14),
                const Icon(Icons.call_split_rounded, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${repo.forks}', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getLanguageColor(String lang) {
    switch (lang.toLowerCase()) {
      case 'rust':
        return const Color(0xFFDEA584);
      case 'dart':
        return const Color(0xFF00B4AB);
      case 'typescript':
        return const Color(0xFF3178C6);
      case 'javascript':
        return const Color(0xFFF1E05A);
      case 'python':
        return const Color(0xFF3572A5);
      default:
        return const Color(0xFF58A6FF);
    }
  }

  // ---------------------------------------------------------------------------
  // 52-WEEK GITHUB CONTRIBUTION HEATMAP
  // ---------------------------------------------------------------------------
  Widget _buildContributionHeatmap(bool isDark) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final days = ['', 'Mon', '', 'Wed', '', 'Fri', ''];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month labels
          Padding(
            padding: const EdgeInsets.only(left: 30.0, bottom: 4.0),
            child: Row(
              children: List.generate(12, (m) {
                return Container(
                  width: 54,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    months[m],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                    ),
                  ),
                );
              }),
            ),
          ),
          // Heatmap grid (7 rows x 52 columns)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day labels column
              Column(
                children: List.generate(7, (d) {
                  return Container(
                    height: 12,
                    margin: const EdgeInsets.only(bottom: 3),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      days[d],
                      style: TextStyle(
                        fontSize: 9,
                        color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                      ),
                    ),
                  );
                }),
              ),
              // Squares matrix
              Row(
                children: List.generate(52, (week) {
                  return Column(
                    children: List.generate(7, (day) {
                      final count = _getSimulatedContributions(week, day);
                      final color = _getHeatmapColor(count, isDark);
                      return Tooltip(
                        message: '$count contributions on Week ${week + 1}, Day ${day + 1}',
                        child: Container(
                          width: 11,
                          height: 11,
                          margin: const EdgeInsets.only(right: 3, bottom: 3),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(
                              color: isDark ? Colors.black.withValues(alpha: 0.1) : Colors.grey.shade300,
                              width: 0.5,
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getSimulatedContributions(int week, int day) {
    final hash = (week * 7 + day * 13 + (week % 4) * 17) % 31;
    if (hash < 10) return 0;
    if (hash < 18) return 2;
    if (hash < 24) return 5;
    if (hash < 28) return 8;
    return 12;
  }

  Color _getHeatmapColor(int count, bool isDark) {
    if (count == 0) return isDark ? const Color(0xFF161B22) : const Color(0xFFEBEDF0);
    if (count <= 2) return const Color(0xFF0E4429);
    if (count <= 5) return const Color(0xFF006D32);
    if (count <= 8) return const Color(0xFF26A641);
    return const Color(0xFF39D353);
  }

  Widget _buildHeatmapCellColor(Color color, bool isDark) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade400, width: 0.5),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CONTRIBUTION ACTIVITY TIMELINE
  // ---------------------------------------------------------------------------
  Widget _buildActivityTimeline(bool isDark) {
    return Column(
      children: [
        _buildTimelineItem(
          month: 'October 2026',
          icon: Icons.commit_rounded,
          iconColor: const Color(0xFF58A6FF),
          title: 'Created 18 commits in 3 sovereign repositories',
          details: 'Pushed to GranthikSom/CodeHub:main and p2p-storage-node',
          isDark: isDark,
        ),
        _buildTimelineItem(
          month: 'September 2026',
          icon: Icons.call_merge_rounded,
          iconColor: const Color(0xFFBC8CFF),
          title: 'Merged pull request #14: Zero-copy SHA-256 chunk streaming',
          details: 'Merged into codehub-core by Soham Mondal',
          isDark: isDark,
        ),
        _buildTimelineItem(
          month: 'August 2026',
          icon: Icons.hub_rounded,
          iconColor: const Color(0xFF238636),
          title: 'Deployed P2P swarm node cluster',
          details: 'Connected 5 sovereign peers across Berlin, San Francisco, and Tokyo',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String month,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String details,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  details,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. REPOSITORIES TAB CONTENT (GitHub Style Search, Filter, List)
  // ---------------------------------------------------------------------------
  Widget _buildRepositoriesTabContent(BuildContext context, bool isDark) {
    var repos = widget.state.repositories;

    if (_repoSearchQuery.trim().isNotEmpty) {
      final q = _repoSearchQuery.toLowerCase();
      repos = repos.where((r) => r.name.toLowerCase().contains(q) || r.description.toLowerCase().contains(q)).toList();
    }

    if (_selectedRepoType == 'Public') {
      repos = repos.where((r) => !r.isPrivate).toList();
    } else if (_selectedRepoType == 'Private') {
      repos = repos.where((r) => r.isPrivate).toList();
    } else if (_selectedRepoType == 'Pinned') {
      repos = repos.where((r) => r.isPinnedLocally).toList();
    }

    if (_selectedLanguage != 'All') {
      repos = repos.where((r) => (r.language ?? '').toLowerCase() == _selectedLanguage.toLowerCase()).toList();
    }

    return Column(
      children: [
        // Controls: Search input + Type filter + Language filter + New Repo button
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (val) => setState(() => _repoSearchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Find a repository...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF161B22) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            DropdownButton<String>(
              value: _selectedRepoType,
              dropdownColor: isDark ? const Color(0xFF161B22) : Colors.white,
              underline: const SizedBox(),
              items: ['All', 'Public', 'Private', 'Pinned'].map((t) {
                return DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)));
              }).toList(),
              onChanged: (val) => setState(() => _selectedRepoType = val ?? 'All'),
            ),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: _selectedLanguage,
              dropdownColor: isDark ? const Color(0xFF161B22) : Colors.white,
              underline: const SizedBox(),
              items: ['All', 'Rust', 'Dart', 'TypeScript', 'Python'].map((l) {
                return DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 12)));
              }).toList(),
              onChanged: (val) => setState(() => _selectedLanguage = val ?? 'All'),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => CreateRepositoryDialog(state: widget.state),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF238636),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('New', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),

        const SizedBox(height: 16),
        Divider(color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE)),
        const SizedBox(height: 8),

        // Repository Items List
        Expanded(
          child: repos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open_outlined, size: 48, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'No repositories matching your criteria',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Create a new decentralized repository or adjust your filter.',
                        style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: repos.length,
                  separatorBuilder: (context, index) => Divider(color: isDark ? const Color(0xFF21262D) : const Color(0xFFD0D7DE), height: 24),
                  itemBuilder: (context, idx) {
                    final repo = repos[idx];
                    return _buildRepoListItem(context, repo, isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRepoListItem(BuildContext context, CodeRepository repo, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      widget.state.selectRepository(repo.id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RepositoryDetailScreen(
                            repoName: repo.name,
                            owner: repo.owner,
                            repository: repo,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      repo.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF58A6FF),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE)),
                    ),
                    child: Text(
                      repo.isPrivate ? 'Private' : 'Public',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  if (repo.isPinnedLocally) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF238636).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.pin_rounded, size: 10, color: Color(0xFF7EE787)),
                          SizedBox(width: 4),
                          Text('Pinned to Swarm', style: TextStyle(fontSize: 10, color: Color(0xFF7EE787), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                repo.description.isNotEmpty ? repo.description : 'Sovereign P2P Git decentralized repository.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getLanguageColor(repo.language ?? 'Rust'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(repo.language ?? 'Rust', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700)),
                  const SizedBox(width: 16),
                  const Icon(Icons.star_outline_rounded, size: 14, color: Color(0xFFE3B341)),
                  const SizedBox(width: 4),
                  Text('${repo.stars}', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700)),
                  const SizedBox(width: 16),
                  const Icon(Icons.call_split_rounded, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${repo.forks}', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700)),
                  const SizedBox(width: 16),
                  Text('Updated recently', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600)),
                ],
              ),
            ],
          ),
        ),
        // Action buttons: Star & Pin
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => widget.state.toggleStarRepository(repo.id),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? const Color(0xFFC9D1D9) : Colors.black87,
                side: BorderSide(color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              icon: Icon(
                repo.stars > 0 ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 16,
                color: repo.stars > 0 ? const Color(0xFFE3B341) : null,
              ),
              label: Text(repo.stars > 0 ? 'Starred' : 'Star', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => widget.state.togglePinRepository(repo.id),
              tooltip: repo.isPinnedLocally ? 'Unpin from local node' : 'Pin to local node',
              icon: Icon(
                repo.isPinnedLocally ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                size: 18,
                color: repo.isPinnedLocally ? const Color(0xFF7EE787) : Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 3. STARS TAB CONTENT
  // ---------------------------------------------------------------------------
  Widget _buildStarsTabContent(BuildContext context, bool isDark) {
    final starred = widget.state.repositories.where((r) => r.stars > 0).toList();

    if (starred.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_outline_rounded, size: 48, color: Color(0xFFE3B341)),
            const SizedBox(height: 12),
            Text(
              "You don't have any starred repositories yet",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 6),
            Text(
              'Explore the decentralized swarm and star repositories you like.',
              style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: starred.length,
      separatorBuilder: (context, index) => Divider(color: isDark ? const Color(0xFF21262D) : const Color(0xFFD0D7DE), height: 24),
      itemBuilder: (context, idx) {
        return _buildRepoListItem(context, starred[idx], isDark);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 4. P2P SWARM & PINNED TAB CONTENT
  // ---------------------------------------------------------------------------
  Widget _buildP2pSwarmTabContent(BuildContext context, bool isDark) {
    final pinned = widget.state.repositories.where((r) => r.isPinnedLocally).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Swarm Node Header Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.hub_rounded, color: Color(0xFF58A6FF), size: 20),
                    const SizedBox(width: 8),
                    const Text('Sovereign Local P2P Node Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF238636).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF238636)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: Color(0xFF7EE787)),
                          SizedBox(width: 6),
                          Text('Swarm Seeder Online', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF7EE787))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildP2pStatBox('Storage Contributed', '${widget.state.storageContributedGb.toStringAsFixed(1)} GB', isDark),
                    const SizedBox(width: 12),
                    _buildP2pStatBox('Storage Used', '${widget.state.storageUsedGb.toStringAsFixed(1)} GB', isDark),
                    const SizedBox(width: 12),
                    _buildP2pStatBox('Upload Bandwidth', '${widget.state.currentUploadMbps} MB/s', isDark),
                    const SizedBox(width: 12),
                    _buildP2pStatBox('Connected Peers', '${widget.state.nodes.length} Nodes', isDark),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Pinned Swarm Repositories (${pinned.length})',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFC9D1D9) : const Color(0xFF24292F),
            ),
          ),
          const SizedBox(height: 10),

          if (pinned.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B22) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE)),
              ),
              child: Center(
                child: Text(
                  'No repositories pinned for local replication yet. Pin any repository to seed its immutable DAG chunks.',
                  style: TextStyle(color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600, fontSize: 13),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pinned.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final repo = pinned[idx];
                return _buildPinnedSwarmRow(repo, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildP2pStatBox(String label, String value, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isDark ? const Color(0xFF21262D) : const Color(0xFFD0D7DE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF58A6FF))),
          ],
        ),
      ),
    );
  }

  Widget _buildPinnedSwarmRow(CodeRepository repo, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.push_pin_rounded, size: 16, color: Color(0xFF7EE787)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${repo.owner}/${repo.name}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF58A6FF)),
                ),
                Text(
                  '${repo.totalObjects} chunks · ${repo.totalSizeMb.toStringAsFixed(1)} MB allocated · 100% verified',
                  style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => widget.state.togglePinRepository(repo.id),
            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
            tooltip: 'Unpin repository',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. README TAB CONTENT
  // ---------------------------------------------------------------------------
  Widget _buildReadmeTabContent(BuildContext context, bool isDark) {
    final profile = widget.state.userProfile;

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.book_outlined, color: Color(0xFF58A6FF), size: 18),
                const SizedBox(width: 8),
                Text(
                  '${profile.username} / README.md',
                  style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: _showEditProfileDialog,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Edit README', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              profile.readmeContent,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: isDark ? const Color(0xFFC9D1D9) : const Color(0xFF24292F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
