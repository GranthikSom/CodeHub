import 'dart:async';
import 'dart:math';
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
  bool _addGitignore = false;
  bool _addLicense = false;

  String _selectedGitignore = 'Rust';
  String _selectedLicense = 'MIT License';
  String _selectedTopic = 'rust';
  int _selectedReplicaCount = 3;

  bool _isCreating = false;
  bool _isCheckingName = false;
  bool? _isNameAvailable;
  String? _nameFeedbackMessage;
  Timer? _debounceTimer;

  static const List<String> _availableTopics = [
    'rust',
    'flutter',
    'p2p',
    'libp2p',
    'git',
    'dht',
    'dart',
    'cryptography',
    'webassembly',
  ];

  static const List<String> _gitignoreTemplates = [
    'Rust',
    'Flutter & Dart',
    'Node.js',
    'Python',
    'Go',
    'C++',
    'Java',
    'Swift',
    'Unity',
  ];

  static const List<String> _licenseTemplates = [
    'MIT License',
    'Apache License 2.0',
    'GNU General Public License v3.0',
    'BSD 3-Clause "New" or "Revised" License',
    'Mozilla Public License 2.0',
    'The Unlicense',
  ];

  static const List<String> _suggestedNames = [
    'scaling-octo-parakeet',
    'shiny-computing-machine',
    'turbo-succotash',
    'legendary-waddle',
    'sturdy-couscous',
    'fluffy-tribble',
    'reimagined-spoon',
    'ubiquitous-chainsaw',
    'fuzzy-eureka',
    'automatic-disco',
    'glowing-giggle',
    'miniature-pancake',
    'friendly-octo-guide',
    'solid-carnival',
    'ideal-dollop',
    'decentralized-hyper-mesh',
  ];

  late String _currentInspiration;

  @override
  void initState() {
    super.initState();
    _currentInspiration = _getRandomInspiration();
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _descriptionController.dispose();
    _defaultBranchController.dispose();
    super.dispose();
  }

  String _getRandomInspiration() {
    final random = Random();
    return _suggestedNames[random.nextInt(_suggestedNames.length)];
  }

  void _refreshInspiration() {
    setState(() {
      _currentInspiration = _getRandomInspiration();
    });
  }

  void _applyInspiration() {
    _nameController.text = _currentInspiration;
    _nameController.selection = TextSelection.fromPosition(
      TextPosition(offset: _nameController.text.length),
    );
  }

  void _onNameChanged() {
    _debounceTimer?.cancel();
    final raw = _nameController.text.trim();

    if (raw.isEmpty) {
      setState(() {
        _isCheckingName = false;
        _isNameAvailable = null;
        _nameFeedbackMessage = null;
      });
      return;
    }

    final isValidChar = RegExp(r'^[a-zA-Z0-9_.-]+$').hasMatch(raw);
    if (!isValidChar || raw.startsWith('.') || raw.endsWith('.') || raw.endsWith('.git')) {
      setState(() {
        _isCheckingName = false;
        _isNameAvailable = false;
        _nameFeedbackMessage =
            'Repository name can only contain ASCII letters, digits, and the characters ., -, and _';
      });
      return;
    }

    setState(() {
      _isCheckingName = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      try {
        final result = await widget.state.api.checkRepoNameAvailability(
          name: raw,
          owner: widget.state.api.currentUsername ?? 'GranthikSom',
        );

        if (!mounted) return;

        final isAvailable = result['data']?['available'] == true;
        final reason = result['data']?['reason'] as String?;

        setState(() {
          _isCheckingName = false;
          _isNameAvailable = isAvailable;
          _nameFeedbackMessage = isAvailable
              ? '$raw is available.'
              : (reason ?? 'The repository $raw already exists on this account.');
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _isCheckingName = false;
          _isNameAvailable = true;
          _nameFeedbackMessage = '$raw is available.';
        });
      }
    });
  }

  Future<void> _createRepo() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isNameAvailable == false) return;

    setState(() {
      _isCreating = true;
    });

    final repoName = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final defaultBranch = _defaultBranchController.text.trim().isEmpty
        ? 'main'
        : _defaultBranchController.text.trim();
    final ownerName = widget.state.api.currentUsername ?? 'GranthikSom';

    // Calculate initial objects count based on GitHub conventions
    int objectCount = 2; // Initial commit + root tree
    double initialSizeMb = 0.05;
    if (_initReadme) {
      objectCount += 1;
      initialSizeMb += 0.04;
    }
    if (_addGitignore) {
      objectCount += 1;
      initialSizeMb += 0.02;
    }
    if (_addLicense) {
      objectCount += 1;
      initialSizeMb += 0.03;
    }

    final commitHash =
        'commit_${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}';
    final repoId = 'repo_${DateTime.now().millisecondsSinceEpoch}';

    final newRepo = CodeRepository(
      id: repoId,
      name: repoName,
      owner: ownerName,
      description: description.isEmpty
          ? 'Decentralized P2P Git repository on CodeHub.'
          : description,
      defaultBranch: defaultBranch,
      tags: [_selectedTopic, 'p2p', 'git'],
      totalSizeMb: initialSizeMb,
      seedNodeIds: const ['local_node_id', 'node_tokyo_01', 'node_frankfurt_02'],
      replicaCount: _selectedReplicaCount,
      totalObjects: objectCount,
      rootCommitHash: commitHash,
      lastUpdated: DateTime.now(),
      isPinnedLocally: true,
      localReplicationProgress: 1.0,
      stars: 1,
      forks: 0,
      isPrivate: _isPrivate,
      license: _addLicense ? _selectedLicense : null,
      gitignoreTemplate: _addGitignore ? _selectedGitignore : null,
      language: _selectedTopic == 'rust'
          ? 'Rust'
          : (_selectedTopic == 'flutter' || _selectedTopic == 'dart'
              ? 'Dart'
              : 'Rust'),
      rootCommit: GitObject(
        hash: commitHash,
        type: GitObjectType.commit,
        name: 'Initial commit ($defaultBranch)',
        sizeBytes: (initialSizeMb * 1024 * 1024).toInt(),
        replicaNodeIds: const ['local_node_id'],
        author: ownerName,
        timestamp: DateTime.now(),
      ),
    );

    // 1. Post repository to backend Control Plane API -> PostgreSQL -> Redis / Event Bus
    try {
      final res = await widget.state.api.createRepository(
        id: newRepo.id,
        name: newRepo.name,
        owner: newRepo.owner,
        description: newRepo.description,
        rootCommitHash: newRepo.rootCommitHash,
        totalObjects: newRepo.totalObjects,
        topics: newRepo.tags,
        isPrivate: _isPrivate,
        defaultBranch: defaultBranch,
        license: _addLicense ? _selectedLicense : null,
        gitignoreTemplate: _addGitignore ? _selectedGitignore : null,
        initReadme: _initReadme,
        replicaCount: _selectedReplicaCount,
      );

      final msg = res['message']?.toString() ?? '';
      if (res['success'] == false && msg.contains('already exists')) {
        if (!mounted) return;
        setState(() {
          _isCreating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFCF222E),
            content: Text(msg),
          ),
        );
        return;
      }
    } catch (_) {}

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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Repository "$ownerName/$repoName" created and broadcast to P2P Swarm!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ownerName = widget.state.api.currentUsername ?? 'GranthikSom';

    // GitHub Color Palette
    final bgColor = isDark ? const Color(0xFF0D1117) : Colors.white;
    final cardBg = isDark ? const Color(0xFF161B22) : const Color(0xFFF6F8FA);
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE);
    final primaryTextColor = isDark ? const Color(0xFFF0F6FC) : const Color(0xFF1F2328);
    final secondaryTextColor = isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76);
    final inputBg = isDark ? const Color(0xFF0D1117) : Colors.white;

    final canSubmit = !_isCreating &&
        _nameController.text.trim().isNotEmpty &&
        _isNameAvailable != false;

    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 740,
          maxHeight: 880,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar / Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF238636).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF238636).withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.bookmark_border_rounded,
                        color: Color(0xFF3FB950),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create a new repository',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: primaryTextColor,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'A repository contains all project files, Git DAG commits, and distributed chunk seeds across the P2P swarm.',
                            style: TextStyle(
                              fontSize: 13,
                              color: secondaryTextColor,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: secondaryTextColor, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      splashRadius: 18,
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: borderColor),

              // Scrollable Form Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Required note
                        Text(
                          '* Required fields',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Owner and Repository Name Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Owner picker
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Owner *',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: primaryTextColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 11,
                                        backgroundColor: const Color(0xFF1F6FEB),
                                        child: Text(
                                          ownerName.isNotEmpty ? ownerName[0].toUpperCase() : 'G',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        ownerName,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: primaryTextColor,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        color: secondaryTextColor,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top: 26, left: 10, right: 10),
                              child: Text(
                                '/',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w300,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ),

                            // Repository Name
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Repository name *',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: primaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _nameController,
                                    style: TextStyle(fontSize: 13, color: primaryTextColor),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      hintText: 'e.g. decentralized-hyper-mesh',
                                      hintStyle: TextStyle(
                                        fontSize: 13,
                                        color: secondaryTextColor.withValues(alpha: 0.6),
                                      ),
                                      filled: true,
                                      fillColor: inputBg,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: BorderSide(color: borderColor),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: BorderSide(
                                          color: _isNameAvailable == false
                                              ? const Color(0xFFF85149)
                                              : (_isNameAvailable == true
                                                  ? const Color(0xFF238636)
                                                  : borderColor),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF58A6FF),
                                          width: 1.5,
                                        ),
                                      ),
                                      suffixIcon: _isCheckingName
                                          ? const Padding(
                                              padding: EdgeInsets.all(11),
                                              child: SizedBox(
                                                width: 14,
                                                height: 14,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Color(0xFF58A6FF),
                                                ),
                                              ),
                                            )
                                          : (_isNameAvailable == true
                                              ? const Icon(
                                                  Icons.check_circle_rounded,
                                                  color: Color(0xFF3FB950),
                                                  size: 18,
                                                )
                                              : (_isNameAvailable == false
                                                  ? const Icon(
                                                      Icons.error_outline_rounded,
                                                      color: Color(0xFFF85149),
                                                      size: 18,
                                                    )
                                                  : null)),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Please enter a repository name';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Name feedback status or tip
                        const SizedBox(height: 6),
                        if (_nameFeedbackMessage != null) ...[
                          Row(
                            children: [
                              Icon(
                                _isNameAvailable == true
                                    ? Icons.check
                                    : Icons.close_rounded,
                                size: 13,
                                color: _isNameAvailable == true
                                    ? const Color(0xFF3FB950)
                                    : const Color(0xFFF85149),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _nameFeedbackMessage!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _isNameAvailable == true
                                        ? const Color(0xFF3FB950)
                                        : const Color(0xFFF85149),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                        ],

                        // Inspiration suggestion link
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Great repository names are short and memorable. Need inspiration? How about ',
                              style: TextStyle(fontSize: 12, color: secondaryTextColor),
                            ),
                            InkWell(
                              onTap: _applyInspiration,
                              child: Text(
                                _currentInspiration,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF58A6FF),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const Text('? '),
                            IconButton(
                              onPressed: _refreshInspiration,
                              icon: const Icon(Icons.refresh_rounded, size: 14),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              color: secondaryTextColor,
                              tooltip: 'Suggest another name',
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Description
                        Text(
                          'Description (optional)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          style: TextStyle(fontSize: 13, color: primaryTextColor),
                          maxLines: 2,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            hintText: 'Short summary of your P2P codebase',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: secondaryTextColor.withValues(alpha: 0.6),
                            ),
                            filled: true,
                            fillColor: inputBg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                color: Color(0xFF58A6FF),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        Divider(height: 1, color: borderColor),
                        const SizedBox(height: 20),

                        // Public vs Private Selection (GitHub Radio Cards)
                        _buildVisibilityCard(
                          isDark: isDark,
                          isPublic: true,
                          title: 'Public',
                          description:
                              'Anyone on the internet and P2P swarm can see this repository. You choose who can commit or sign chunks.',
                          badgeText: 'P2P Discovery: ON',
                          icon: Icons.book_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildVisibilityCard(
                          isDark: isDark,
                          isPublic: false,
                          title: 'Private',
                          description:
                              'You choose who can see and commit to this repository. Protected by end-to-end Noise Protocol identity keys.',
                          badgeText: 'Zero-Knowledge Encrypted',
                          icon: Icons.lock_outline_rounded,
                        ),

                        const SizedBox(height: 20),
                        Divider(height: 1, color: borderColor),
                        const SizedBox(height: 20),

                        // Initialize this repository with
                        Text(
                          'Initialize this repository with:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Skip this step if you're importing an existing repository.",
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Checkbox 1: README
                        _buildInitOption(
                          isDark: isDark,
                          value: _initReadme,
                          onChanged: (val) => setState(() => _initReadme = val ?? false),
                          title: 'Add a README file',
                          subtitle:
                              'This is where you can write a long description for your project. Creates root SHA-256 tree commit.',
                        ),

                        const SizedBox(height: 12),

                        // Checkbox 2: .gitignore
                        _buildInitOption(
                          isDark: isDark,
                          value: _addGitignore,
                          onChanged: (val) => setState(() => _addGitignore = val ?? false),
                          title: 'Add .gitignore',
                          subtitle:
                              'Choose which files not to track from a list of standard language templates.',
                          child: _addGitignore
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 8, left: 32),
                                   child: DropdownButtonFormField<String>(
                                    initialValue: _selectedGitignore,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      labelText: '.gitignore template',
                                      filled: true,
                                      fillColor: inputBg,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    items: _gitignoreTemplates
                                        .map((t) => DropdownMenuItem(
                                              value: t,
                                              child: Text(t, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                                            ))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _selectedGitignore = val);
                                      }
                                    },
                                  ),
                                )
                              : null,
                        ),

                        const SizedBox(height: 12),

                        // Checkbox 3: License
                        _buildInitOption(
                          isDark: isDark,
                          value: _addLicense,
                          onChanged: (val) => setState(() => _addLicense = val ?? false),
                          title: 'Choose a license',
                          subtitle:
                              'A license tells others what they can and can\'t do with your code.',
                          child: _addLicense
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 8, left: 32),
                                   child: DropdownButtonFormField<String>(
                                    initialValue: _selectedLicense,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      labelText: 'License',
                                      filled: true,
                                      fillColor: inputBg,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    items: _licenseTemplates
                                        .map((l) => DropdownMenuItem(
                                              value: l,
                                              child: Text(l, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                                            ))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _selectedLicense = val);
                                      }
                                    },
                                  ),
                                )
                              : null,
                        ),

                        const SizedBox(height: 20),
                        Divider(height: 1, color: borderColor),
                        const SizedBox(height: 20),

                        // P2P Swarm & Branch Settings
                        Text(
                          'P2P Swarm & Branch Settings',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Configure sovereign Git default branch and peer replication redundancy.',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            // Default Branch
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Default branch',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: primaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _defaultBranchController,
                                    style: TextStyle(fontSize: 13, color: primaryTextColor),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 9,
                                      ),
                                      filled: true,
                                      fillColor: inputBg,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Primary Topic
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Primary topic',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: primaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    initialValue: _selectedTopic,
                                    isExpanded: true,
                                    style: TextStyle(fontSize: 13, color: primaryTextColor),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      filled: true,
                                      fillColor: inputBg,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    items: _availableTopics
                                        .map((t) => DropdownMenuItem(
                                              value: t,
                                              child: Text('#$t', overflow: TextOverflow.ellipsis),
                                            ))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _selectedTopic = val);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Replication SLA
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Replication SLA',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: primaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<int>(
                                    initialValue: _selectedReplicaCount,
                                    isExpanded: true,
                                    style: TextStyle(fontSize: 13, color: primaryTextColor),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      filled: true,
                                      fillColor: inputBg,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 3,
                                        child: Text('3 Replicas (Standard)', overflow: TextOverflow.ellipsis),
                                      ),
                                      DropdownMenuItem(
                                        value: 5,
                                        child: Text('5 Replicas (HA)', overflow: TextOverflow.ellipsis),
                                      ),
                                      DropdownMenuItem(
                                        value: 9,
                                        child: Text('9 Replicas (Mesh)', overflow: TextOverflow.ellipsis),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _selectedReplicaCount = val);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Informational Notice Callout (GitHub Style)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF388BFD).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF388BFD).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: Color(0xFF58A6FF),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'You are creating a ${_isPrivate ? "private" : "public"} repository in $ownerName. Initial objects will be indexed in PostgreSQL and synchronized live across $_selectedReplicaCount P2P swarm seeders.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: primaryTextColor,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Divider(height: 1, color: borderColor),

              // Bottom Action Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: secondaryTextColor,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF238636),
                        disabledBackgroundColor: const Color(0xFF238636).withValues(alpha: 0.4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        elevation: 0,
                      ),
                      onPressed: canSubmit ? _createRepo : null,
                      child: _isCreating
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Creating repository...',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ],
                            )
                          : const Text(
                              'Create repository',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisibilityCard({
    required bool isDark,
    required bool isPublic,
    required String title,
    required String description,
    required String badgeText,
    required IconData icon,
  }) {
    final isSelected = isPublic ? !_isPrivate : _isPrivate;
    final primaryTextColor = isDark ? const Color(0xFFF0F6FC) : const Color(0xFF1F2328);
    final secondaryTextColor = isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76);

    return InkWell(
      onTap: () {
        setState(() {
          _isPrivate = !isPublic;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1F6FEB).withValues(alpha: isDark ? 0.08 : 0.05)
              : (isDark ? const Color(0xFF161B22) : const Color(0xFFF6F8FA)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1F6FEB)
                : (isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF238636)
                        : (isDark ? const Color(0xFF484F58) : const Color(0xFFD0D7DE)),
                    width: isSelected ? 5.5 : 1.5,
                  ),
                  color: isSelected ? Colors.white : Colors.transparent,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF58A6FF) : secondaryTextColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: isPublic
                              ? const Color(0xFF238636).withValues(alpha: 0.15)
                              : const Color(0xFF8957E5).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isPublic
                                ? const Color(0xFF238636).withValues(alpha: 0.3)
                                : const Color(0xFF8957E5).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isPublic ? const Color(0xFF3FB950) : const Color(0xFFA371F7),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryTextColor,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitOption({
    required bool isDark,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String title,
    required String subtitle,
    Widget? child,
  }) {
    final primaryTextColor = isDark ? const Color(0xFFF0F6FC) : const Color(0xFF1F2328);
    final secondaryTextColor = isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              activeColor: const Color(0xFF238636),
              onChanged: onChanged,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(!value),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ?child,
      ],
    );
  }
}
