import 'package:flutter_test/flutter_test.dart';
import 'package:codehub/main.dart';

void main() {
  testWidgets('CodeHub app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CodeHubApp());

    // Verify that CodeHub app splash screen displays CODEHUB branding.
    expect(find.text('CODEHUB'), findsOneWidget);
    expect(find.text('Decentralized P2P Code Hosting Platform'), findsOneWidget);

    // Advance time past the splash screen delay (2500ms)
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify that AuthScreen renders correctly
    expect(find.text('Sign In to CodeHub'), findsOneWidget);
  });
}
