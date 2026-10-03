import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/p2p_node.dart';
import '../models/git_object.dart';
import '../models/repository_model.dart';
import '../models/user_profile.dart';
import '../native/native_bindings.dart';
import 'api_service.dart';
import '../config/api_config.dart';


enum ActiveTab { overview, repos, dagExplorer, networkTopology, storageSettings }

enum StoragePreset { zero, gb5, gb20, gb50, gb100, custom }

class CodeHubState extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  ActiveTab _activeTab = ActiveTab.overview;
  String _searchQuery = '';
  String? _selectedRepoId;
  GitObject? _selectedGitObject;
  ThemeMode _themeMode = ThemeMode.dark;
  late UserProfile _userProfile;
  int _dashboardNavIndex = 0;
  void Function(int)? onNavigateToDashboardTab;

  // Real-Time Event Bus & Live Explore Toast State
  String? _latestLiveEventMessage;
  DateTime? _latestLiveEventTime;
  WebSocketChannel? _eventChannel;
  StreamSubscription? _eventSubscription;
  Timer? _reconnectTimer;
  bool _isBackendConnected = false;
  String _backendStatus = 'connecting'; // 'online', 'connecting', 'offline'
  String _activeBackendPipelineInfo = 'Direct Axum / WebSocket Event Bus';
  bool _isDisposed = false;
  final Set<Timer> _pendingTimers = {};

  String? get latestLiveEventMessage => _latestLiveEventMessage;
  DateTime? get latestLiveEventTime => _latestLiveEventTime;
  bool get isBackendConnected => _isBackendConnected;
  String get backendStatus => _backendStatus;
  String get activeBackendPipelineInfo => _activeBackendPipelineInfo;

  void dismissLiveEventMessage() {
    _latestLiveEventMessage = null;
    notifyListeners();
  }

  void reconnectBackend() {
    _backendStatus = 'connecting';
    notifyListeners();
    _connectWebSocketEventBus();
    _syncRepositoriesFromBackend();
  }


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

  // Garbage Collection & Grace Period State
  int _gcCandidateCount = 342;
  double _reclaimableGb = 1.85;
  final int _gracePeriodDays = 30;
  bool _isGcRunning = false;
  String _gcLastStatus = 'Active: 342 candidate chunks in 30-day grace period.';

  // Repository Versioning & Delta Sync State
  final double _baseVersionMb = 500.0;
  final double _targetVersionMb = 505.0;
  final double _deltaTransferMb = 5.0;
  final double _bandwidthSavedPercent = 99.01;
  bool _isDeltaSyncRunning = false;
  String _deltaSyncStatus = 'Version 1 (500 MB) → Version 2 (505 MB). Only 5 MB new objects needed.';

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isNativeEngineActive => NativeP2PEngine.isNativeLoaded;
  ApiService get api => _apiService;

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

  int get gcCandidateCount => _gcCandidateCount;
  double get reclaimableGb => _reclaimableGb;
  int get gracePeriodDays => _gracePeriodDays;
  bool get isGcRunning => _isGcRunning;
  String get gcLastStatus => _gcLastStatus;

  double get baseVersionMb => _baseVersionMb;
  double get targetVersionMb => _targetVersionMb;
  double get deltaTransferMb => _deltaTransferMb;
  double get bandwidthSavedPercent => _bandwidthSavedPercent;
  bool get isDeltaSyncRunning => _isDeltaSyncRunning;
  String get deltaSyncStatus => _deltaSyncStatus;

  void runDeltaSyncSimulation() {
    _isDeltaSyncRunning = true;
    notifyListeners();

    Timer(const Duration(milliseconds: 600), () {
      _isDeltaSyncRunning = false;
      _deltaSyncStatus = 'Delta Sync complete! Distributed 5 MB new objects (Saved 500 MB redundancy).';
      notifyListeners();
    });
  }

  void triggerGarbageCollection() {
    _isGcRunning = true;
    notifyListeners();

    Timer(const Duration(milliseconds: 800), () {
      _isGcRunning = false;
      _gcCandidateCount = (_gcCandidateCount - 12).clamp(0, 10000);
      _reclaimableGb = (_reclaimableGb - 0.08).clamp(0.0, 100.0);
      _gcLastStatus = 'Garbage Collection complete. 12 expired chunks purged (>30 days).';
      notifyListeners();
    });
  }

  void toggleThemeMode() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  UserProfile get userProfile => _userProfile;
  int get dashboardNavIndex => _dashboardNavIndex;

  void setDashboardNavIndex(int index) {
    _dashboardNavIndex = index;
    if (onNavigateToDashboardTab != null) {
      onNavigateToDashboardTab!(index);
    }
    notifyListeners();
  }

  void navigateToProfile() {
    setDashboardNavIndex(8);
  }

  void notifyAuthStateChanged() {
    final username = _apiService.currentUsername ?? 'soham';
    _userProfile = UserProfile.defaultFor(
      username,
      email: _apiService.currentEmail ?? '$username@codehub.p2p',
      role: _apiService.currentRole ?? 'developer',
      peerId: _apiService.currentPeerId ?? '12D3KooW_${username}_NodeKey',
    );
    notifyListeners();
  }

  void logoutUser() {
    _apiService.logout();
    _userProfile = UserProfile.defaultFor('User');
    notifyListeners();
  }

  void updateUserProfile({
    String? displayName,
    String? bio,
    String? company,
    String? location,
    String? website,
    String? twitter,
    String? statusEmoji,
    String? statusText,
    String? readmeContent,
  }) {
    _userProfile = _userProfile.copyWith(
      displayName: displayName,
      bio: bio,
      company: company,
      location: location,
      website: website,
      twitter: twitter,
      statusEmoji: statusEmoji,
      statusText: statusText,
      readmeContent: readmeContent,
    );
    notifyListeners();
    _apiService.updateMyProfile(
      displayName: displayName,
      bio: bio,
      email: _userProfile.email,
    );
  }

  void setProfileStatus(String emoji, String text) {
    _userProfile = _userProfile.copyWith(
      statusEmoji: emoji,
      statusText: text,
    );
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

  void addRepository(CodeRepository repo) {
    _repositories.insert(0, repo);
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
    if (_selectedRepoId == null || _repositories.isEmpty) return null;
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

  final Set<String> _starredRepoIds = {};

  bool isRepoStarred(String repoId) => _starredRepoIds.contains(repoId);

  void toggleStarRepository(String repoId) {
    final isStarred = _starredRepoIds.contains(repoId);
    if (isStarred) {
      _starredRepoIds.remove(repoId);
      _apiService.unstarRepository(repoId);
    } else {
      _starredRepoIds.add(repoId);
      _apiService.starRepository(repoId);
    }
    
    final index = _repositories.indexWhere((r) => r.id == repoId);
    if (index != -1) {
      final repo = _repositories[index];
      final newStars = !isStarred ? repo.stars + 1 : (repo.stars - 1).clamp(0, 999999);
      _repositories[index] = repo.copyWith(stars: newStars);
    }
    notifyListeners();
  }

  CodeRepository? findRepository(String owner, String name) {
    for (final r in _repositories) {
      if (r.name.toLowerCase() == name.toLowerCase() &&
          r.owner.toLowerCase() == owner.toLowerCase()) {
        return r;
      }
    }
    for (final r in _repositories) {
      if (r.name.toLowerCase() == name.toLowerCase()) {
        return r;
      }
    }
    return null;
  }

  CodeHubState() {
    NativeP2PEngine.initialize();
    _initializeData();
    _startTelemetrySimulation();
    _connectWebSocketEventBus();
    _syncRepositoriesFromBackend();
  }

  void _connectWebSocketEventBus() async {
    if (_isDisposed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _eventSubscription?.cancel();
    _eventSubscription = null;
    try {
      _eventChannel?.sink.close();
    } catch (_) {}
    _eventChannel = null;

    final candidateWsUrls = <String>[
      ApiConfig.socketWsUrl,
      'ws://127.0.0.1:8080/api/v1/events/ws',
      'ws://localhost:8080/api/v1/events/ws',
      'wss://api.codehub.p2p/api/v1/events/ws',
      'wss://api.codehub.com/api/v1/events/ws',
    ];

    bool connected = false;
    for (final wsUrl in candidateWsUrls) {
      if (_isDisposed) return;
      try {
        final uri = Uri.parse(wsUrl);
        final channel = WebSocketChannel.connect(uri);

        final timeoutCompleter = Completer<void>();
        final timer = Timer(const Duration(seconds: 2), () {
          if (!timeoutCompleter.isCompleted) {
            timeoutCompleter.completeError(TimeoutException('WebSocket timeout', const Duration(seconds: 2)));
          }
        });
        _pendingTimers.add(timer);

        try {
          await Future.any([
            channel.ready,
            timeoutCompleter.future,
          ]);
        } finally {
          timer.cancel();
          _pendingTimers.remove(timer);
        }

        if (_isDisposed) {
          try {
            channel.sink.close();
          } catch (_) {}
          return;
        }

        _eventChannel = channel;
        _isBackendConnected = true;
        _backendStatus = 'online';
        _activeBackendPipelineInfo = 'Connected to $wsUrl';
        connected = true;
        notifyListeners();

        _eventSubscription = channel.stream.listen(
          (data) {
            if (!_isDisposed) {
              _handleWebSocketEvent(data);
            }
          },
          onError: (err) {
            if (!_isDisposed) {
              _handleWebSocketDisconnect();
            }
          },
          onDone: () {
            if (!_isDisposed) {
              _handleWebSocketDisconnect();
            }
          },
        );
        break;
      } catch (_) {
        // try next candidate
      }
    }

    if (!connected && !_isDisposed) {
      _isBackendConnected = false;
      _backendStatus = 'offline';
      _activeBackendPipelineInfo = 'Offline (Retrying pipeline connection...)';
      notifyListeners();
      _scheduleReconnect();
    }
  }

  void _handleWebSocketDisconnect() {
    if (_isDisposed) return;
    _isBackendConnected = false;
    _backendStatus = 'offline';
    _activeBackendPipelineInfo = 'Disconnected (Reconnecting...)';
    notifyListeners();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_isDisposed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isDisposed) {
        _connectWebSocketEventBus();
      }
    });
    if (_reconnectTimer != null) {
      _pendingTimers.add(_reconnectTimer!);
    }
  }

  void _handleWebSocketEvent(dynamic data) {
    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      final evt = json['event'] ?? json['type'];

      if (evt == 'pipeline_connected') {
        _isBackendConnected = true;
        _backendStatus = 'online';
        _latestLiveEventMessage = '⚡ Connected to CodeHub Backend Pipeline (${json['server'] ?? 'Axum'})';
        _latestLiveEventTime = DateTime.now();
        notifyListeners();
      } else if (evt == 'heartbeat') {
        // Heartbeat keepalive acknowledged
      } else if (evt == 'repository_created' || evt == 'repository.created') {
        final repoMap = json['repository'] as Map<String, dynamic>?;
        if (repoMap != null) {
          final repoId = (repoMap['id'] ?? 'repo_${DateTime.now().millisecondsSinceEpoch}').toString();
          if (!_repositories.any((r) => r.id == repoId)) {
            final owner = repoMap['owner']?.toString() ?? 'User A';
            final name = repoMap['name']?.toString() ?? 'new-p2p-repo';
            final desc = repoMap['description']?.toString() ?? 'Real-time broadcast repository';
            final commitHash = repoMap['root_commit_hash']?.toString() ?? 'commit_live_broadcast';

            final newRepo = CodeRepository(
              id: repoId,
              name: name,
              owner: owner,
              description: desc,
              defaultBranch: repoMap['default_branch']?.toString() ?? 'main',
              tags: repoMap['topics'] != null
                  ? List<String>.from(repoMap['topics'] as List)
                  : const ['rust', 'p2p'],
              totalSizeMb: 1.25,
              seedNodeIds: const ['peer_broadcaster_01', 'peer_tokyo'],
              replicaCount: (repoMap['seed_count'] is int) ? repoMap['seed_count'] as int : 3,
              totalObjects: (repoMap['total_objects'] is int) ? repoMap['total_objects'] as int : 12,
              rootCommitHash: commitHash,
              lastUpdated: DateTime.now(),
              isPinnedLocally: false,
              localReplicationProgress: 0.0,
              stars: (repoMap['stars'] is int) ? repoMap['stars'] as int : 1,
              forks: (repoMap['forks'] is int) ? repoMap['forks'] as int : 0,
              rootCommit: GitObject(
                hash: commitHash,
                type: GitObjectType.commit,
                name: 'Initial live commit',
                sizeBytes: 850,
                replicaNodeIds: const ['peer_broadcaster_01'],
                author: owner,
                timestamp: DateTime.now(),
              ),
            );

            _repositories.insert(0, newRepo);
            _latestLiveEventMessage = '⚡ Live Control Event: User $owner created repository "$name" (Saved to PostgreSQL & broadcast live)';
            _latestLiveEventTime = DateTime.now();
            notifyListeners();
          }
        }
      } else if (evt == 'repository_updated' || evt == 'repository.updated') {
        final repoMap = json['repository'] as Map<String, dynamic>?;
        final name = repoMap?['name'] ?? 'repository';
        _latestLiveEventMessage = '⚡ Live Control Event: Repository "$name" metadata updated';
        _latestLiveEventTime = DateTime.now();
        notifyListeners();
      } else if (evt == 'repository_deleted' || evt == 'repository.deleted') {
        final repoId = (json['repository_id'] ?? json['id'] ?? '').toString();
        _repositories.removeWhere((r) => r.id == repoId);
        _latestLiveEventMessage = '⚡ Live Control Event: Repository $repoId deleted from catalog';
        _latestLiveEventTime = DateTime.now();
        notifyListeners();
      } else if (evt == 'issue_updated' || evt == 'issue.updated') {
        final title = json['title'] ?? 'Issue update';
        _latestLiveEventMessage = '⚡ Live Control Event: Issue updated "$title"';
        _latestLiveEventTime = DateTime.now();
        notifyListeners();
      } else if (evt == 'PR_updated' || evt == 'PR.updated') {
        final title = json['title'] ?? 'Pull request update';
        _latestLiveEventMessage = '⚡ Live Control Event: Pull Request updated "$title"';
        _latestLiveEventTime = DateTime.now();
        notifyListeners();
      } else if (evt == 'peer_online' || evt == 'peer.online') {
        final peerId = json['peer_id'] ?? 'Peer';
        _latestLiveEventMessage = '⚡ Live Control Event: Peer $peerId joined swarm';
        _latestLiveEventTime = DateTime.now();
        notifyListeners();
      } else if (evt == 'replication_updated' || evt == 'replication.updated') {
        final factor = json['replica_count'] ?? 3;
        _latestLiveEventMessage = '⚡ Live Control Event: Swarm replication factor synchronized ($factor seeds active)';
        _latestLiveEventTime = DateTime.now();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _syncRepositoriesFromBackend() async {
    try {
      final repos = await _apiService.fetchRepositories();
      if (repos.isNotEmpty) {
        for (final r in repos) {
          if (r is Map<String, dynamic>) {
            final id = r['id']?.toString() ?? '';
            if (id.isNotEmpty && !_repositories.any((existing) => existing.id == id)) {
              final newRepo = CodeRepository(
                id: id,
                name: r['name']?.toString() ?? 'repo',
                owner: r['owner']?.toString() ?? 'User',
                description: r['description']?.toString() ?? '',
                defaultBranch: r['default_branch']?.toString() ?? 'main',
                tags: r['topics'] != null ? List<String>.from(r['topics'] as List) : const ['rust', 'p2p'],
                totalSizeMb: 1.5,
                seedNodeIds: const ['peer_broadcaster_01'],
                replicaCount: (r['seed_count'] is int) ? r['seed_count'] as int : 3,
                totalObjects: (r['total_objects'] is int) ? r['total_objects'] as int : 12,
                rootCommitHash: r['root_commit_hash']?.toString() ?? 'commit_live',
                lastUpdated: DateTime.now(),
                isPinnedLocally: false,
                localReplicationProgress: 0.0,
                stars: (r['stars'] is int) ? r['stars'] as int : 1,
                forks: (r['forks'] is int) ? r['forks'] as int : 0,
                rootCommit: GitObject(
                  hash: r['root_commit_hash']?.toString() ?? 'commit_live',
                  type: GitObjectType.commit,
                  name: 'Initial commit',
                  sizeBytes: 850,
                  replicaNodeIds: const ['peer_broadcaster_01'],
                  author: r['owner']?.toString() ?? 'User',
                  timestamp: DateTime.now(),
                ),
              );
              _repositories.add(newRepo);
            }
          }
        }
        notifyListeners();
      }
    } catch (_) {}
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
        _apiService.announcePeer(repoId, peerId: localNode.id);
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

  Future<bool> deleteRepository(String repoId) async {
    _repositories.removeWhere((r) => r.id == repoId);
    if (_selectedRepoId == repoId) {
      _selectedRepoId = _repositories.isNotEmpty ? _repositories.first.id : null;
    }
    _latestLiveEventMessage = '⚡ Live Control Event: Repository $repoId deleted from catalog';
    _latestLiveEventTime = DateTime.now();
    notifyListeners();
    try {
      final res = await _apiService.deleteRepository(repoId);
      return res['success'] == true;
    } catch (_) {
      return false;
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
    _isDisposed = true;
    _telemetryTimer?.cancel();
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    for (final t in _pendingTimers) {
      t.cancel();
    }
    _pendingTimers.clear();
    _eventSubscription?.cancel();
    try {
      _eventChannel?.sink.close();
    } catch (_) {}
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
        storageUsedGb: 0.0,
        uploadSpeedMbps: 18.4,
        downloadSpeedMbps: 42.1,
        isLocal: true,
        pinnedRepoIds: [],
      ),
      const P2PNode(
        id: '12D3KooWDeviceALaptop456',
        name: 'Device A (San Francisco Peer)',
        ipAddress: '192.168.1.104',
        type: NodeType.peerDevice,
        pingMs: 24,
        storageAllocatedGb: 50.0,
        storageUsedGb: 0.0,
        uploadSpeedMbps: 45.0,
        downloadSpeedMbps: 120.0,
        pinnedRepoIds: [],
      ),
      const P2PNode(
        id: '12D3KooWDeviceBDesktop890',
        name: 'Device B (Tokyo Node)',
        ipAddress: '10.0.4.18',
        type: NodeType.peerDevice,
        pingMs: 142,
        storageAllocatedGb: 100.0,
        storageUsedGb: 0.0,
        uploadSpeedMbps: 85.0,
        downloadSpeedMbps: 250.0,
        pinnedRepoIds: [],
      ),
      const P2PNode(
        id: '12D3KooWDeviceCLinuxServer',
        name: 'Device C (Berlin High-Capacity Seed)',
        ipAddress: '84.22.190.12',
        type: NodeType.seedNode,
        pingMs: 88,
        storageAllocatedGb: 500.0,
        storageUsedGb: 0.0,
        uploadSpeedMbps: 500.0,
        downloadSpeedMbps: 1000.0,
        pinnedRepoIds: [],
      ),
      const P2PNode(
        id: '12D3KooW1BjxRJcydv6rtKJhuutvEp8LEvUgCHv5ARgQ',
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

    // 2. Repositories (clean production state: synchronized dynamically via backend & P2P swarm)
    _repositories = [];
    _selectedRepoId = null;
    _selectedGitObject = null;

    // 3. User Profile
    final username = _apiService.currentUsername ?? 'soham';
    _userProfile = UserProfile.defaultFor(
      username,
      email: _apiService.currentEmail ?? '$username@gmail.com',
      role: _apiService.currentRole ?? 'developer',
      peerId: _apiService.currentPeerId ?? '12D3KooW_${username}_NodeKey',
    );
  }
}
