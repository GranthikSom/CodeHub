import 'package:flutter/material.dart';
import '../models/git_object.dart';
import '../models/p2p_node.dart';
import '../services/codehub_state.dart';

class GitObjectDagView extends StatelessWidget {
  final CodeHubState? state;

  const GitObjectDagView({super.key, this.state});

  @override
  Widget build(BuildContext context) {
    final activeState = state ?? CodeHubState();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repo = activeState.selectedRepo;

    if (repo == null) {
      return Center(
        child: Text(
          'Select a repository to explore its Git object DAG.',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
      );
    }

    final selectedObj = activeState.selectedGitObject ?? repo.rootCommit;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Repository selector & Object Tree Navigation
        Expanded(
          flex: 4,
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
                // Repository Selector Header
                Row(
                  children: [
                    Icon(
                      Icons.account_tree,
                      color: isDark ? const Color(0xFFBC8CFF) : Colors.purple,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Content-Addressed DAG',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Explore immutable commit, tree, and blob objects identified by SHA hashes.',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),

                // Repository Dropdown / Picker
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: repo.id,
                      isExpanded: true,
                      dropdownColor: isDark ? const Color(0xFF161B22) : Colors.white,
                      items: activeState.repositories.map((r) {
                        return DropdownMenuItem<String>(
                          value: r.id,
                          child: Text(
                            '${r.owner} / ${r.name}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (id) {
                        if (id != null) activeState.selectRepository(id);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Divider(height: 1),
                const SizedBox(height: 12),

                // Interactive Object DAG Tree
                Text(
                  'OBJECT GRAPH TREE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: SingleChildScrollView(
                    child: _buildDagObjectNode(
                      context: context,
                      object: repo.rootCommit,
                      depth: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Right Column: Object Inspector & Replica Peer Mapping
        Expanded(
          flex: 6,
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
                // Selected Object Header
                Row(
                  children: [
                    _getObjectTypeIcon(selectedObj.type),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedObj.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            selectedObj.hash,
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: isDark ? const Color(0xFF58A6FF) : Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getObjectTypeColor(selectedObj.type).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _getObjectTypeColor(selectedObj.type),
                        ),
                      ),
                      child: Text(
                        selectedObj.type.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getObjectTypeColor(selectedObj.type),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // P2P Replication Replica Mapping Matrix
                Text(
                  'P2P OBJECT SHARD REPLICATION MATRIX',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    children: activeState.nodes.where((n) => n.type != NodeType.controlRelay).map((node) {
                      final hasReplica = selectedObj.replicaNodeIds.contains(node.id);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              hasReplica ? Icons.check_circle : Icons.cancel_outlined,
                              size: 16,
                              color: hasReplica ? const Color(0xFF3FB950) : (isDark ? const Color(0xFF484F58) : Colors.grey.shade400),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              node.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: hasReplica ? FontWeight.bold : FontWeight.normal,
                                color: hasReplica
                                    ? (isDark ? Colors.white : Colors.black87)
                                    : (isDark ? const Color(0xFF8B949E) : Colors.grey.shade600),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              hasReplica ? 'Object Replica Stored (${node.ipAddress})' : 'Not Replicated Here',
                              style: TextStyle(
                                fontSize: 10,
                                fontFamily: 'monospace',
                                color: hasReplica
                                    ? const Color(0xFF3FB950)
                                    : (isDark ? const Color(0xFF484F58) : Colors.grey.shade500),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Content Payload Preview (For blobs)
                Text(
                  'OBJECT CONTENT PAYLOAD',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? const Color(0xFF30363D) : Colors.black,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        selectedObj.contentPayload ??
                            (selectedObj.type == GitObjectType.commit
                                ? 'Author: ${selectedObj.author}\nTimestamp: ${selectedObj.timestamp}\nCommit message: ${selectedObj.name}\nRoot Tree: ${selectedObj.children.firstOrNull?.hash ?? "N/A"}'
                                : 'Directory Tree containing ${selectedObj.children.length} sub-objects.'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Color(0xFFC9D1D9),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Repository Versioning & Immutable Delta Replication Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
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
                              const Icon(Icons.difference_outlined, size: 16, color: Color(0xFF58A6FF)),
                              const SizedBox(width: 8),
                              Text(
                                'Repository Versioning & Delta Sync',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF238636).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF3FB950), width: 0.8),
                            ),
                            child: const Text(
                              '99% Bandwidth Saved',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3FB950),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Immutable Commit Chain Visualiser Diagram: Commit A -> Commit B -> Commit C
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildCommitNode('Commit A', 'v1: 500 MB', isDark),
                          const Icon(Icons.arrow_right_alt, color: Color(0xFF8B949E), size: 20),
                          _buildCommitNode('Commit B', 'delta: 2 MB', isDark),
                          const Icon(Icons.arrow_right_alt, color: Color(0xFF8B949E), size: 20),
                          _buildCommitNode('Commit C', 'v2: 505 MB', isDark, isTarget: true),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Metric Grid: Base (500MB) vs Target (505MB) -> Transfer (5MB)
                      Row(
                        children: [
                          _buildDeltaStat('Version 1 Base', '${activeState.baseVersionMb.toStringAsFixed(0)} MB', isDark),
                          _buildDeltaStat('Version 2 Target', '${activeState.targetVersionMb.toStringAsFixed(0)} MB', isDark),
                          _buildDeltaStat('P2P Delta Transfer', '${activeState.deltaTransferMb.toStringAsFixed(0)} MB', isDark, isHighlight: true),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Trigger Button & Live Status
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: activeState.isDeltaSyncRunning
                                ? null
                                : () => activeState.runDeltaSyncSimulation(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF238636),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            icon: activeState.isDeltaSyncRunning
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.sync_alt, size: 14),
                            label: Text(
                              activeState.isDeltaSyncRunning ? 'Syncing Delta...' : 'Simulate Delta Sync',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              activeState.deltaSyncStatus,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDagObjectNode({
    required BuildContext context,
    required GitObject object,
    required int depth,
  }) {
    final activeState = state ?? CodeHubState();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = activeState.selectedGitObject?.hash == object.hash;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => activeState.selectGitObject(object),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: EdgeInsets.only(
              left: 8.0 + (depth * 16.0),
              right: 8.0,
              top: 6.0,
              bottom: 6.0,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? const Color(0xFF21262D) : Colors.blue.shade100)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected
                    ? (isDark ? const Color(0xFF58A6FF) : Colors.blue)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                _getObjectTypeIcon(object.type),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    object.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  object.shortHash,
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (object.children.isNotEmpty)
          ...object.children.map((child) {
            return _buildDagObjectNode(
              context: context,
              object: child,
              depth: depth + 1,
            );
          }),
      ],
    );
  }

  Widget _getObjectTypeIcon(GitObjectType type) {
    switch (type) {
      case GitObjectType.commit:
        return const Icon(Icons.commit, size: 16, color: Color(0xFFBC8CFF));
      case GitObjectType.tree:
        return const Icon(Icons.folder, size: 16, color: Color(0xFF58A6FF));
      case GitObjectType.blob:
        return const Icon(Icons.insert_drive_file_outlined, size: 16, color: Color(0xFF3FB950));
    }
  }

  Color _getObjectTypeColor(GitObjectType type) {
    switch (type) {
      case GitObjectType.commit:
        return const Color(0xFFBC8CFF);
      case GitObjectType.tree:
        return const Color(0xFF58A6FF);
      case GitObjectType.blob:
        return const Color(0xFF3FB950);
    }
  }

  Widget _buildCommitNode(String title, String subtitle, bool isDark, {bool isTarget = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isTarget
            ? const Color(0xFF238636).withValues(alpha: 0.15)
            : (isDark ? const Color(0xFF161B22) : Colors.white),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isTarget
              ? const Color(0xFF3FB950)
              : (isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isTarget
                  ? const Color(0xFF3FB950)
                  : (isDark ? Colors.white : Colors.black87),
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9,
              color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeltaStat(String label, String value, bool isDark, {bool isHighlight = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isHighlight
              ? const Color(0xFF238636).withValues(alpha: 0.15)
              : (isDark ? const Color(0xFF161B22) : Colors.white),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isHighlight
                ? const Color(0xFF3FB950)
                : (isDark ? const Color(0xFF21262D) : Colors.grey.shade300),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isHighlight
                    ? const Color(0xFF3FB950)
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
