import 'package:flutter/material.dart';

class PullRequestsView extends StatelessWidget {
  final String repoId;
  const PullRequestsView({super.key, required this.repoId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: Icon(Icons.merge_type, color: Colors.purple),
          title: Text('#42 Implement Zero-Knowledge Private Repo Access Control', style: TextStyle(color: Colors.white)),
          subtitle: Text('Merged by @soham', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}
