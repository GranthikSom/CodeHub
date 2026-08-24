import 'package:flutter/material.dart';
import '../models/repository_model.dart';
import '../models/git_object.dart';
import '../services/codehub_state.dart';

class CreateRepositoryDialog extends StatefulWidget {
  final CodeHubState state;

  const CreateRepositoryDialog({super.key, required this.state});

  @override
  State<CreateRepositoryDialog> createState() => _CreateRepositoryDialogState();
}

class _CreateRepositoryDialogState extends State<CreateRepositoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _defaultBranchController = TextEditingController(text: 'main');
  
  bool _isPrivate = false;
  bool _initReadme = true;
  String _selectedTopic = 'rust';
  bool _isCreating = false;

  final List<String> _availableTopics = ['rust', 'flutter', 'p2p', 'libp2p', 'git', 'dht', 'dart'];

  Future<void> _createRepo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
    });

    final repoName = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final defaultBranch = _defaultBranchController.text.trim().isEmpty
        ? 'main'
        : _defaultBranchController.text.trim();

    final newRepo = CodeRepository(
      id: 'repo_${DateTime.now().millisecondsSinceEpoch}',
      name: repoName,
      owner: 'GranthikSom',
      description: description.isEmpty ? 'Decentralized P2P Git repository.' : description,
      defaultBranch: defaultBranch,
      tags: [_selectedTopic, 'p2p', 'git'],
      totalSizeMb: _initReadme ? 0.48 : 0.05,
      seedNodeIds: const ['local_node_id', 'node_tokyo_01'],
      replicaCount: 3,
      totalObjects: _initReadme ? 3 : 1,
      rootCommitHash: 'commit_${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
      lastUpdated: DateTime.now(),
      isPinnedLocally: true,
      localReplicationProgress: 1.0,
      stars: 1,
      forks: 0,
      rootCommit: GitObject(
        hash: 'commit_${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
        type: GitObjectType.commit,
        name: 'Initial Commit',
        sizeBytes: 480,
        replicaNodeIds: const ['local_node_id'],
        author: 'GranthikSom',
        timestamp: DateTime.now(),
      ),
    );

    // 1. Post repository to CodeHub API -> PostgreSQL -> Event Bus / Redis
    await widget.state.api.createRepository(
      id: newRepo.id,
      name: newRepo.name,
      owner: newRepo.owner,
      description: newRepo.description,
      rootCommitHash: newRepo.rootCommitHash,
      totalObjects: newRepo.totalObjects,
      topics: newRepo.tags,
      isPrivate: _isPrivate,
    );

    // 2. Local state update
    widget.state.addRepository(newRepo);

    if (!mounted) return;

    setState(() {
      _isCreating = false;
    });

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF238636),
        content: Text('Repository "$repoName" created & broadcast live via Redis Event Bus to P2P Swarm!'),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF238636).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.create_new_folder_outlined, color: Color(0xFF3FB950), size: 22),
          ),
          const SizedBox(width: 12),
          Text(
            'Create a New Repository',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Owner',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: Color(0xFF58A6FF),
                        child: Text('G', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'GranthikSom (You)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Repository Name *',
                    hintText: 'e.g. codehub-core-p2p',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a repository name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Short summary of your P2P codebase',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _defaultBranchController,
                        decoration: const InputDecoration(
                          labelText: 'Default Branch',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedTopic,
                        decoration: const InputDecoration(
                          labelText: 'Primary Topic',
                          border: OutlineInputBorder(),
                        ),
                        items: _availableTopics
                            .map((t) => DropdownMenuItem(value: t, child: Text('#$t')))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedTopic = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                CheckboxListTile(
                  value: _initReadme,
                  onChanged: (val) => setState(() => _initReadme = val ?? true),
                  title: const Text('Initialize repository with a README.md'),
                  subtitle: const Text('Creates an initial commit with root SHA-256 tree hash'),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  value: _isPrivate,
                  onChanged: (val) => setState(() => _isPrivate = val ?? false),
                  title: const Text('Private Repository (Encrypted P2P Swarm)'),
                  subtitle: const Text('Requires noise identity keys to read and sync chunks'),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF238636),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          onPressed: _isCreating ? null : _createRepo,
          child: _isCreating
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Create Repository', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
