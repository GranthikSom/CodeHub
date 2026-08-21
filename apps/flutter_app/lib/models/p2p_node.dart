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
    );
  }
}
