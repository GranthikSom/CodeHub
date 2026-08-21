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

          // Section 2: Bandwidth & Laptop Power Management Card
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
                        color: const Color(0xFF58A6FF).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.speed_outlined,
                        color: Color(0xFF58A6FF),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bandwidth & Power Management',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'Set maximum transfer speed limits, peer connections, and battery power policies for laptops.',
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

                // Bandwidth Limits Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildBandwidthCard(
                        'Upload limit:',
                        '${activeState.uploadLimitMbps.toStringAsFixed(0)} MB/s',
                        Icons.upload_sharp,
                        const Color(0xFF3FB950),
                        activeState.uploadLimitMbps,
                        1.0,
                        100.0,
                        (val) => activeState.setUploadLimit(val),
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildBandwidthCard(
                        'Download limit:',
                        '${activeState.downloadLimitMbps.toStringAsFixed(0)} MB/s',
                        Icons.download_sharp,
                        const Color(0xFF58A6FF),
                        activeState.downloadLimitMbps,
                        5.0,
                        500.0,
                        (val) => activeState.setDownloadLimit(val),
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildBandwidthCard(
                        'Maximum peers:',
                        '${activeState.maxPeersLimit} peers',
                        Icons.hub_outlined,
                        const Color(0xFFA371F7),
                        activeState.maxPeersLimit.toDouble(),
                        5.0,
                        100.0,
                        (val) => activeState.setMaxPeersLimit(val.round()),
                        isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(height: 1),
                const SizedBox(height: 20),

                // Power & Laptop Seeding Policies
                Text(
                  'Laptop Power & Seeding Policies',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 14),

                // Seed while idle (✓)
                InkWell(
                  onTap: () => activeState.setSeedWhileIdle(!activeState.seedWhileIdle),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: activeState.seedWhileIdle
                                ? const Color(0xFF238636)
                                : (isDark ? const Color(0xFF21262D) : Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: activeState.seedWhileIdle
                              ? const Icon(Icons.check, size: 18, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Seed while idle',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              'Allows background Git object chunk seeding when system is idle.',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Seed while battery (✗)
                InkWell(
                  onTap: () => activeState.setSeedOnBattery(!activeState.seedOnBattery),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: activeState.seedOnBattery
                                ? const Color(0xFF238636)
                                : (isDark ? const Color(0xFF21262D) : Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: activeState.seedOnBattery
                              ? const Icon(Icons.check, size: 18, color: Colors.white)
                              : const Icon(Icons.close, size: 18, color: Color(0xFFF85149)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Seed while battery',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF85149).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Important on Laptops',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFF85149),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Pauses P2P seeding when running on battery to conserve laptop battery life.',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 3: Garbage Collection & 30-Day Grace Period Manager Card
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD29922).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.auto_delete_outlined,
                            color: Color(0xFFD29922),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Garbage Collection & Orphan Chunk Management',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              'Prevents orphaned Git object chunks from cluttering disk storage when repositories are deleted.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: activeState.isGcRunning
                          ? null
                          : () => activeState.triggerGarbageCollection(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF238636),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: activeState.isGcRunning
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.cleaning_services, size: 16),
                      label: Text(
                        activeState.isGcRunning ? 'Running GC...' : 'Run Garbage Collection',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Reference Tracking Flow Diagram Card: Object -> Referenced? -> YES (keep) / NO (30-day grace)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF21262D) : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.account_tree_outlined, size: 16, color: isDark ? const Color(0xFF58A6FF) : Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Object Reference Tracking Logic',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildGcFlowBox('Object', isDark),
                          const Icon(Icons.arrow_right_alt, color: Color(0xFF8B949E)),
                          _buildGcFlowBox('Referenced?', isDark, isHighlight: true),
                          const Icon(Icons.arrow_right_alt, color: Color(0xFF8B949E)),
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF238636).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: const Color(0xFF3FB950)),
                                ),
                                child: const Text(
                                  'YES → keep',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF3FB950)),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD29922).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: const Color(0xFFD29922)),
                                ),
                                child: const Text(
                                  'NO → 30-day grace period candidate',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD29922)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Metrics Breakdown Grid (Candidates, Grace Period, Reclaimable Space)
                Row(
                  children: [
                    Expanded(
                      child: _buildGcStatCard(
                        'Unreferenced Candidate Chunks',
                        '${activeState.gcCandidateCount} chunks',
                        Icons.collections_bookmark_outlined,
                        const Color(0xFFD29922),
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildGcStatCard(
                        'Safety Grace Period',
                        '${activeState.gracePeriodDays} Days Grace',
                        Icons.timer_outlined,
                        const Color(0xFF58A6FF),
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildGcStatCard(
                        'Reclaimable Disk Space',
                        '${activeState.reclaimableGb} GB',
                        Icons.cleaning_services_outlined,
                        const Color(0xFF3FB950),
                        isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Grace Period Notice Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161B22) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Color(0xFF58A6FF)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          activeState.gcLastStatus,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
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

  Widget _buildBandwidthCard(
    String label,
    String value,
    IconData icon,
    Color color,
    double currentVal,
    double minVal,
    double maxVal,
    ValueChanged<double> onChanged,
    bool isDark,
  ) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: currentVal.clamp(minVal, maxVal),
            min: minVal,
            max: maxVal,
            activeColor: color,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildGcFlowBox(String title, bool isDark, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlight
            ? const Color(0xFF58A6FF).withValues(alpha: 0.15)
            : (isDark ? const Color(0xFF161B22) : Colors.white),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isHighlight
              ? const Color(0xFF58A6FF)
              : (isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isHighlight
              ? const Color(0xFF58A6FF)
              : (isDark ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildGcStatCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF21262D) : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
