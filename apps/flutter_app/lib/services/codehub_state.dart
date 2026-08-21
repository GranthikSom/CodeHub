import 'dart:async';
import 'package:flutter/material.dart';
import '../models/p2p_node.dart';
import '../models/git_object.dart';
import '../models/repository_model.dart';
import '../native/native_bindings.dart';

enum ActiveTab { overview, repos, dagExplorer, networkTopology, storageSettings }

enum StoragePreset { zero, gb5, gb20, gb50, gb100, custom }

class CodeHubState extends ChangeNotifier {
  ActiveTab _activeTab = ActiveTab.overview;
  String _searchQuery = '';
  String? _selectedRepoId;
  GitObject? _selectedGitObject;
  ThemeMode _themeMode = ThemeMode.dark;

  // Storage Management & Seeding State
  StoragePreset _selectedStoragePreset = StoragePreset.custom;
  double _storageContributedGb = 42.5;
  double _storageUsedGb = 17.2;
  bool _isSeedingEnabled = true;

  // Bandwidth & Power Management State
  double _uploadLimitMbps = 10.0;
  double _downloadLimitMbps = 50.0;
  int _maxPeersLimit = 20;
  bool _seedWhileIdle = true;
  bool _seedOnBattery = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isNativeEngineActive => NativeP2PEngine.isNativeLoaded;

  StoragePreset get selectedStoragePreset => _selectedStoragePreset;
  double get storageContributedGb => _storageContributedGb;
  double get storageUsedGb => _storageUsedGb;
  double get storageAvailableGb => (_storageContributedGb - _storageUsedGb).clamp(0.0, double.infinity);
  bool get isSeedingEnabled => _isSeedingEnabled;

  double get uploadLimitMbps => _uploadLimitMbps;
  double get downloadLimitMbps => _downloadLimitMbps;
  int get maxPeersLimit => _maxPeersLimit;
  bool get seedWhileIdle => _seedWhileIdle;
  bool get seedOnBattery => _seedOnBattery;

  void toggleThemeMode() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setUploadLimit(double limitMbps) {
    _uploadLimitMbps = limitMbps;
    notifyListeners();
  }

  void setDownloadLimit(double limitMbps) {
    _downloadLimitMbps = limitMbps;
    notifyListeners();
  }

  void setMaxPeersLimit(int maxPeers) {
    _maxPeersLimit = maxPeers;
    notifyListeners();
  }

  void setSeedWhileIdle(bool value) {
    _seedWhileIdle = value;
    notifyListeners();
  }

  void setSeedOnBattery(bool value) {
    _seedOnBattery = value;
    notifyListeners();
  }

  void setStoragePreset(StoragePreset preset, {double? customGb}) {
    _selectedStoragePreset = preset;
    switch (preset) {
      case StoragePreset.zero:
        _storageContributedGb = 0.0;
        break;
      case StoragePreset.gb5:
        _storageContributedGb = 5.0;
        break;
      case StoragePreset.gb20:
        _storageContributedGb = 20.0;
        break;
      case StoragePreset.gb50:
        _storageContributedGb = 50.0;
        break;
      case StoragePreset.gb100:
        _storageContributedGb = 100.0;
        break;
      case StoragePreset.custom:
        if (customGb != null) {
          _storageContributedGb = customGb;
        }
        break;
    }
    updateLocalStorageQuota(_storageContributedGb);
    notifyListeners();
  }

  void setSeedingEnabled(bool enabled) {
    _isSeedingEnabled = enabled;
    notifyListeners();
  }

  // Bandwidth & Telemetry Stats
  double _currentUploadMbps = 18.4;
  double _currentDownloadMbps = 42.1;
  final int _totalSwarmObjects = 14820;

  late List<P2PNode> _nodes;
  late List<CodeRepository> _repositories;
  Timer? _telemetryTimer;

  ActiveTab get activeTab => _activeTab;
  String get searchQuery => _searchQuery;
  String? get selectedRepoId => _selectedRepoId;
  GitObject? get selectedGitObject => _selectedGitObject;
  double get currentUploadMbps => _currentUploadMbps;
  double get currentDownloadMbps => _currentDownloadMbps;
  int get totalSwarmObjects => _totalSwarmObjects;

  List<P2PNode> get nodes => _nodes;
  List<CodeRepository> get repositories => _repositories;

  CodeRepository? get selectedRepo {
    if (_selectedRepoId == null) return null;
    return _repositories.firstWhere(
      (r) => r.id == _selectedRepoId,
      orElse: () => _repositories.first,
    );
  }

  P2PNode get localNode => _nodes.firstWhere((n) => n.isLocal);

  List<CodeRepository> get filteredRepositories {
    if (_searchQuery.trim().isEmpty) return _repositories;
    final query = _searchQuery.toLowerCase();
    return _repositories.where((r) {
      return r.name.toLowerCase().contains(query) ||
          r.owner.toLowerCase().contains(query) ||
          r.description.toLowerCase().contains(query) ||
          r.rootCommitHash.toLowerCase().contains(query) ||
          r.tags.any((t) => t.toLowerCase().contains(query));
    }).toList();
  }

  CodeHubState() {
    NativeP2PEngine.initialize();
    _initializeData();
    _startTelemetrySimulation();
  }

  void setActiveTab(ActiveTab tab) {
    _activeTab = tab;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectRepository(String repoId) {
    _selectedRepoId = repoId;
    final repo = selectedRepo;
    if (repo != null) {
      _selectedGitObject = repo.rootCommit;
    }
    notifyListeners();
  }

  void selectGitObject(GitObject object) {
    _selectedGitObject = object;
    notifyListeners();
  }

  void togglePinRepository(String repoId) {
    final index = _repositories.indexWhere((r) => r.id == repoId);
    if (index != -1) {
      final repo = _repositories[index];
      final newPinState = !repo.isPinnedLocally;
      
      final updatedSeedNodes = List<String>.from(repo.seedNodeIds);
      if (newPinState) {
        if (!updatedSeedNodes.contains(localNode.id)) {
          updatedSeedNodes.add(localNode.id);
        }
      } else {
        updatedSeedNodes.remove(localNode.id);
      }

      _repositories[index] = repo.copyWith(
        isPinnedLocally: newPinState,
        localReplicationProgress: newPinState ? 1.0 : 0.0,
        replicaCount: updatedSeedNodes.length,
        seedNodeIds: updatedSeedNodes,
      );

      // Update Local Node storage
      _updateLocalNodeStorage();
      notifyListeners();
    }
  }

  void updateLocalStorageQuota(double quotaGb) {
    final localIndex = _nodes.indexWhere((n) => n.isLocal);
    if (localIndex != -1) {
      _nodes[localIndex] = _nodes[localIndex].copyWith(
        storageAllocatedGb: quotaGb,
      );
      notifyListeners();
    }
  }

  void _updateLocalNodeStorage() {
    final pinnedRepos = _repositories.where((r) => r.isPinnedLocally);
    double totalPinnedMb = 0;
    for (var repo in pinnedRepos) {
      totalPinnedMb += repo.totalSizeMb;
    }
    _storageUsedGb = double.parse((totalPinnedMb / 1024).toStringAsFixed(2));
    final localIndex = _nodes.indexWhere((n) => n.isLocal);
    if (localIndex != -1) {
      _nodes[localIndex] = _nodes[localIndex].copyWith(
        storageUsedGb: _storageUsedGb,
      );
    }
  }

  void _startTelemetrySimulation() {
    _telemetryTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // Simulate light fluctuations in P2P traffic
      _currentUploadMbps = double.parse((15.0 + (5.0 * (timer.tick % 4) / 4)).toStringAsFixed(1));
      _currentDownloadMbps = double.parse((38.0 + (8.0 * ((timer.tick + 1) % 3) / 3)).toStringAsFixed(1));
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    super.dispose();
  }

  void _initializeData() {
    // 1. Initial Nodes
    _nodes = [
      const P2PNode(
        id: '12D3KooWLocalDevNode7890x12',
        name: 'Local Node (This Device)',
        ipAddress: '127.0.0.1 (NAT Traversed)',
        type: NodeType.localNode,
        pingMs: 0,
        storageAllocatedGb: 20.0,
        storageUsedGb: 2.45,
        uploadSpeedMbps: 18.4,
        downloadSpeedMbps: 42.1,
        isLocal: true,
        pinnedRepoIds: ['repo-1', 'repo-2'],
      ),
      const P2PNode(
        id: '12D3KooWDeviceALaptop456',
        name: 'Device A (San Francisco Peer)',
        ipAddress: '192.168.1.104',
        type: NodeType.peerDevice,
        pingMs: 24,
        storageAllocatedGb: 50.0,
        storageUsedGb: 12.8,
        uploadSpeedMbps: 45.0,
        downloadSpeedMbps: 120.0,
        pinnedRepoIds: ['repo-1', 'repo-2', 'repo-3'],
      ),
      const P2PNode(
        id: '12D3KooWDeviceBDesktop890',
        name: 'Device B (Tokyo Node)',
        ipAddress: '10.0.4.18',
        type: NodeType.peerDevice,
        pingMs: 142,
        storageAllocatedGb: 100.0,
        storageUsedGb: 48.2,
        uploadSpeedMbps: 85.0,
        downloadSpeedMbps: 250.0,
        pinnedRepoIds: ['repo-1', 'repo-3', 'repo-4'],
      ),
      const P2PNode(
        id: '12D3KooWDeviceCLinuxServer',
        name: 'Device C (Berlin High-Capacity Seed)',
        ipAddress: '84.22.190.12',
        type: NodeType.seedNode,
        pingMs: 88,
        storageAllocatedGb: 500.0,
        storageUsedGb: 310.5,
        uploadSpeedMbps: 500.0,
        downloadSpeedMbps: 1000.0,
        pinnedRepoIds: ['repo-1', 'repo-2', 'repo-3', 'repo-4'],
      ),
      const P2PNode(
        id: '12D3KooWControlRelayServer',
        name: 'Control Plane (Relay & Metadata Coord)',
        ipAddress: 'control.codehub.p2p',
        type: NodeType.controlRelay,
        pingMs: 12,
        storageAllocatedGb: 0.0,
        storageUsedGb: 0.0,
        uploadSpeedMbps: 0.0,
        downloadSpeedMbps: 0.0,
        pinnedRepoIds: [],
      ),
    ];

    // Build sample Git Content-Addressed DAG Objects
    final mainDartBlob = GitObject(
      hash: 'blob_8f9a2b1c4e7d3f6a9b8c7d6e5f4a3b2c1d0e9f8a',
      type: GitObjectType.blob,
      name: 'main.dart',
      sizeBytes: 1420,
      replicaNodeIds: [
        '12D3KooWLocalDevNode7890x12',
        '12D3KooWDeviceALaptop456',
        '12D3KooWDeviceCLinuxServer'
      ],
      contentPayload: '''
import 'package:flutter/material.dart';

void main() {
  // CodeHub Decentralized P2P Git Client Entry Point
  runApp(const CodeHubApp());
}
''',
    );

    final libp2pEngineBlob = GitObject(
      hash: 'blob_3a1b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b',
      type: GitObjectType.blob,
      name: 'swarm.rs',
      sizeBytes: 8420,
      replicaNodeIds: [
        '12D3KooWDeviceALaptop456',
        '12D3KooWDeviceBDesktop890',
        '12D3KooWDeviceCLinuxServer'
      ],
      contentPayload: '''
// Rust P2P Storage & libp2p Network Swarm Engine
use libp2p::{gossipsub, kad, identity, Swarm};
use tokio::fs;

pub struct CodeHubNode {
    swarm: Swarm<CodeHubBehaviour>,
    block_store: PathBuf,
}
''',
    );

    final libTree = GitObject(
      hash: 'tree_9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b',
      type: GitObjectType.tree,
      name: 'lib',
      sizeBytes: 9840,
      replicaNodeIds: [
        '12D3KooWLocalDevNode7890x12',
        '12D3KooWDeviceALaptop456',
        '12D3KooWDeviceCLinuxServer'
      ],
      children: [mainDartBlob, libp2pEngineBlob],
    );

    final rootCommitObj = GitObject(
      hash: 'commit_e4b0c2a1f8e9d7c6b5a4f3e2d1c0b9a8f7e6d5c4',
      type: GitObjectType.commit,
      name: 'feat: implement libp2p object shard replication & local pinning',
      sizeBytes: 24500,
      author: 'Soham Mondal <soham@codehub.p2p>',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      replicaNodeIds: [
        '12D3KooWLocalDevNode7890x12',
        '12D3KooWDeviceALaptop456',
        '12D3KooWDeviceBDesktop890',
        '12D3KooWDeviceCLinuxServer'
      ],
      children: [libTree],
    );

    // 2. Repositories
    _repositories = [
      CodeRepository(
        id: 'repo-1',
        name: 'codehub-core-p2p',
        owner: 'GranthikSom',
        description: 'Decentralized Git engine with Rust libp2p blockstore & Flutter UI layer.',
        defaultBranch: 'main',
        rootCommitHash: 'commit_e4b0c2a1f8e9d7c6b5a4f3e2d1c0b9a8f7e6d5c4',
        totalSizeMb: 148.5,
        totalObjects: 1420,
        replicaCount: 4,
        isPinnedLocally: true,
        localReplicationProgress: 1.0,
        seedNodeIds: [
          '12D3KooWLocalDevNode7890x12',
          '12D3KooWDeviceALaptop456',
          '12D3KooWDeviceBDesktop890',
          '12D3KooWDeviceCLinuxServer'
        ],
        rootCommit: rootCommitObj,
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 42)),
        stars: 342,
        forks: 58,
        tags: ['rust', 'libp2p', 'git', 'p2p', 'decentralized'],
      ),
      CodeRepository(
        id: 'repo-2',
        name: 'flutter-dag-visualizer',
        owner: 'GranthikSom',
        description: 'Interactive Flutter widget for rendering content-addressed Git object DAG trees.',
        defaultBranch: 'main',
        rootCommitHash: 'commit_8f2a1b9c4d3e5f6a7b8c9d0e1f2a3b4c5d6e7f8a',
        totalSizeMb: 42.1,
        totalObjects: 380,
        replicaCount: 3,
        isPinnedLocally: true,
        localReplicationProgress: 1.0,
        seedNodeIds: [
          '12D3KooWLocalDevNode7890x12',
          '12D3KooWDeviceALaptop456',
          '12D3KooWDeviceCLinuxServer'
        ],
        rootCommit: rootCommitObj,
        lastUpdated: DateTime.now().subtract(const Duration(hours: 5)),
        stars: 128,
        forks: 19,
        tags: ['flutter', 'dart', 'ui', 'dag'],
      ),
      CodeRepository(
        id: 'repo-3',
        name: 'kademlia-dht-relay',
        owner: 'libp2p-community',
        description: 'Distributed Hash Table & NAT Traversal STUN/TURN coordination protocol for P2P code hosting.',
        defaultBranch: 'master',
        rootCommitHash: 'commit_3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d',
        totalSizeMb: 210.8,
        totalObjects: 3100,
        replicaCount: 3,
        isPinnedLocally: false,
        localReplicationProgress: 0.0,
        seedNodeIds: [
          '12D3KooWDeviceALaptop456',
          '12D3KooWDeviceBDesktop890',
          '12D3KooWDeviceCLinuxServer'
        ],
        rootCommit: rootCommitObj,
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        stars: 890,
        forks: 140,
        tags: ['networking', 'dht', 'kademlia', 'nat-traversal'],
      ),
      CodeRepository(
        id: 'repo-4',
        name: 'git-chunk-blockstore',
        owner: 'git-p2p-labs',
        description: 'Content-addressable packfile chunker with deduplication across peer devices.',
        defaultBranch: 'main',
        rootCommitHash: 'commit_7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b',
        totalSizeMb: 88.0,
        totalObjects: 890,
        replicaCount: 2,
        isPinnedLocally: false,
        localReplicationProgress: 0.0,
        seedNodeIds: [
          '12D3KooWDeviceBDesktop890',
          '12D3KooWDeviceCLinuxServer'
        ],
        rootCommit: rootCommitObj,
        lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
        stars: 215,
        forks: 31,
        tags: ['storage', 'git', 'deduplication', 'merkle'],
      ),
    ];

    _selectedRepoId = 'repo-1';
    _selectedGitObject = rootCommitObj;
  }
}
