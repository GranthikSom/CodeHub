class UserProfile {
  final String username;
  final String displayName;
  final String email;
  final String role;
  final String peerId;
  final String bio;
  final String company;
  final String location;
  final String website;
  final String twitter;
  final String statusEmoji;
  final String statusText;
  final int followersCount;
  final int followingCount;
  final DateTime joinedAt;
  final String readmeContent;
  final List<String> achievements;
  final List<String> pinnedRepoIds;

  const UserProfile({
    required this.username,
    required this.displayName,
    required this.email,
    this.role = 'developer',
    this.peerId = '12D3KooW_soham_NodeKey',
    this.bio = 'Sovereign P2P Infrastructure Architect & Distributed Systems Engineer.',
    this.company = '@CodeHub Decentralized Core',
    this.location = 'Kolkata, India',
    this.website = 'https://codehub.p2p',
    this.twitter = '@GranthikSom',
    this.statusEmoji = '🚀',
    this.statusText = 'Building P2P Sovereign Engine',
    this.followersCount = 24,
    this.followingCount = 18,
    required this.joinedAt,
    this.readmeContent = '''# Hi there, I'm Soham 👋 (@GranthikSom)

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
    this.achievements = const [
      'Pull Shark',
      'Quickdraw',
      'Galaxy Brain',
      'Arctic Code Vault Contributor',
      'Sovereign Pioneer',
    ],
    this.pinnedRepoIds = const [],
  });

  UserProfile copyWith({
    String? username,
    String? displayName,
    String? email,
    String? role,
    String? peerId,
    String? bio,
    String? company,
    String? location,
    String? website,
    String? twitter,
    String? statusEmoji,
    String? statusText,
    int? followersCount,
    int? followingCount,
    DateTime? joinedAt,
    String? readmeContent,
    List<String>? achievements,
    List<String>? pinnedRepoIds,
  }) {
    return UserProfile(
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      role: role ?? this.role,
      peerId: peerId ?? this.peerId,
      bio: bio ?? this.bio,
      company: company ?? this.company,
      location: location ?? this.location,
      website: website ?? this.website,
      twitter: twitter ?? this.twitter,
      statusEmoji: statusEmoji ?? this.statusEmoji,
      statusText: statusText ?? this.statusText,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      joinedAt: joinedAt ?? this.joinedAt,
      readmeContent: readmeContent ?? this.readmeContent,
      achievements: achievements ?? this.achievements,
      pinnedRepoIds: pinnedRepoIds ?? this.pinnedRepoIds,
    );
  }

  factory UserProfile.defaultFor(String username, {String? email, String? role, String? peerId}) {
    return UserProfile(
      username: username,
      displayName: username == 'soham' ? 'Soham Mondal' : username,
      email: email ?? '$username@codehub.p2p',
      role: role ?? 'developer',
      peerId: peerId ?? '12D3KooW_${username}_NodeKey',
      joinedAt: DateTime(2026, 1, 15),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'display_name': displayName,
      'email': email,
      'role': role,
      'peer_id': peerId,
      'bio': bio,
      'company': company,
      'location': location,
      'website': website,
      'twitter': twitter,
      'status_emoji': statusEmoji,
      'status_text': statusText,
      'followers_count': followersCount,
      'following_count': followingCount,
      'joined_at': joinedAt.toIso8601String(),
      'readme_content': readmeContent,
      'achievements': achievements,
      'pinned_repo_ids': pinnedRepoIds,
    };
  }
}
