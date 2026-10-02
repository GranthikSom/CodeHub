/// Web Fallback Implementation for CodeHub Native Engine
/// Active when running in Web browsers where dart:ffi is unavailable.
library;

class NativeP2PEngine {
  static const bool isNativeLoaded = false;

  static void initialize() {
    // In Web browser mode, native FFI is disabled; web client uses REST / WebSocket protocol.
  }

  static int initNode(String storagePath) => -1;

  static int initLocalStorageEngine() => -1;

  static int createRepository(String repoName) => -1;

  static String? getStorageStatsJson() => null;

  static String? storeGitBlob(String payload) => null;

  static String? getTelemetryJson() => null;

  static String? putContentAddressedObject(String payload) => null;

  static bool hasContentAddressedObject(String hash) => false;

  static String? chunkRepositoryPayload(String repoId, String payload) => null;

  static String? scheduleParallelSwarmDownload(int totalChunks) => null;

  static String? getOrCreatePeerIdentity() => null;

  static String? getConnectedPeers() => null;

  static String? confirmPushReplication(String repoId) => null;

  static String? verifySyncChunk(String repoId, String chunkHash, String payload) => null;

  static Map<String, dynamic> createRepositoryEngine(String repoName) {
    return {
      'success': true,
      'repo': repoName,
      'path': 'web://repositories/$repoName',
      'message': 'Web virtual repository layout initialized.',
    };
  }

  static Map<String, dynamic> openRepositoryEngine(String repoName) {
    return {
      'success': true,
      'repo': repoName,
      'path': 'web://repositories/$repoName',
      'status': 'opened',
    };
  }

  static Map<String, dynamic> readFileEngine(String repoName, String relativePath) {
    return {
      'success': true,
      'repo': repoName,
      'path': relativePath,
      'content': '// CodeHub Web Repository: $relativePath',
    };
  }

  static Map<String, dynamic> writeFileEngine(String repoName, String relativePath, String content) {
    return {
      'success': true,
      'repo': repoName,
      'path': relativePath,
      'size_bytes': content.length,
    };
  }

  static Map<String, dynamic> hashObjectEngine(String payload) {
    return {
      'hash': 'web_virtual_hash_${payload.hashCode}',
      'size_bytes': payload.length,
    };
  }

  static Map<String, dynamic> storeObjectEngine(String payload) {
    return {
      'success': true,
      'hash': 'web_stored_hash_${payload.hashCode}',
      'is_newly_written': true,
    };
  }

  static Map<String, dynamic> retrieveObjectEngine(String hash) {
    return {
      'success': true,
      'hash': hash,
      'payload': 'commit web\n\nWeb fallback content',
    };
  }
}
