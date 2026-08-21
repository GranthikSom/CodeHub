import 'package:flutter/material.dart';
import '../services/codehub_state.dart';

class LocalStoragePanel extends StatelessWidget {
  final CodeHubState state;

  const LocalStoragePanel({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localNode = state.localNode;
    final pinnedRepos = state.repositories.where((r) => r.isPinnedLocally).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Storage Allocation Card
          Container(
            padding: const EdgeInsets.all(20),
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3FB950).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.sd_storage_outlined,
                        color: Color(0xFF3FB950),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Local Device Blockstore Storage',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'Manage disk space allocated for storing and seeding Git object DAG shards to the P2P swarm.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Storage usage Progress bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Disk Quota Usage',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      '${localNode.storageUsedGb} GB used of ${localNode.storageAllocatedGb.toStringAsFixed(0)} GB allocated',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3FB950),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (localNode.storageUsedGb / localNode.storageAllocatedGb).clamp(0.0, 1.0),
                    minHeight: 10,
                    backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3FB950)),
                  ),
                ),
                const SizedBox(height: 20),

                // Slider to adjust allocated disk quota
                Row(
                  children: [
                    Text(
                      'Allocate Max Disk Storage:',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: localNode.storageAllocatedGb,
                        min: 5.0,
                        max: 100.0,
                        divisions: 19,
                        label: '${localNode.storageAllocatedGb.toStringAsFixed(0)} GB',
                        activeColor: const Color(0xFF58A6FF),
                        onChanged: (val) => state.updateLocalStorageQuota(val),
                      ),
                    ),
                    Text(
                      '${localNode.storageAllocatedGb.toStringAsFixed(0)} GB',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 2: Pinned Repositories List
          Container(
            padding: const EdgeInsets.all(20),
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
                    Text(
                      'PINNED REPOSITORIES ON THIS NODE (${pinnedRepos.length})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      'Local Node ID: ${localNode.id}',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: isDark ? const Color(0xFF58A6FF) : Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (pinnedRepos.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No repositories pinned locally yet. Pin a repository to seed it to the P2P network.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  )
                else
                  ...pinnedRepos.map((repo) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF21262D) : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.push_pin, size: 16, color: Color(0xFF238636)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${repo.owner} / ${repo.name}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  '${repo.totalSizeMb} MB • ${repo.totalObjects} Git objects • Root: ${repo.rootCommitHash.substring(0, 10)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                    color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () => state.togglePinRepository(repo.id),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? const Color(0xFFF85149) : Colors.red,
                              side: BorderSide(color: isDark ? const Color(0xFFF85149) : Colors.red),
                            ),
                            child: const Text('Unpin & Evict'),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
