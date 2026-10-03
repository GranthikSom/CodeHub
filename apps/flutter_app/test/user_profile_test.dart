import 'package:flutter_test/flutter_test.dart';
import 'package:codehub/models/user_profile.dart';
import 'package:codehub/services/codehub_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserProfile & GitHub Profile Tests', () {
    test('Default user profile has correct initial fields and achievements', () {
      final profile = UserProfile.defaultFor(
        'soham',
        email: 'soham@codehub.p2p',
        role: 'developer',
        peerId: '12D3KooW_soham_NodeKey',
      );

      expect(profile.username, 'soham');
      expect(profile.displayName, 'Soham Mondal');
      expect(profile.email, 'soham@codehub.p2p');
      expect(profile.role, 'developer');
      expect(profile.peerId, '12D3KooW_soham_NodeKey');
      expect(profile.achievements.contains('Pull Shark'), isTrue);
      expect(profile.achievements.contains('Sovereign Pioneer'), isTrue);
      expect(profile.followersCount, 24);
      expect(profile.followingCount, 18);
    });

    test('Updating user profile creates copy with new fields', () {
      final initial = UserProfile.defaultFor('soham');
      final updated = initial.copyWith(
        displayName: 'Soham M.',
        bio: 'Updated P2P Architect bio',
        location: 'Bengaluru, India',
        statusEmoji: '🔥',
        statusText: 'Shipping sovereign Git',
      );

      expect(updated.displayName, 'Soham M.');
      expect(updated.bio, 'Updated P2P Architect bio');
      expect(updated.location, 'Bengaluru, India');
      expect(updated.statusEmoji, '🔥');
      expect(updated.statusText, 'Shipping sovereign Git');
      expect(updated.username, 'soham'); // Preserved
    });

    test('CodeHubState updates user profile and notifies listeners', () {
      final state = CodeHubState();
      expect(state.userProfile.username, 'soham');

      bool notified = false;
      state.addListener(() {
        notified = true;
      });

      state.updateUserProfile(
        displayName: 'Soham Mondal (Lead)',
        bio: 'Decentralized systems researcher',
        location: 'Remote',
      );

      expect(notified, isTrue);
      expect(state.userProfile.displayName, 'Soham Mondal (Lead)');
      expect(state.userProfile.bio, 'Decentralized systems researcher');
      expect(state.userProfile.location, 'Remote');

      state.setProfileStatus('⚡', 'High-throughput seeding');
      expect(state.userProfile.statusEmoji, '⚡');
      expect(state.userProfile.statusText, 'High-throughput seeding');

      state.dispose();
    });

    test('CodeHubState navigates to profile destination', () {
      final state = CodeHubState();
      int? destinationNavigated;
      state.onNavigateToDashboardTab = (idx) {
        destinationNavigated = idx;
      };

      state.navigateToProfile();
      expect(state.dashboardNavIndex, 8);
      expect(destinationNavigated, 8);

      state.dispose();
    });
  });
}
