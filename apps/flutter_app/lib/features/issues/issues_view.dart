import 'package:flutter/material.dart';

class IssuesView extends StatelessWidget {
  final String repoId;
  const IssuesView({super.key, required this.repoId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: Icon(Icons.error_outline, color: Colors.green),
          title: Text('#1 Add automatic BitSwap chunk re-replication', style: TextStyle(color: Colors.white)),
          subtitle: Text('Opened 1 day ago by @soham', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}
