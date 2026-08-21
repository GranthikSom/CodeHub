import 'package:flutter/material.dart';

class BranchesView extends StatelessWidget {
  final String repoId;
  const BranchesView({super.key, required this.repoId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: Icon(Icons.call_split, color: Colors.blue),
          title: Text('main (default)', style: TextStyle(color: Colors.white)),
          subtitle: Text('Updated 2 mins ago by uploader', style: TextStyle(color: Colors.grey)),
        ),
        ListTile(
          leading: Icon(Icons.call_split, color: Colors.grey),
          title: Text('feat/p2p-hardening', style: TextStyle(color: Colors.white)),
          subtitle: Text('Updated 1 hour ago', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}
