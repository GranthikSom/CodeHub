import '../models/p2p_node.dart';

class P2PService {
  final List<P2PNode> _connectedPeers = [];

  List<P2PNode> get connectedPeers => List.unmodifiable(_connectedPeers);

  Future<void> initializeSwarm() async {
    // Initializing libp2p swarm engine
  }

  Future<void> connectToPeer(String multiaddr) async {
    // Connecting to peer multiaddr
  }
}
