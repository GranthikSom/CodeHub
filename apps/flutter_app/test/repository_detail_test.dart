import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:codehub/screens/repository_detail_screen.dart';
import 'package:codehub/models/repository_model.dart';
import 'package:codehub/models/git_object.dart';

void main() {
  testWidgets('RepositoryDetailScreen renders full GitHub-style layout and functions', (WidgetTester tester) async {
    final testRepo = CodeRepository(
      id: 'test-repo-1',
      name: 'unreaded',
      owner: 'cyberduck',
      description: 'Decentralized sovereign git repository for testing',
      rootCommitHash: '7976e58f2a1b9c4e21a3b5',
      totalSizeMb: 14.5,
      totalObjects: 120,
      replicaCount: 3,
      isPinnedLocally: true,
      localReplicationProgress: 1.0,
      seedNodeIds: ['peer-1', 'peer-2', 'peer-3'],
      rootCommit: GitObject(
        hash: '7976e58f2a1b9c4e21a3b5',
        type: GitObjectType.commit,
        name: 'commit 7976e58',
        sizeBytes: 1024,
        contentPayload: 'Initial commit',
        replicaNodeIds: ['peer-1', 'peer-2'],
      ),
      lastUpdated: DateTime.now(),
      stars: 42,
      forks: 4,
      tags: ['rust', 'flutter', 'p2p'],
    );

    // Set screen size to a desktop resolution so right sidebar is rendered
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: RepositoryDetailScreen(
          repoName: 'unreaded',
          owner: 'cyberduck',
          repository: testRepo,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify GitHub Header elements
    expect(find.text('cyberduck'), findsWidgets);
    expect(find.text('unreaded'), findsWidgets);
    expect(find.text('Public'), findsOneWidget);

    // 2. Verify GitHub action buttons
    expect(find.text('Pinned (3 peers)'), findsOneWidget);
    expect(find.text('Watch'), findsOneWidget);
    expect(find.text('Fork'), findsOneWidget);
    expect(find.text('Star'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);

    // 3. Test interactive Star toggle
    final starButton = find.text('Star');
    await tester.tap(starButton);
    await tester.pumpAndSettle();

    // Should now say Starred and incremented to 43
    expect(find.text('Starred'), findsOneWidget);
    expect(find.text('43'), findsOneWidget);

    // 4. Verify GitHub Navigation Tabs
    expect(find.text('Code'), findsWidgets);
    expect(find.text('Issues'), findsOneWidget);
    expect(find.text('Pull requests'), findsOneWidget);
    expect(find.text('Actions'), findsOneWidget);
    expect(find.text('Projects'), findsOneWidget);
    expect(find.text('Security'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Commits'), findsOneWidget);
    expect(find.text('Branches'), findsOneWidget);
    expect(find.text('Swarm Network'), findsOneWidget);
    expect(find.text('Settings (Access)'), findsOneWidget);

    // 5. Verify GitHub Controls in CodeBrowserView
    expect(find.text('main'), findsOneWidget);
    expect(find.text('3 branches'), findsOneWidget);
    expect(find.text('2 tags'), findsOneWidget);
    expect(find.text('Go to file'), findsOneWidget);
    expect(find.text('Add file'), findsOneWidget);

    // 6. Verify Latest Commit Banner
    expect(find.text('Verified'), findsOneWidget);
    expect(find.text('7976e58'), findsOneWidget);
    expect(find.text('24 commits'), findsOneWidget);

    // 7. Verify Files in Explorer Table
    expect(find.text('README.md'), findsWidgets);
    expect(find.text('Cargo.toml'), findsOneWidget);
    expect(find.text('.gitignore'), findsOneWidget);
    expect(find.text('LICENSE'), findsWidgets);

    // 8. Verify Right Sidebar (About, P2P Swarm Health, Releases, Contributors, Languages)
    expect(find.text('About'), findsOneWidget);
    expect(find.text('P2P Swarm Health'), findsOneWidget);
    expect(find.text('Releases'), findsOneWidget);
    expect(find.text('v1.0.0-p2p'), findsOneWidget);
    expect(find.text('Contributors 3'), findsOneWidget);
    expect(find.text('Languages'), findsOneWidget);
    expect(find.text('Rust'), findsOneWidget);
    expect(find.text('Dart'), findsOneWidget);
  });
}
