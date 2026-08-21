import 'package:flutter/material.dart';

class CommitHistoryView extends StatelessWidget {
  final String repoId;
  const CommitHistoryView({super.key, required this.repoId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: Icon(Icons.commit, color: Colors.blue),
          title: Text('feat: Phase 16 Complete Final Production Target Architecture', style: TextStyle(color: Colors.white)),
          subtitle: Text('e541a0d • Committed by @soham 10 mins ago', style: TextStyle(color: Colors.grey)),
        ),
        ListTile(
          leading: Icon(Icons.commit, color: Colors.grey),
          title: Text('feat: complete Phase 15 Multi-Tier Seed Server Mesh Engine', style: TextStyle(color: Colors.white)),
          subtitle: Text('4bfb243 • Committed by @soham 30 mins ago', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}
