import 'package:flutter/material.dart';
import '../models/repository_model.dart';
import '../services/codehub_state.dart';
import '../screens/repository_detail_screen.dart';

class RepoCard extends StatelessWidget {
  final CodeRepository repo;
  final CodeHubState state;

  const RepoCard({
    super.key,
    required this.repo,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPinned = repo.isPinnedLocally;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RepositoryDetailScreen(
              repoName: repo.name,
              owner: repo.owner,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPinned
              ? const Color(0xFF238636)
              : (isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
          width: isPinned ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Repo Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF21262D) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.snippet_folder_outlined,
                  color: isDark ? const Color(0xFF58A6FF) : Colors.blue.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Title & Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${repo.owner} / ',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          repo.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFF58A6FF) : Colors.blue.shade900,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF21262D) : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            repo.defaultBranch,
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'monospace',
                              color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      repo.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Action Buttons: Pin & Explore DAG
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      state.selectRepository(repo.id);
                      state.setActiveTab(ActiveTab.dagExplorer);
                    },
                    icon: const Icon(Icons.account_tree_outlined, size: 14),
                    label: const Text('Git DAG'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? const Color(0xFFBC8CFF) : Colors.purple.shade700,
                      side: BorderSide(
                        color: isDark ? const Color(0xFFBC8CFF).withValues(alpha: 0.5) : Colors.purple.shade200,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => state.togglePinRepository(repo.id),
                    icon: Icon(
                      isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      size: 14,
                    ),
                    label: Text(isPinned ? 'Pinned (Seeding)' : 'Pin Repo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPinned
                          ? const Color(0xFF238636)
                          : (isDark ? const Color(0xFF21262D) : Colors.grey.shade100),
                      foregroundColor: isPinned
                          ? Colors.white
                          : (isDark ? const Color(0xFFC9D1D9) : Colors.black87),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // P2P Replication Footer metadata
          Row(
            children: [
              // Root SHA Hash
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.fingerprint,
                      size: 12,
                      color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Root commit: ${repo.rootCommitHash.substring(0, 14)}...',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Peer Seeders
              Row(
                children: [
                  const Icon(Icons.people_outline, size: 14, color: Color(0xFF58A6FF)),
                  const SizedBox(width: 4),
                  Text(
                    '${repo.replicaCount} Peer Devices Seeding',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF58A6FF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // Objects & Size
              Row(
                children: [
                  Icon(
                    Icons.storage_outlined,
                    size: 14,
                    color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${repo.totalSizeMb} MB (${repo.totalObjects} Git objects)',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Tags
              Row(
                children: repo.tags.take(3).map((tag) {
                  return Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF21262D) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}
