import 'package:flutter/material.dart';

class CodeBrowserView extends StatefulWidget {
  final String repoName;
  final String owner;

  const CodeBrowserView({
    super.key,
    required this.repoName,
    required this.owner,
  });

  @override
  State<CodeBrowserView> createState() => _CodeBrowserViewState();
}

class _CodeBrowserViewState extends State<CodeBrowserView> {
  String _selectedFile = 'README.md';

  final Map<String, String> _mockFiles = {
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
''',
    'lib/main.dart': '''import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const CodeHubApp());
}
''',
    'native/p2p_engine/src/blockstore.rs': '''pub struct Blockstore {
    blocks: std::collections::HashMap<String, Vec<u8>>,
    quota_bytes: u64,
}

impl Blockstore {
    pub fn new(quota_bytes: u64) -> Self {
        Self {
            blocks: std::collections::HashMap::new(),
            quota_bytes,
        }
    }
}
''',
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fileContent = _mockFiles[_selectedFile] ?? '// Select a file to view code payload';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Interactive File Tree Explorer
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.folder_open, size: 18, color: Color(0xFF58A6FF)),
                    const SizedBox(width: 8),
                    Text(
                      'Files',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF21262D) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'main branch',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: _mockFiles.keys.map((filePath) {
                      final isSelected = _selectedFile == filePath;
                      return ListTile(
                        dense: true,
                        selected: isSelected,
                        selectedTileColor: isDark
                            ? const Color(0xFF1F6FEB).withValues(alpha: 0.15)
                            : Colors.blue.shade50,
                        leading: Icon(
                          filePath.endsWith('.md')
                              ? Icons.description
                              : (filePath.endsWith('.toml')
                                  ? Icons.settings
                                  : Icons.code),
                          size: 16,
                          color: isSelected
                              ? const Color(0xFF58A6FF)
                              : (isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
                        ),
                        title: Text(
                          filePath,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontFamily: 'monospace',
                            color: isSelected
                                ? (isDark ? Colors.white : Colors.blue.shade900)
                                : (isDark ? const Color(0xFFC9D1D9) : Colors.black87),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedFile = filePath;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Right Column: Code Viewer with Line Numbers
        Expanded(
          flex: 7,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.insert_drive_file, size: 16, color: Color(0xFF3FB950)),
                        const SizedBox(width: 8),
                        Text(
                          _selectedFile,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${fileContent.split('\n').length} lines • SHA256 Verified',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? const Color(0xFF30363D) : Colors.black,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        fileContent,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          height: 1.4,
                          color: Color(0xFFC9D1D9),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
