import 'package:flutter/material.dart';

/// Actions Tab View (P2P CI/CD Workflows & Pipelines)
class ActionsView extends StatefulWidget {
  final String repoName;
  final String owner;

  const ActionsView({super.key, required this.repoName, required this.owner});

  @override
  State<ActionsView> createState() => _ActionsViewState();
}

class _ActionsViewState extends State<ActionsView> {
  String _selectedWorkflow = 'All Workflows';

  final List<String> _workflowsList = [
    'All Workflows',
    'Flutter CI',
    'Node CI',
    'Rust CI',
    'Release Build',
  ];

  final List<Map<String, dynamic>> _runs = [
    {
      'id': 'Build #182',
      'workflow': 'Release Build',
      'commit': '7976e58 feat: implement Access & Permissions system',
      'branch': 'main',
      'author': 'GranthikSom',
      'status': 'success',
      'duration': '4m 21s',
      'time': '10 mins ago',
      'steps': [
        {'name': 'Clone repository', 'status': 'success', 'duration': '0.4s', 'logs': 'git clone --depth=1 https://github.com/GranthikSom/CodeHub.git\nChecking out commit 7976e58... Done.'},
        {'name': 'Install dependencies', 'status': 'success', 'duration': '18.2s', 'logs': 'cargo fetch --manifest-path server/Cargo.toml\nflutter pub get --directory apps/flutter_app\nGot dependencies! 0 errors.'},
        {'name': 'Run tests', 'status': 'success', 'duration': '42.1s', 'logs': 'Running `cargo test` in server/\n5 tests passed.\nRunning `flutter analyze` in apps/flutter_app/\nNo issues found!'},
        {'name': 'Build Linux', 'status': 'success', 'duration': '1m 52s', 'logs': 'Building Flutter Linux x64 bundle...\nGenerated build/linux/x64/release/bundle/codehub\nPackaged codehub-linux-x64.tar.gz (42.5 MB).'},
        {'name': 'Build Windows', 'status': 'success', 'duration': '1m 28s', 'logs': 'Building Flutter Windows x64 executable...\nGenerated build/windows/runner/Release/codehub.exe\nPackaged codehub-win-x64.exe (48.1 MB).'},
      ],
    },
    {
      'id': 'Build #181',
      'workflow': 'Flutter CI',
      'commit': '718c022 feat: implement Pull Requests section',
      'branch': 'main',
      'author': 'GranthikSom',
      'status': 'success',
      'duration': '1m 12s',
      'time': '45 mins ago',
      'steps': [
        {'name': 'Clone repository', 'status': 'success', 'duration': '0.3s', 'logs': 'git clone complete.'},
        {'name': 'Install dependencies', 'status': 'success', 'duration': '14.1s', 'logs': 'flutter pub get complete.'},
        {'name': 'Run flutter analyze', 'status': 'success', 'duration': '12.5s', 'logs': 'No issues found!'},
        {'name': 'Run unit tests', 'status': 'success', 'duration': '45.1s', 'logs': 'All widget tests passed.'},
      ],
    },
    {
      'id': 'Build #180',
      'workflow': 'Rust CI',
      'commit': 'a1ce771 security: enforce strict authentication guard',
      'branch': 'main',
      'author': 'GranthikSom',
      'status': 'success',
      'duration': '48s',
      'time': '2 hours ago',
      'steps': [
        {'name': 'Clone repository', 'status': 'success', 'duration': '0.3s', 'logs': 'git clone complete.'},
        {'name': 'Cargo check & clippy', 'status': 'success', 'duration': '15.2s', 'logs': '0 warnings, 0 errors.'},
        {'name': 'Cargo test', 'status': 'success', 'duration': '32.5s', 'logs': '5 passed, 0 failed.'},
      ],
    },
    {
      'id': 'Build #179',
      'workflow': 'Node CI',
      'commit': '5c0d7e1 refactor auth router',
      'branch': 'feature/dht-routing',
      'author': 'node_beta',
      'status': 'success',
      'duration': '34s',
      'time': '5 hours ago',
      'steps': [
        {'name': 'Clone repository', 'status': 'success', 'duration': '0.3s', 'logs': 'git clone complete.'},
        {'name': 'npm install & test', 'status': 'success', 'duration': '33.7s', 'logs': '14 API test suites passed.'},
      ],
    },
  ];

  List<Map<String, dynamic>> get _filteredRuns {
    if (_selectedWorkflow == 'All Workflows') return _runs;
    return _runs.where((r) => r['workflow'] == _selectedWorkflow).toList();
  }

  void _showRunWorkflowDialog() {
    String workflowToRun = 'Release Build';
    final branchController = TextEditingController(text: 'main');

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.play_circle_outline_rounded, color: Color(0xFF238636)),
              SizedBox(width: 10),
              Text('Run Workflow'),
            ],
          ),
          content: SizedBox(
            width: 450,
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: workflowToRun,
                      items: const [
                        DropdownMenuItem(value: 'Release Build', child: Text('Release Build (Linux/Windows/macOS)')),
                        DropdownMenuItem(value: 'Flutter CI', child: Text('Flutter CI (Analyze & Widget Tests)')),
                        DropdownMenuItem(value: 'Rust CI', child: Text('Rust CI (Cargo Test & Clippy)')),
                        DropdownMenuItem(value: 'Node CI', child: Text('Node CI (Axum Server Tests)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => workflowToRun = val);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Select Workflow',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: branchController,
                      decoration: const InputDecoration(
                        labelText: 'Branch / Tag',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF238636),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _runs.insert(0, {
                    'id': 'Build #${183 + _runs.length}',
                    'workflow': workflowToRun,
                    'commit': 'Manual trigger on ${branchController.text}',
                    'branch': branchController.text,
                    'author': 'GranthikSom',
                    'status': 'success',
                    'duration': '2m 14s',
                    'time': 'Just now',
                    'steps': [
                      {'name': 'Clone repository', 'status': 'success', 'duration': '0.4s', 'logs': 'Repository cloned.'},
                      {'name': 'Install dependencies', 'status': 'success', 'duration': '12.0s', 'logs': 'Dependencies resolved.'},
                      {'name': 'Run tests', 'status': 'success', 'duration': '30.0s', 'logs': 'All checks passed.'},
                      {'name': 'Build binaries', 'status': 'success', 'duration': '1m 31s', 'logs': 'Artifacts generated.'},
                    ],
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Triggered $workflowToRun on branch ${branchController.text}'),
                    backgroundColor: const Color(0xFF238636),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow_rounded, size: 16),
              label: const Text('Run Workflow'),
            ),
          ],
        );
      },
    );
  }

  void _showBuildDetailsModal(Map<String, dynamic> run) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final steps = run['steps'] as List<Map<String, String>>;

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF3FB950), size: 22),
              const SizedBox(width: 10),
              Text('${run['id']} • ${run['workflow']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(
                'Duration: ${run['duration']}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF58A6FF), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SizedBox(
            width: 600,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${run['commit']} • Branch: ${run['branch']} • Triggered by ${run['author']}',
                  style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pipeline Steps Execution:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Column(
                  children: steps.map((step) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check, color: Color(0xFF3FB950), size: 16),
                              const SizedBox(width: 8),
                              Text(
                                step['name']!,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                step['duration']!,
                                style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF161B22) : Colors.black87,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              step['logs']!,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                color: Color(0xFF7EE787),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Sidebar: Workflows List
          SizedBox(
            width: 220,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workflows',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                ..._workflowsList.map((wfName) {
                  final isSelected = _selectedWorkflow == wfName;
                  return InkWell(
                    onTap: () => setState(() => _selectedWorkflow = wfName),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF58A6FF).withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: isSelected
                            ? Border.all(color: const Color(0xFF58A6FF), width: 1.0)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            wfName == 'All Workflows' ? Icons.format_list_bulleted_rounded : Icons.play_circle_outline_rounded,
                            size: 16,
                            color: isSelected ? const Color(0xFF58A6FF) : (isDark ? Colors.white60 : Colors.black54),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            wfName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? const Color(0xFF58A6FF) : (isDark ? Colors.white : Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(width: 24),
          const VerticalDivider(width: 1, thickness: 1),
          const SizedBox(width: 24),

          // Main Workflow Runs Area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.play_circle_outline_rounded, color: Color(0xFF238636), size: 24),
                        const SizedBox(width: 10),
                        Text(
                          '$_selectedWorkflow Execution Runs',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _showRunWorkflowDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF238636),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 16),
                      label: const Text('Run Workflow', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Featured Build #182 Step Breakdown Banner
                if (_selectedWorkflow == 'All Workflows' || _selectedWorkflow == 'Release Build')
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161B22) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF3FB950), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF3FB950), size: 20),
                            const SizedBox(width: 10),
                            const Text(
                              'Featured Run: Build #182 (Release Build)',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF58A6FF).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF58A6FF)),
                              ),
                              child: const Text(
                                'Duration: 4m 21s',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF58A6FF)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _buildStepChip('✓ Clone repository', '0.4s'),
                            _buildStepChip('✓ Install dependencies', '18.2s'),
                            _buildStepChip('✓ Run tests', '42.1s'),
                            _buildStepChip('✓ Build Linux', '1m 52s'),
                            _buildStepChip('✓ Build Windows', '1m 28s'),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Workflow Runs List
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredRuns.length,
                    itemBuilder: (ctx, index) {
                      final run = _filteredRuns[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF161B22) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                        ),
                        child: InkWell(
                          onTap: () => _showBuildDetailsModal(run),
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF3FB950), size: 20),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '${run['id']} • ${run['workflow']}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF21262D) : Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            run['branch'] as String,
                                            style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Color(0xFF58A6FF)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${run['commit']} • by ${run['author']}',
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
                                    run['duration'] as String,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF58A6FF)),
                                  ),
                                  Text(
                                    run['time'] as String,
                                    style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepChip(String label, String duration) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF3FB950).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF3FB950), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3FB950)),
          ),
          const SizedBox(width: 6),
          Text(
            '($duration)',
            style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.grey),
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
