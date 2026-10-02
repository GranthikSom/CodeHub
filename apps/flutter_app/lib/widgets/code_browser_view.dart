import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/repository_model.dart';

class CodeBrowserView extends StatefulWidget {
  final String repoName;
  final String owner;
  final CodeRepository? repository;
  final Function(int tabIndex)? onSelectTab;

  const CodeBrowserView({
    super.key,
    required this.repoName,
    required this.owner,
    this.repository,
    this.onSelectTab,
  });

  @override
  State<CodeBrowserView> createState() => _CodeBrowserViewState();
}

class _CodeBrowserViewState extends State<CodeBrowserView> {
  String _currentBranch = 'main';
  String _selectedFile = 'README.md';
  String _currentPath = '';
  bool _isBlameView = false;
  bool _isRawView = false;

  final Map<String, String> _files = {
    'README.md': '''# CodeHub - Sovereign P2P Git Platform

CodeHub is a decentralized, peer-to-peer git collaboration network built with Flutter, Rust, libp2p, Kademlia DHT, and SQLite/PostgreSQL.

## Architecture

- **Control Plane**: REST API, PostgreSQL, Redis, Auth
- **Data Plane**: Content-Addressed SHA-256 Git Object Blockstore, Kademlia DHT, libp2p Bitswap
- **Storage Management**: User-defined contribution quotas (5GB - 100GB+), 30-day GC grace period

## Features

- Sovereign P2P Git object replication
- Single-replica data risk alerts
- Peer reputation scoring (Uptime, Availability, Latency)
- Automatic delta object sync
- Noise TLS cryptographically verified commits
''',
    'Cargo.toml': '''[package]
name = "p2p_engine"
version = "0.1.0"
edition = "2021"

[dependencies]
libp2p = { version = "0.53", features = ["tcp", "noise", "yamux", "kad", "gossipsub"] }
tokio = { version = "1.35", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
sha2 = "0.10"
rusqlite = { version = "0.30", features = ["bundled"] }
anyhow = "1.0"
''',
    '.gitignore': '''# Generated files and build outputs
target/
build/
.dart_tool/
.packages
*.lock
*.log
.env
.DS_Store
''',
    'LICENSE': '''MIT License

Copyright (c) 2026 Granthik Som & CodeHub Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
''',
    'lib/main.dart': '''import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'services/codehub_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CodeHubApp());
}
''',
    'lib/screens/repository_detail_screen.dart': '''import 'package:flutter/material.dart';
import '../widgets/code_browser_view.dart';

class RepositoryDetailScreen extends StatefulWidget {
  final String repoName;
  final String owner;
  const RepositoryDetailScreen({super.key, required this.repoName, required this.owner});
  @override
  State<RepositoryDetailScreen> createState() => _RepositoryDetailScreenState();
}
''',
    'native/p2p_engine/src/blockstore.rs': '''use sha2::{Digest, Sha256};
use std::collections::HashMap;

pub struct Blockstore {
    blocks: HashMap<String, Vec<u8>>,
    quota_bytes: u64,
}

impl Blockstore {
    pub fn new(quota_bytes: u64) -> Self {
        Self {
            blocks: HashMap::new(),
            quota_bytes,
        }
    }

    pub fn put(&mut self, data: Vec<u8>) -> Result<String, &'static str> {
        let mut hasher = Sha256::new();
        hasher.update(&data);
        let hash = format!("{:x}", hasher.finalize());
        self.blocks.insert(hash.clone(), data);
        Ok(hash)
    }

    pub fn get(&self, hash: &str) -> Option<&Vec<u8>> {
        self.blocks.get(hash)
    }
}
''',
    'native/p2p_engine/src/dht_relay.rs': '''use libp2p::kad::{Kademlia, KademliaConfig};
use libp2p::PeerId;

pub struct DhtRelayCoordinator {
    local_peer_id: PeerId,
    active_peers: Vec<PeerId>,
}

impl DhtRelayCoordinator {
    pub fn new(local_peer_id: PeerId) -> Self {
        Self {
            local_peer_id,
            active_peers: Vec::new(),
        }
    }
}
''',
    'scripts/run_p2p_node.sh': '''#!/usr/bin/env bash
set -euo pipefail

echo "==> Starting CodeHub Sovereign P2P Daemon..."
cargo run --manifest-path server/Cargo.toml
''',
  };

  final Map<String, String> _fileCommitMessages = {
    'README.md': 'docs: update sovereign architecture guide & DHT metrics',
    'Cargo.toml': 'build: configure libp2p, tokio, and serde dependencies',
    '.gitignore': 'chore: initial repository gitignore configuration',
    'LICENSE': 'docs: add MIT open-source license',
    'lib/main.dart': 'feat: add flutter responsive layout & initialization',
    'lib/screens/repository_detail_screen.dart': 'feat: redesign GitHub-style repo page layout',
    'native/p2p_engine/src/blockstore.rs': 'refactor: implement SHA-256 content-addressed chunk store',
    'native/p2p_engine/src/dht_relay.rs': 'feat: add Kademlia DHT peer relay coordinator',
    'scripts/run_p2p_node.sh': 'ci: add p2p local node launch helper',
  };

  final Map<String, String> _fileCommitTimes = {
    'README.md': '2 hours ago',
    'Cargo.toml': '2 days ago',
    '.gitignore': '1 week ago',
    'LICENSE': '1 week ago',
    'lib/main.dart': '1 day ago',
    'lib/screens/repository_detail_screen.dart': '45 mins ago',
    'native/p2p_engine/src/blockstore.rs': '3 days ago',
    'native/p2p_engine/src/dht_relay.rs': '4 days ago',
    'scripts/run_p2p_node.sh': '5 days ago',
  };

  void _showBranchSelector() {
    final branches = ['main', 'feature/dht-routing', 'fix/sha256-block-verify', 'release/v1.0.0'];
    final tags = ['v1.0.0-p2p', 'v0.9.0-alpha'];

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        String filterQuery = '';
        int selectedTabIndex = 0;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final activeList = selectedTabIndex == 0 ? branches : tags;
            final filtered = activeList
                .where((item) => item.toLowerCase().contains(filterQuery.toLowerCase()))
                .toList();

            return Dialog(
              backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
              ),
              child: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Switch branches/tags',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () => Navigator.pop(ctx),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        onChanged: (val) {
                          setDialogState(() {
                            filterQuery = val;
                          });
                        },
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Filter branches/tags...',
                          hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          prefixIcon: const Icon(Icons.search, size: 16),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setDialogState(() => selectedTabIndex = 0),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: selectedTabIndex == 0
                                        ? const Color(0xFFF78166)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Branches (${branches.length})',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: selectedTabIndex == 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: selectedTabIndex == 0
                                      ? (isDark ? Colors.white : Colors.black87)
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setDialogState(() => selectedTabIndex = 1),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: selectedTabIndex == 1
                                        ? const Color(0xFFF78166)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Tags (${tags.length})',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: selectedTabIndex == 1
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: selectedTabIndex == 1
                                      ? (isDark ? Colors.white : Colors.black87)
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 1),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final isSelected = item == _currentBranch;
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              selectedTabIndex == 0 ? Icons.alt_route : Icons.sell_outlined,
                              size: 14,
                              color: isSelected ? const Color(0xFF58A6FF) : Colors.grey,
                            ),
                            title: Text(
                              item,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check, size: 16, color: Color(0xFF3FB950))
                                : null,
                            onTap: () {
                              setState(() {
                                _currentBranch = item;
                              });
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCloneModal() {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        int activeProtocolIndex = 0;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final p2pUrl = 'p2p://12D3KooWLocalDevNode7890x12/${widget.owner}/${widget.repoName}.git';
            final httpsUrl = 'http://127.0.0.1:8080/git/${widget.owner}/${widget.repoName}.git';
            final sshUrl = 'git@codehub.p2p:${widget.owner}/${widget.repoName}.git';

            final currentUrl = activeProtocolIndex == 0
                ? p2pUrl
                : (activeProtocolIndex == 1 ? httpsUrl : sshUrl);

            final protocolDesc = activeProtocolIndex == 0
                ? 'Decentralized P2P clone using libp2p Bitswap protocol and Kademlia DHT.'
                : (activeProtocolIndex == 1
                    ? 'Standard HTTPS clone compatible with vanilla Git clients.'
                    : 'Encrypted SSH clone with Ed25519 identity key authentication.');

            return Dialog(
              backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
              ),
              child: SizedBox(
                width: 440,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.code, size: 18, color: Color(0xFF3FB950)),
                              const SizedBox(width: 8),
                              Text(
                                'Clone Repository',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () => Navigator.pop(ctx),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            _buildProtocolTab('P2P Swarm', 0, activeProtocolIndex, (idx) {
                              setModalState(() => activeProtocolIndex = idx);
                            }),
                            _buildProtocolTab('HTTPS', 1, activeProtocolIndex, (idx) {
                              setModalState(() => activeProtocolIndex = idx);
                            }),
                            _buildProtocolTab('SSH', 2, activeProtocolIndex, (idx) {
                              setModalState(() => activeProtocolIndex = idx);
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        protocolDesc,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                currentUrl,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  color: Color(0xFF58A6FF),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 15),
                              tooltip: 'Copy to clipboard',
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: currentUrl));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Copied clone URL: $currentUrl'),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: const Color(0xFF238636),
                                  ),
                                );
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Opening repository in CodeHub Desktop workspace...'),
                                    backgroundColor: Color(0xFF1F6FEB),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.desktop_windows, size: 14),
                              label: const Text('Open in Desktop', style: TextStyle(fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Downloading archive: ${widget.repoName}-main.zip (1.8 MB)'),
                                    backgroundColor: const Color(0xFF238636),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.download, size: 14),
                              label: const Text('Download ZIP', style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF238636),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProtocolTab(String title, int index, int activeIndex, Function(int) onSelect) {
    final isSelected = index == activeIndex;
    return Expanded(
      child: InkWell(
        onTap: () => onSelect(index),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1F6FEB).withValues(alpha: 0.25) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF58A6FF) : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  void _showGoToFileModal() {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        String filter = '';

        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredFiles = _files.keys
                .where((f) => f.toLowerCase().contains(filter.toLowerCase()))
                .toList();

            return Dialog(
              backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
              ),
              child: SizedBox(
                width: 480,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        autofocus: true,
                        onChanged: (val) => setModalState(() => filter = val),
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search or jump to a file in ${widget.repoName}...',
                          prefixIcon: const Icon(Icons.search, size: 16),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    SizedBox(
                      height: 240,
                      child: ListView.builder(
                        itemCount: filteredFiles.length,
                        itemBuilder: (context, index) {
                          final f = filteredFiles[index];
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              f.endsWith('.md')
                                  ? Icons.description_outlined
                                  : (f.endsWith('.toml') || f.endsWith('.json')
                                      ? Icons.settings_outlined
                                      : Icons.code),
                              size: 16,
                              color: const Color(0xFF58A6FF),
                            ),
                            title: Text(
                              f,
                              style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                            ),
                            trailing: Text(
                              _fileCommitTimes[f] ?? 'recently',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedFile = f;
                              });
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddFileDialog() {
    final nameController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
          ),
          title: const Text('Create New File', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'File Name',
                    hintText: 'e.g. src/utils.rs or doc.md',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 8,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  decoration: const InputDecoration(
                    labelText: 'File Content',
                    hintText: '// Write file payload here...',
                    border: OutlineInputBorder(),
                  ),
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
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  setState(() {
                    _files[name] = contentController.text;
                    _fileCommitMessages[name] = 'feat: create $name';
                    _fileCommitTimes[name] = 'Just now';
                    _selectedFile = name;
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('File created and SHA-256 hashed: $name'),
                      backgroundColor: const Color(0xFF238636),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF238636),
                foregroundColor: Colors.white,
              ),
              child: const Text('Commit new file'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fileContent = _files[_selectedFile] ?? '// Select a file to view code payload';

    // Group directories and root files
    final directories = <String>{};
    final currentDirectoryFiles = <String>[];

    for (final fullPath in _files.keys) {
      if (_currentPath.isEmpty) {
        if (fullPath.contains('/')) {
          directories.add(fullPath.split('/').first);
        } else {
          currentDirectoryFiles.add(fullPath);
        }
      } else {
        if (fullPath.startsWith('$_currentPath/')) {
          final remainder = fullPath.substring(_currentPath.length + 1);
          if (remainder.contains('/')) {
            directories.add(remainder.split('/').first);
          } else {
            currentDirectoryFiles.add(fullPath);
          }
        }
      }
    }

    final sortedDirs = directories.toList()..sort();
    currentDirectoryFiles.sort();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Controls Row (Branch Selector, Go to file, Add file, Green Code button)
          Row(
            children: [
              // Branch Dropdown Button
              OutlinedButton.icon(
                onPressed: _showBranchSelector,
                icon: const Icon(Icons.alt_route, size: 14),
                label: Row(
                  children: [
                    Text(_currentBranch, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 16),
                  ],
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF21262D) : Colors.grey.shade100,
                  foregroundColor: isDark ? Colors.white : Colors.black87,
                  side: BorderSide(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(width: 12),

              // Branches & Tags Count Link
              InkWell(
                onTap: () => widget.onSelectTab?.call(8), // Branches tab
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.alt_route, size: 14, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '3 branches',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _showBranchSelector,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.sell_outlined, size: 14, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '2 tags',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // "Go to file" search button
              OutlinedButton.icon(
                onPressed: _showGoToFileModal,
                icon: const Icon(Icons.search, size: 14),
                label: const Text('Go to file', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF21262D) : Colors.white,
                  foregroundColor: isDark ? const Color(0xFFC9D1D9) : Colors.black87,
                  side: BorderSide(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
              const SizedBox(width: 8),

              // "Add file" Dropdown
              PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'create') _showAddFileDialog();
                  if (val == 'upload') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('P2P file upload dropped into local blockstore.')),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'create',
                    child: Row(
                      children: [
                        Icon(Icons.note_add_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('Create new file'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'upload',
                    child: Row(
                      children: [
                        Icon(Icons.upload_file_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('Upload files'),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF21262D) : Colors.white,
                    border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Add file',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFFC9D1D9) : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Iconic Green "<> Code ▾" Button
              ElevatedButton.icon(
                onPressed: _showCloneModal,
                icon: const Icon(Icons.code, size: 16),
                label: const Row(
                  children: [
                    Text('Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, size: 16),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF238636),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Latest Commit Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : const Color(0xFFF6F8FA),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: const Color(0xFF1F6FEB),
                  child: Text(
                    widget.owner.isNotEmpty ? widget.owner[0].toUpperCase() : 'G',
                    style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.owner,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'feat: implement sovereign P2P Git blockstore & libp2p bitswap sync',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFFC9D1D9) : Colors.grey.shade800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Verified green shield badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3FB950).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF3FB950).withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user_rounded, size: 12, color: Color(0xFF3FB950)),
                      SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3FB950),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: '7976e58f2a1b9c4e21a3b5'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied commit SHA: 7976e58')),
                    );
                  },
                  child: Text(
                    '7976e58',
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: Color(0xFF58A6FF),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '2 hours ago',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () => widget.onSelectTab?.call(7), // Commits & DAG tab
                  child: Row(
                    children: [
                      Icon(Icons.history, size: 14, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '24 commits',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Main Content: File Explorer Table & Readme + Right Sidebar
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left / Primary: File Table & File Viewer / Readme
                  Expanded(
                    flex: isWide ? 7 : 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // File Explorer Table Container
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF161B22) : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Breadcrumb row if navigating subdirectory
                              if (_currentPath.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () => setState(() => _currentPath = ''),
                                        child: Text(
                                          widget.repoName,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF58A6FF),
                                          ),
                                        ),
                                      ),
                                      const Text(' / ', style: TextStyle(color: Colors.grey)),
                                      Text(
                                        _currentPath,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      const Spacer(),
                                      InkWell(
                                        onTap: () {
                                          if (_currentPath.contains('/')) {
                                            setState(() {
                                              _currentPath = _currentPath.substring(
                                                0,
                                                _currentPath.lastIndexOf('/'),
                                              );
                                            });
                                          } else {
                                            setState(() => _currentPath = '');
                                          }
                                        },
                                        child: const Row(
                                          children: [
                                            Icon(Icons.arrow_upward, size: 13, color: Color(0xFF58A6FF)),
                                            SizedBox(width: 4),
                                            Text(
                                              '.. (up)',
                                              style: TextStyle(fontSize: 12, color: Color(0xFF58A6FF)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Directory Rows
                              ...sortedDirs.map((dirName) {
                                return _buildFileRow(
                                  icon: Icons.folder,
                                  iconColor: const Color(0xFF58A6FF),
                                  name: dirName,
                                  commitMsg: 'feat: add $dirName module architecture',
                                  timeAgo: '2 days ago',
                                  isDark: isDark,
                                  onTap: () {
                                    setState(() {
                                      _currentPath = _currentPath.isEmpty ? dirName : '$_currentPath/$dirName';
                                    });
                                  },
                                );
                              }),

                              // File Rows
                              ...currentDirectoryFiles.map((filePath) {
                                final isSelected = _selectedFile == filePath;
                                final displayName = filePath.contains('/')
                                    ? filePath.split('/').last
                                    : filePath;

                                IconData fileIcon = Icons.insert_drive_file_outlined;
                                Color iconColor = isDark ? const Color(0xFF8B949E) : Colors.grey.shade600;

                                if (displayName.endsWith('.md')) {
                                  fileIcon = Icons.description;
                                  iconColor = const Color(0xFF58A6FF);
                                } else if (displayName.endsWith('.toml') || displayName.endsWith('.json') || displayName.startsWith('.')) {
                                  fileIcon = Icons.settings;
                                  iconColor = const Color(0xFFBC8CFF);
                                } else if (displayName.endsWith('.rs')) {
                                  fileIcon = Icons.code;
                                  iconColor = const Color(0xFFDEA584);
                                } else if (displayName.endsWith('.dart')) {
                                  fileIcon = Icons.code;
                                  iconColor = const Color(0xFF00B4AB);
                                } else if (displayName.endsWith('.sh')) {
                                  fileIcon = Icons.terminal;
                                  iconColor = const Color(0xFF89E051);
                                }

                                return _buildFileRow(
                                  icon: fileIcon,
                                  iconColor: iconColor,
                                  name: displayName,
                                  commitMsg: _fileCommitMessages[filePath] ?? 'update $displayName',
                                  timeAgo: _fileCommitTimes[filePath] ?? 'recently',
                                  isDark: isDark,
                                  isSelected: isSelected,
                                  onTap: () {
                                    setState(() {
                                      _selectedFile = filePath;
                                      _isBlameView = false;
                                      _isRawView = false;
                                    });
                                  },
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // File Viewer / README Card
                        _buildFilePreviewCard(fileContent, isDark),
                      ],
                    ),
                  ),

                  // Right Sidebar: GitHub "About", P2P Telemetry, Releases, Contributors, Languages
                  if (isWide) ...[
                    const SizedBox(width: 24),
                    SizedBox(
                      width: 300,
                      child: _buildRightSidebar(isDark),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFileRow({
    required IconData icon,
    required Color iconColor,
    required String name,
    required String commitMsg,
    required String timeAgo,
    required bool isDark,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected
          ? (isDark ? const Color(0xFF1F6FEB).withValues(alpha: 0.15) : Colors.blue.shade50)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? const Color(0xFF21262D) : Colors.grey.shade200,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 12),
              SizedBox(
                width: 180,
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? const Color(0xFF58A6FF)
                        : (isDark ? const Color(0xFFC9D1D9) : Colors.black87),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  commitMsg,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                timeAgo,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePreviewCard(String fileContent, bool isDark) {
    final lines = fileContent.split('\n');
    final isReadme = _selectedFile.endsWith('README.md');

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1117) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : const Color(0xFFF6F8FA),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              border: Border(
                bottom: BorderSide(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isReadme ? Icons.list_alt : Icons.insert_drive_file_outlined,
                  size: 16,
                  color: const Color(0xFF58A6FF),
                ),
                const SizedBox(width: 8),
                Text(
                  _selectedFile,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${lines.length} lines · ${(fileContent.length / 1024).toStringAsFixed(2)} KB · SHA-256 Verified',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                  ),
                ),
                const Spacer(),

                // Raw button
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isRawView = !_isRawView;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _isRawView
                        ? (isDark ? const Color(0xFF1F6FEB) : Colors.blue.shade100)
                        : Colors.transparent,
                    side: BorderSide(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    _isRawView ? 'Preview' : 'Raw',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Blame button
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isBlameView = !_isBlameView;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _isBlameView
                        ? (isDark ? const Color(0xFF1F6FEB) : Colors.blue.shade100)
                        : Colors.transparent,
                    side: BorderSide(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    'Blame',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Copy button
                IconButton(
                  icon: const Icon(Icons.copy, size: 14),
                  tooltip: 'Copy raw file',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: fileContent));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied $_selectedFile to clipboard'),
                        backgroundColor: const Color(0xFF238636),
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                if (!isReadme) ...[
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    tooltip: 'Close file preview',
                    onPressed: () {
                      setState(() {
                        _selectedFile = 'README.md';
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
          ),

          // Body: Rendered README or Code Viewer with Line Numbers
          if (isReadme && !_isRawView && !_isBlameView)
            _buildRenderedReadme(fileContent, isDark)
          else
            _buildCodeEditor(lines, isDark),
        ],
      ),
    );
  }

  Widget _buildRenderedReadme(String content, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'CodeHub - Sovereign P2P Git Platform',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 12),

          // Badges Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBadge('P2P Network', 'Online', const Color(0xFF238636)),
              _buildBadge('Replicas', '3/3 Target', const Color(0xFF1F6FEB)),
              _buildBadge('License', 'MIT', const Color(0xFF8957E5)),
              _buildBadge('DHT', 'Kademlia v0.53', const Color(0xFFDA3633)),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            'CodeHub is a decentralized, peer-to-peer git collaboration network built with Flutter, Rust, libp2p, Kademlia DHT, and SQLite/PostgreSQL.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? const Color(0xFFC9D1D9) : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Callout Note Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1F6FEB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDark ? const Color(0xFF388BFD).withValues(alpha: 0.4) : Colors.blue.shade200,
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 3,
                  height: 36,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF58A6FF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Icon(Icons.info_outline, size: 16, color: Color(0xFF58A6FF)),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFFC9D1D9) : Colors.black87,
                        height: 1.4,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Sovereign Data Ownership: ',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF58A6FF)),
                        ),
                        TextSpan(
                          text: 'All Git objects are cryptographically signed using Ed25519 identity keys and replicated across the decentralized swarm. No centralized authority can delete or revoke access to your repository data.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Architecture',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          _buildBulletPoint('Control Plane: REST API, PostgreSQL, Redis, Auth & Access Control Matrix', isDark),
          _buildBulletPoint('Data Plane: Content-Addressed SHA-256 Git Object Blockstore, Kademlia DHT, libp2p Bitswap', isDark),
          _buildBulletPoint('Storage Management: User-defined contribution quotas (5GB - 100GB+), 30-day GC grace period', isDark),
          const SizedBox(height: 20),

          Text(
            'Quick Start & Peer Sync',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 10),

          // Terminal Snippet
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF010409) : Colors.grey.shade900,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF30363D)),
            ),
            child: const Text(
              '# Clone via decentralized P2P swarm\n'
              'git clone p2p://12D3KooWLocalDevNode7890x12/GranthikSom/CodeHub.git\n\n'
              '# Check local replication SLA and peer status\n'
              'codehub swarm status --repo GranthikSom/CodeHub',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Color(0xFF58A6FF),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Key Features',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          _buildCheckItem('Sovereign P2P Git object replication across active nodes', true, isDark),
          _buildCheckItem('Single-replica data risk alerts and automated proactive re-seeding', true, isDark),
          _buildCheckItem('Peer reputation scoring (Uptime, Availability, Latency, Bandwidth)', true, isDark),
          _buildCheckItem('Automatic delta object sync with 99%+ bandwidth savings', true, isDark),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(3)),
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: Text(
              value,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Color(0xFF58A6FF), fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDark ? const Color(0xFFC9D1D9) : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text, bool checked, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            checked ? Icons.check_box : Icons.check_box_outline_blank,
            size: 16,
            color: checked ? const Color(0xFF3FB950) : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFFC9D1D9) : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeEditor(List<String> lines, bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FA),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: lines.length,
        itemBuilder: (context, index) {
          final lineNum = index + 1;
          final lineContent = lines[index];

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Line number gutter
              Container(
                width: 50,
                padding: const EdgeInsets.only(right: 12),
                alignment: Alignment.centerRight,
                child: Text(
                  '$lineNum',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: isDark ? const Color(0xFF484F58) : Colors.grey.shade400,
                  ),
                ),
              ),

              // Blame annotation if enabled
              if (_isBlameView)
                Container(
                  width: 140,
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    '7976e58 (${widget.owner})',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Color(0xFF58A6FF),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Code content
              Expanded(
                child: Text(
                  lineContent.isEmpty ? ' ' : lineContent,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    height: 1.4,
                    color: isDark ? const Color(0xFFC9D1D9) : Colors.black87,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRightSidebar(bool isDark) {
    final repo = widget.repository;
    final description = repo?.description.isNotEmpty == true
        ? repo!.description
        : 'Sovereign P2P decentralized Git collaboration network built with Flutter, Rust, libp2p, Kademlia DHT, and SQLite.';
    final topics = repo?.tags.isNotEmpty == true
        ? repo!.tags
        : ['p2p', 'rust', 'libp2p', 'git', 'decentralized', 'kademlia-dht', 'flutter'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // About Header
        Text(
          'About',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: isDark ? const Color(0xFFC9D1D9) : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        // Website Link
        InkWell(
          onTap: () {},
          child: const Row(
            children: [
              Icon(Icons.link, size: 14, color: Color(0xFF58A6FF)),
              SizedBox(width: 6),
              Text(
                'https://codehub.p2p',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF58A6FF),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Topics Pills
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: topics.map((t) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F6FEB).withValues(alpha: 0.15) : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF388BFD).withValues(alpha: 0.3) : Colors.blue.shade200,
                ),
              ),
              child: Text(
                t,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF58A6FF),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        // Resources links
        Row(
          children: [
            Icon(Icons.book_outlined, size: 14, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
            const SizedBox(width: 6),
            Text('Readme', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700)),
            const SizedBox(width: 14),
            Icon(Icons.gavel_outlined, size: 14, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(repo?.license ?? 'MIT license', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700)),
          ],
        ),

        const Divider(height: 28),

        // P2P Swarm Telemetry Section (Decentralized Superpower)
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF3FB950),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'P2P Swarm Health',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildSidebarMetric('Replication SLA', '${repo?.replicaCount ?? 3}/3 target replicas', const Color(0xFF3FB950)),
        _buildSidebarMetric('Active Seeders', '8 online peers', const Color(0xFF58A6FF)),
        _buildSidebarMetric('Pinned Chunks', '14 verified chunks', const Color(0xFFBC8CFF)),
        _buildSidebarMetric('Local Status', repo?.isPinnedLocally == false ? 'Remote Swarm' : 'Sovereign Pinned', const Color(0xFF3FB950)),

        const Divider(height: 28),

        // Releases
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Releases',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              '+ 2 releases',
              style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.sell_outlined, size: 14, color: Color(0xFF3FB950)),
            const SizedBox(width: 6),
            const Text(
              'v1.0.0-p2p',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF58A6FF),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFF3FB950).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF3FB950).withValues(alpha: 0.5)),
              ),
              child: const Text(
                'Latest',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3FB950)),
              ),
            ),
            const Spacer(),
            Text(
              '2d ago',
              style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
            ),
          ],
        ),

        const Divider(height: 28),

        // Contributors
        Text(
          'Contributors 3',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildContributorAvatar('G', const Color(0xFF1F6FEB), 'GranthikSom'),
            const SizedBox(width: 6),
            _buildContributorAvatar('A', const Color(0xFF8957E5), 'AlexDev'),
            const SizedBox(width: 6),
            _buildContributorAvatar('S', const Color(0xFF238636), 'SohamMondal'),
          ],
        ),

        const Divider(height: 28),

        // Languages
        Text(
          'Languages',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),

        // Language bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: [
              Expanded(
                flex: 62,
                child: Container(height: 8, color: const Color(0xFFDEA584)),
              ),
              Expanded(
                flex: 32,
                child: Container(height: 8, color: const Color(0xFF00B4AB)),
              ),
              Expanded(
                flex: 6,
                child: Container(height: 8, color: const Color(0xFF89E051)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            _buildLanguageLegend('Rust', '62.4%', const Color(0xFFDEA584), isDark),
            _buildLanguageLegend('Dart', '31.8%', const Color(0xFF00B4AB), isDark),
            _buildLanguageLegend('Shell', '5.8%', const Color(0xFF89E051), isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildSidebarMetric(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildContributorAvatar(String initial, Color color, String name) {
    return Tooltip(
      message: name,
      child: CircleAvatar(
        radius: 14,
        backgroundColor: color,
        child: Text(
          initial,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLanguageLegend(String lang, String percent, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          lang,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          percent,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
