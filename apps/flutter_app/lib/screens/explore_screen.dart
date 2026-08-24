import 'package:flutter/material.dart';
import '../services/codehub_state.dart';
import '../widgets/repo_card.dart';
import '../models/repository_model.dart';
import '../models/git_object.dart';

class ExploreScreen extends StatefulWidget {
  final CodeHubState state;

  const ExploreScreen({super.key, required this.state});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedCategory = 'Trending';
  String _searchQuery = '';

  final List<CodeRepository> _trendingRepos = [
    CodeRepository(
      id: 'explore_1',
      name: 'hyper-dht-p2p',
      owner: 'libp2p-rust',
      description: 'Ultra-fast Kademlia DHT implementation with hole-punching STUN/TURN traversal.',
      defaultBranch: 'main',
      tags: const ['rust', 'p2p', 'dht'],
      totalSizeMb: 128.4,
      totalObjects: 4200,
      replicaCount: 18,
      isPinnedLocally: false,
      localReplicationProgress: 0.0,
      seedNodeIds: const ['peer_tokyo', 'peer_london'],
      rootCommitHash: 'commit_88f912c40a1',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
      stars: 842,
      forks: 139,
      rootCommit: GitObject(
        hash: 'commit_88f912c40a1',
        type: GitObjectType.commit,
        name: 'feat: add Noise cryptographic handshake',
        sizeBytes: 900,
        replicaNodeIds: const ['peer_tokyo'],
        author: 'RustPeer',
        timestamp: DateTime.now(),
      ),
    ),
    CodeRepository(
      id: 'explore_2',
      name: 'flutter-decentralized-ui',
      owner: 'flutter-community',
      description: 'Glassmorphic design system and state manager for sovereign desktop apps.',
      defaultBranch: 'main',
      tags: const ['flutter', 'dart', 'ui'],
      totalSizeMb: 45.2,
      totalObjects: 1200,
      replicaCount: 12,
      isPinnedLocally: false,
      localReplicationProgress: 0.0,
      seedNodeIds: const ['peer_berlin'],
      rootCommitHash: 'commit_11a45f92d3',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 3)),
      stars: 620,
      forks: 94,
      rootCommit: GitObject(
        hash: 'commit_11a45f92d3',
        type: GitObjectType.commit,
        name: 'v2.0.0 release',
        sizeBytes: 1200,
        replicaNodeIds: const ['peer_berlin'],
        author: 'FlutterDev',
        timestamp: DateTime.now(),
      ),
    ),
    CodeRepository(
      id: 'explore_3',
      name: 'sqlite-wasm-sync',
      owner: 'wasm-labs',
      description: 'Local-first offline sync engine for WebAssembly and native apps.',
      defaultBranch: 'main',
      tags: const ['wasm', 'sqlite', 'database'],
      totalSizeMb: 19.8,
      totalObjects: 640,
      replicaCount: 8,
      isPinnedLocally: false,
      localReplicationProgress: 0.0,
      seedNodeIds: const ['peer_sf'],
      rootCommitHash: 'commit_55d81299f0',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 8)),
      stars: 410,
      forks: 52,
      rootCommit: GitObject(
        hash: 'commit_55d81299f0',
        type: GitObjectType.commit,
        name: 'Fix CRDT merge conflict algorithm',
        sizeBytes: 400,
        replicaNodeIds: const ['peer_sf'],
        author: 'DBArchitect',
        timestamp: DateTime.now(),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allDisplay = [...widget.state.repositories, ..._trendingRepos];
    final filtered = allDisplay.where((r) {
      if (_searchQuery.isNotEmpty) {
        return r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            r.owner.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            r.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Search Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore P2P Swarm Catalog',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Discover and pin decentralized Git repositories hosted across peer devices.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Container(
                width: 300,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161B22) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Filter explore catalog...',
                    hintStyle: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade500),
                    prefixIcon: Icon(Icons.search, size: 18, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade500),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(top: 8),
                  ),
                ),
              ),
            ],
          ),
          // Live Architecture Event Toast Banner
          if (widget.state.latestLiveEventMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F6FEB), Color(0xFF238636)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt, color: Colors.amber, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.state.latestLiveEventMessage!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                    onPressed: () => widget.state.dismissLiveEventMessage(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Pipeline Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Icon(Icons.hub_outlined, color: Color(0xFF58A6FF), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Real-Time Swarm Pipeline:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'User A → CodeHub API → PostgreSQL → Redis Event Bus → Socket.IO → Live Explore Page',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF3FB950) : const Color(0xFF238636),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3FB950),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('Connected', style: TextStyle(fontSize: 11, color: Color(0xFF3FB950))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),


          // Category Filters
          Row(
            children: ['Trending', 'Most Seeded', 'Recently Updated', 'Rust', 'Flutter']
                .map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: _selectedCategory == cat,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedCategory = cat);
                        },
                        selectedColor: Colors.blueAccent.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: _selectedCategory == cat
                              ? Colors.blueAccent
                              : (isDark ? const Color(0xFF8B949E) : Colors.grey.shade700),
                          fontWeight: _selectedCategory == cat ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),

          // Catalog List
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return RepoCard(repo: filtered[index], state: widget.state);
              },
            ),
          ),
        ],
      ),
    );
  }
}
