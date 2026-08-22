import 'package:flutter/material.dart';

/// Actions Tab View (P2P CI/CD Workflows)
class ActionsView extends StatelessWidget {
  final String repoName;
  final String owner;

  const ActionsView({super.key, required this.repoName, required this.owner});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final workflows = [
      {
        'name': 'P2P Swarm Build & Test',
        'event': 'push to main',
        'status': 'success',
        'duration': '1m 24s',
        'commit': 'a1ce771 security: enforce strict authentication guard',
        'time': '20 mins ago',
      },
      {
        'name': 'Rust Native Engine Cargo Test',
        'event': 'pull_request #42',
        'status': 'success',
        'duration': '48s',
        'commit': '5c0d7e1 feat: enforce app onboarding flow',
        'time': '2 hours ago',
      },
      {
        'name': 'Flutter Linux Bundle Release',
        'event': 'push to main',
        'status': 'success',
        'duration': '3m 10s',
        'commit': '0aae62c feat: persist authenticated session across screen transitions',
        'time': '5 hours ago',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.play_circle_outline, color: Color(0xFF238636), size: 24),
              const SizedBox(width: 10),
              Text(
                'P2P Workflows & CI/CD Pipelines',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: workflows.length,
              itemBuilder: (ctx, index) {
                final wf = workflows[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161B22) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF3FB950), size: 20),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              wf['name']!,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${wf['commit']} • ${wf['event']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            wf['duration']!,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF58A6FF)),
                          ),
                          Text(
                            wf['time']!,
                            style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Projects Tab View (Kanban Boards)
class ProjectsView extends StatelessWidget {
  final String repoName;
  final String owner;

  const ProjectsView({super.key, required this.repoName, required this.owner});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.view_kanban_outlined, color: Color(0xFFBC8CFF), size: 24),
              const SizedBox(width: 10),
              Text(
                'Project Planning & Kanban Swarm Boards',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKanbanColumn(
                  context,
                  title: 'To Do',
                  count: 3,
                  cards: ['#44 Encrypted P2P messaging', '#45 Multi-sig repository release tags'],
                ),
                const SizedBox(width: 16),
                _buildKanbanColumn(
                  context,
                  title: 'In Progress',
                  count: 2,
                  cards: ['#42 Improve peer discovery algorithm', '#39 Fix chunk verification logic'],
                ),
                const SizedBox(width: 16),
                _buildKanbanColumn(
                  context,
                  title: 'Done',
                  count: 5,
                  cards: ['#37 Add repository encryption', '#28 Hardened Argon2id password hashing'],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(BuildContext context, {required String title, required int count, required List<String> cards}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
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
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF21262D) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$count', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView(
                children: cards.map((cardTitle) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                    ),
                    child: Text(
                      cardTitle,
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Security Tab View (CodeQL, Secret Scanning, Ed25519 Keys)
class SecurityView extends StatelessWidget {
  final String repoName;
  final String owner;

  const SecurityView({super.key, required this.repoName, required this.owner});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: Color(0xFF3FB950), size: 26),
              const SizedBox(width: 10),
              Text(
                'Security & Cryptographic Trust Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Security Status Cards
          _buildSecurityCard(
            context,
            icon: Icons.lock_person_outlined,
            title: 'Ed25519 Developer Identity Signatures',
            status: 'ENFORCED',
            statusColor: const Color(0xFF3FB950),
            desc: 'All commits in this repository DAG must be cryptographically signed by authorized peer keys.',
          ),
          const SizedBox(height: 12),
          _buildSecurityCard(
            context,
            icon: Icons.key_outlined,
            title: 'Argon2id Memory-Hard Key Derivation',
            status: 'ACTIVE',
            statusColor: const Color(0xFF58A6FF),
            desc: 'Repository secret keys and auth tokens are protected using Argon2id with 19MB memory cost.',
          ),
          const SizedBox(height: 12),
          _buildSecurityCard(
            context,
            icon: Icons.bug_report_outlined,
            title: 'CodeQL Static Code Analysis',
            status: '0 VULNERABILITIES',
            statusColor: const Color(0xFF3FB950),
            desc: 'Automated static analysis scanned 14,200 lines of Rust & Dart code. 0 security alerts.',
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String status,
    required Color statusColor,
    required String desc,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Insights Tab View (Swarm Metrics, Traffic, Commit Velocity)
class InsightsView extends StatelessWidget {
  final String repoName;
  final String owner;

  const InsightsView({super.key, required this.repoName, required this.owner});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          Row(
            children: [
              const Icon(Icons.insights_outlined, color: Color(0xFF58A6FF), size: 26),
              const SizedBox(width: 10),
              Text(
                'Repository Insights & P2P Swarm Telemetry',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildInsightMetric(context, label: 'Total Commits', value: '342', color: const Color(0xFF58A6FF)),
              const SizedBox(width: 16),
              _buildInsightMetric(context, label: 'Peer Seeders', value: '18 Active', color: const Color(0xFF3FB950)),
              const SizedBox(width: 16),
              _buildInsightMetric(context, label: 'Bandwidth Saved', value: '99.01%', color: const Color(0xFFBC8CFF)),
              const SizedBox(width: 16),
              _buildInsightMetric(context, label: 'Total Objects', value: '1,420', color: const Color(0xFFD29922)),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 220,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Swarm Replication Velocity (Last 30 Days)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(14, (i) {
                    final heights = [40.0, 65.0, 90.0, 120.0, 75.0, 110.0, 140.0, 160.0, 115.0, 130.0, 95.0, 150.0, 175.0, 130.0];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 16,
                          height: heights[i],
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF58A6FF), Color(0xFF3FB950)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('D${i + 1}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightMetric(BuildContext context, {required String label, required String value, required Color color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
