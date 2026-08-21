enum NodeType { peerDevice, seedNode, controlRelay, localNode }

class P2PNode {
  final String id;
  final String name;
  final String ipAddress;
  final NodeType type;
  final int pingMs;
  final double storageAllocatedGb;
  final double storageUsedGb;
  final double uploadSpeedMbps;
  final double downloadSpeedMbps;
  final bool isLocal;
  final bool isOnline;
  final List<String> pinnedRepoIds;

  // Peer Reputation & Health Metrics
  final double uptimePercent;
  final double availabilityPercent;
  final int successfulTransfers;
  final int failedTransfers;
  final int starRating;
  final bool isPreferred;

  const P2PNode({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.type,
    required this.pingMs,
    required this.storageAllocatedGb,
    required this.storageUsedGb,
    required this.uploadSpeedMbps,
    required this.downloadSpeedMbps,
    this.isLocal = false,
    this.isOnline = true,
    required this.pinnedRepoIds,
    this.uptimePercent = 98.4,
    this.availabilityPercent = 99.1,
    this.successfulTransfers = 12492,
    this.failedTransfers = 13,
    this.starRating = 5,
    this.isPreferred = true,
  });

  P2PNode copyWith({
    String? name,
    int? pingMs,
    double? storageAllocatedGb,
    double? storageUsedGb,
    double? uploadSpeedMbps,
    double? downloadSpeedMbps,
    bool? isOnline,
    List<String>? pinnedRepoIds,
    double? uptimePercent,
    double? availabilityPercent,
    int? successfulTransfers,
    int? failedTransfers,
    int? starRating,
    bool? isPreferred,
  }) {
    return P2PNode(
      id: id,
      name: name ?? this.name,
      ipAddress: ipAddress,
      type: type,
      pingMs: pingMs ?? this.pingMs,
      storageAllocatedGb: storageAllocatedGb ?? this.storageAllocatedGb,
      storageUsedGb: storageUsedGb ?? this.storageUsedGb,
      uploadSpeedMbps: uploadSpeedMbps ?? this.uploadSpeedMbps,
      downloadSpeedMbps: downloadSpeedMbps ?? this.downloadSpeedMbps,
      isLocal: isLocal,
      isOnline: isOnline ?? this.isOnline,
      pinnedRepoIds: pinnedRepoIds ?? this.pinnedRepoIds,
      uptimePercent: uptimePercent ?? this.uptimePercent,
      availabilityPercent: availabilityPercent ?? this.availabilityPercent,
      successfulTransfers: successfulTransfers ?? this.successfulTransfers,
      failedTransfers: failedTransfers ?? this.failedTransfers,
      starRating: starRating ?? this.starRating,
      isPreferred: isPreferred ?? this.isPreferred,
    );
  }
}
