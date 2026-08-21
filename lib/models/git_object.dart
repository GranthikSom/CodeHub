enum GitObjectType { commit, tree, blob }

class GitObject {
  final String hash;
  final GitObjectType type;
  final String name;
  final int sizeBytes;
  final String? contentPayload;
  final List<String> replicaNodeIds;
  final List<GitObject> children;
  final String? author;
  final DateTime? timestamp;

  const GitObject({
    required this.hash,
    required this.type,
    required this.name,
    required this.sizeBytes,
    this.contentPayload,
    required this.replicaNodeIds,
    this.children = const [],
    this.author,
    this.timestamp,
  });

  String get shortHash => hash.length > 8 ? hash.substring(0, 8) : hash;

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
