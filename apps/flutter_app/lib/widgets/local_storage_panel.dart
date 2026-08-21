import 'package:flutter/material.dart';
import '../services/codehub_state.dart';

class LocalStoragePanel extends StatefulWidget {
  final CodeHubState? state;

  const LocalStoragePanel({super.key, this.state});

  @override
  State<LocalStoragePanel> createState() => _LocalStoragePanelState();
}

class _LocalStoragePanelState extends State<LocalStoragePanel> {
  final TextEditingController _customGbController = TextEditingController(text: '42.5');

  @override
  void dispose() {
    _customGbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeState = widget.state ?? CodeHubState();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pinnedRepos = activeState.repositories.where((r) => r.isPinnedLocally).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Storage Management & Contribution Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3FB950).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.sd_storage_outlined,
                        color: Color(0xFF3FB950),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Storage Management',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'Configure storage allocated for caching & seeding Git object DAG shards to the CodeHub P2P network.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Question Prompt
                Text(
                  'How much storage do you want to contribute?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Radio Presets
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildRadioPreset(activeState, StoragePreset.zero, '0 GB', isDark),
                    _buildRadioPreset(activeState, StoragePreset.gb5, '5 GB', isDark),
                    _buildRadioPreset(activeState, StoragePreset.gb20, '20 GB', isDark),
                    _buildRadioPreset(activeState, StoragePreset.gb50, '50 GB', isDark),
                    _buildRadioPreset(activeState, StoragePreset.gb100, '100 GB', isDark),
                    _buildRadioPreset(activeState, StoragePreset.custom, 'Custom', isDark),
                  ],
                ),

                // Custom Input Field if Custom is selected
                if (activeState.selectedStoragePreset == StoragePreset.custom) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Custom Storage Quota (GB):',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 120,
                        height: 38,
                        child: TextField(
                          controller: _customGbController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            suffixText: 'GB',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                color: isDark ? const Color(0xFF30363D) : Colors.grey.shade400,
                              ),
                            ),
                          ),
                          onSubmitted: (val) {
                            final parsed = double.tryParse(val);
                            if (parsed != null && parsed >= 0) {
                              activeState.setStoragePreset(StoragePreset.custom, customGb: parsed);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 28),
                const Divider(height: 1),
                const SizedBox(height: 24),

                // Metrics Breakdown (Contributed, Used, Available)
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'Storage contributed:',
                        '${activeState.storageContributedGb.toStringAsFixed(1)} GB',
                        const Color(0xFF58A6FF),
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        'Used:',
                        '${activeState.storageUsedGb.toStringAsFixed(1)} GB',
                        const Color(0xFFD29922),
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        'Available:',
                        '${activeState.storageAvailableGb.toStringAsFixed(1)} GB',
                        const Color(0xFF3FB950),
                        isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: activeState.storageContributedGb > 0
                        ? (activeState.storageUsedGb / activeState.storageContributedGb).clamp(0.0, 1.0)
                        : 0.0,
                    minHeight: 12,
                    backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3FB950)),
                  ),
                ),
                const SizedBox(height: 28),
                const Divider(height: 1),
                const SizedBox(height: 20),

                // Seeding Toggle Switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'P2P Swarm Seeding Engine',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Enable or disable background seeding of Git repository shards to nearby swarm peers.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          activeState.isSeedingEnabled ? 'Seeding Enabled' : 'Seeding Disabled',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: activeState.isSeedingEnabled ? const Color(0xFF3FB950) : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // ignore: deprecated_member_use
                        Switch(
                          value: activeState.isSeedingEnabled,
                          // ignore: deprecated_member_use
                          activeColor: const Color(0xFF3FB950),
                          onChanged: (val) => activeState.setSeedingEnabled(val),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

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
                Text(
                  'PINNED REPOSITORIES ON THIS NODE (${pinnedRepos.length})',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                  ),
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
                            onPressed: () => activeState.togglePinRepository(repo.id),
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

  Widget _buildRadioPreset(
    CodeHubState state,
    StoragePreset preset,
    String label,
    bool isDark,
  ) {
    final isSelected = state.selectedStoragePreset == preset;
    return InkWell(
      onTap: () {
        if (preset == StoragePreset.custom) {
          final customVal = double.tryParse(_customGbController.text) ?? 42.5;
          state.setStoragePreset(preset, customGb: customVal);
        } else {
          state.setStoragePreset(preset);
        }
      },
      borderRadius: BorderRadius.circular(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ignore: deprecated_member_use
          Radio<StoragePreset>(
            value: preset,
            // ignore: deprecated_member_use
            groupValue: state.selectedStoragePreset,
            // ignore: deprecated_member_use
            activeColor: const Color(0xFF3FB950),
            // ignore: deprecated_member_use
            onChanged: (val) {
              if (val != null) {
                if (val == StoragePreset.custom) {
                  final customVal = double.tryParse(_customGbController.text) ?? 42.5;
                  state.setStoragePreset(val, customGb: customVal);
                } else {
                  state.setStoragePreset(val);
                }
              }
            },
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF21262D) : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
