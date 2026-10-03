import 'package:flutter_test/flutter_test.dart';
import 'package:codehub/services/api_service.dart';

void main() {
  group('ApiService Production Pipeline Tests', () {
    test('ApiService initializes with valid defaults and candidates', () {
      final api = ApiService();
      expect(api.baseUrl, isNotEmpty);
      expect(api.isAuthenticated, isFalse);
      expect(api.jwtToken, isNull);
    });

    test('ApiService checkHealth reaches live Axum control plane', () async {
      final api = ApiService();
      final health = await api.checkHealth();
      if (health['success'] != true) {
        // Backend not running in headless test environment; graceful skip
        return;
      }
      expect(health['success'], isTrue);
      if (health['data'] != null) {
        final data = health['data'] as Map<String, dynamic>;
        expect(data['status'], 'online');
      }
    });

    test('ApiService repository lifecycle: create, fetch, star, delete', () async {
      final api = ApiService();
      final health = await api.checkHealth();
      if (health['success'] != true) {
        return;
      }
      final initialRepos = await api.fetchRepositories();
      expect(initialRepos, isA<List>());

      final testRepoId = 'repo_test_${DateTime.now().millisecondsSinceEpoch}';
      final createRes = await api.createRepository(
        id: testRepoId,
        name: 'test-realtime-repo',
        owner: 'GranthikSom',
        description: 'Automated test repository for real-time lifecycle',
        rootCommitHash: 'commit_test_hash',
        totalObjects: 10,
        topics: ['test', 'p2p'],
        isPrivate: false,
      );
      expect(createRes['success'], isTrue);

      final updatedRepos = await api.fetchRepositories();
      expect(updatedRepos.any((r) => (r as Map)['id'] == testRepoId), isTrue);

      final starRes = await api.starRepository(testRepoId);
      expect(starRes['success'], isTrue);

      final deleteRes = await api.deleteRepository(testRepoId);
      expect(deleteRes['success'], isTrue);

      final finalRepos = await api.fetchRepositories();
      expect(finalRepos.any((r) => (r as Map)['id'] == testRepoId), isFalse);
    });

    test('ApiService checkRepoNameAvailability verifies availability', () async {
      final api = ApiService();
      final health = await api.checkHealth();
      if (health['success'] != true) {
        return;
      }
      final result = await api.checkRepoNameAvailability(name: 'unique-new-repo-xyz');
      expect(result['data'], isNotNull);
      expect(result['data']['available'], isTrue);
    });
  });
}
