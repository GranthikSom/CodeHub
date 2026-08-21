import 'package:flutter/material.dart';

class PeersView extends StatelessWidget {
  const PeersView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: Icon(Icons.cloud_done, color: Colors.green),
          title: Text('storage-node-us-east-1 (Dedicated Seed Node)', style: TextStyle(color: Colors.white)),
          subtitle: Text('US East (N. Virginia) • 99.99% Uptime SLA', style: TextStyle(color: Colors.grey)),
        ),
        ListTile(
          leading: Icon(Icons.laptop, color: Colors.blue),
          title: Text('Peer B (Laptop Node)', style: TextStyle(color: Colors.white)),
          subtitle: Text('Germany (Frankfurt) • 22ms latency', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}
