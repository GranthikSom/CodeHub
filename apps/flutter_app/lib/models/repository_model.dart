import 'git_object.dart';

class CodeRepository {
  final String id;
  final String name;
  final String owner;
  final String description;
  final String defaultBranch;
  final String rootCommitHash;
  final double totalSizeMb;
  final int totalObjects;
  final int replicaCount;
  final bool isPinnedLocally;
  final double localReplicationProgress; // 0.0 to 1.0
  final List<String> seedNodeIds;
  final GitObject rootCommit;
  final DateTime lastUpdated;
  final int stars;
  final int forks;
  final List<String> tags;

  const CodeRepository({
    required this.id,
    required this.name,
    required this.owner,
    required this.description,
    this.defaultBranch = 'main',
    required this.rootCommitHash,
    required this.totalSizeMb,
    required this.totalObjects,
    required this.replicaCount,
    required this.isPinnedLocally,
    required this.localReplicationProgress,
    required this.seedNodeIds,
    required this.rootCommit,
    required this.lastUpdated,
    required this.stars,
    required this.forks,
    required this.tags,
  });

  CodeRepository copyWith({
    bool? isPinnedLocally,
    double? localReplicationProgress,
    int? replicaCount,
    List<String>? seedNodeIds,
    int? stars,
    int? forks,
  }) {
    return CodeRepository(
      id: id,
      name: name,
      owner: owner,
      description: description,
      defaultBranch: defaultBranch,
      rootCommitHash: rootCommitHash,
      totalSizeMb: totalSizeMb,
      totalObjects: totalObjects,
      replicaCount: replicaCount ?? this.replicaCount,
      isPinnedLocally: isPinnedLocally ?? this.isPinnedLocally,
      localReplicationProgress: localReplicationProgress ?? this.localReplicationProgress,
      seedNodeIds: seedNodeIds ?? this.seedNodeIds,
      rootCommit: rootCommit,
      lastUpdated: lastUpdated,
      stars: stars ?? this.stars,
      forks: forks ?? this.forks,
      tags: tags,
    );
  }
}
