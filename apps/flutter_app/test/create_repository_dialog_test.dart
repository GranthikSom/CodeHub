import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:codehub/widgets/create_repository_dialog.dart';
import 'package:codehub/services/codehub_state.dart';

void main() {
  testWidgets('CreateRepositoryDialog renders GitHub-style layout and creates repo',
      (WidgetTester tester) async {
    final state = CodeHubState();
    final initialCount = state.repositories.length;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => CreateRepositoryDialog(state: state),
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );

    // Open the dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // 1. Verify GitHub-like header and subtitles
    expect(find.text('Create a new repository'), findsOneWidget);
    expect(
      find.text(
        'A repository contains all project files, Git DAG commits, and distributed chunk seeds across the P2P swarm.',
      ),
      findsOneWidget,
    );
    expect(find.text('* Required fields'), findsOneWidget);

    // 2. Verify Owner and Repository Name fields
    expect(find.text('Owner *'), findsOneWidget);
    expect(find.text('GranthikSom'), findsWidgets);
    expect(find.text('Repository name *'), findsOneWidget);

    // 3. Verify Visibility Cards (Public & Private)
    expect(find.text('Public'), findsOneWidget);
    expect(find.text('Private'), findsOneWidget);
    expect(find.text('P2P Discovery: ON'), findsOneWidget);
    expect(find.text('Zero-Knowledge Encrypted'), findsOneWidget);

    // 4. Verify Initialization options
    expect(find.text('Initialize this repository with:'), findsOneWidget);
    expect(find.text('Add a README file'), findsOneWidget);
    expect(find.text('Add .gitignore'), findsOneWidget);
    expect(find.text('Choose a license'), findsOneWidget);

    // 5. Verify P2P Swarm & Branch Settings
    expect(find.text('P2P Swarm & Branch Settings'), findsOneWidget);
    expect(find.text('Default branch'), findsOneWidget);
    expect(find.text('Primary topic'), findsOneWidget);
    expect(find.text('Replication SLA'), findsOneWidget);

    // 6. Enter a repository name
    final nameField = find.widgetWithText(TextFormField, 'e.g. decentralized-hyper-mesh');
    expect(nameField, findsOneWidget);
    await tester.enterText(nameField, 'test-github-repo');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // 7. Click Create repository button
    final createBtn = find.text('Create repository');
    expect(createBtn, findsOneWidget);
    await tester.tap(createBtn);
    await tester.pumpAndSettle();

    // 8. Dialog should be dismissed and repository added to state
    expect(find.text('Create a new repository'), findsNothing);
    expect(state.repositories.length, equals(initialCount + 1));
    expect(state.repositories.first.name, equals('test-github-repo'));
    expect(state.repositories.first.owner, equals('GranthikSom'));

    // Clean up timers
    state.dispose();
  });
}
