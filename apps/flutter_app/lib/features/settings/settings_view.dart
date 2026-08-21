import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: Icon(Icons.storage, color: Colors.blue),
          title: Text('Local Blockstore Storage Limit', style: TextStyle(color: Colors.white)),
          subtitle: Text('20 GB Allocated / 4.8 GB Used', style: TextStyle(color: Colors.grey)),
        ),
        ListTile(
          leading: Icon(Icons.security, color: Colors.green),
          title: Text('Peer Identity Signing Keys', style: TextStyle(color: Colors.white)),
          subtitle: Text('Ed25519 Keypair Active (12D3KooW...)', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}
