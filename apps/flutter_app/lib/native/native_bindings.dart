import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// FFI function type signatures
typedef NativeInitNode = Int32 Function(Pointer<Utf8> storagePath);
typedef DartInitNode = int Function(Pointer<Utf8> storagePath);

typedef NativeStoreBlob = Pointer<Utf8> Function(Pointer<Utf8> payload);
typedef DartStoreBlob = Pointer<Utf8> Function(Pointer<Utf8> payload);

typedef NativeGetTelemetry = Pointer<Utf8> Function();
typedef DartGetTelemetry = Pointer<Utf8> Function();

typedef NativeFreeString = Void Function(Pointer<Utf8> ptr);
typedef DartFreeString = void Function(Pointer<Utf8> ptr);

typedef NativeInitLocalStorage = Int32 Function();
typedef DartInitLocalStorage = int Function();

typedef NativeCreateRepo = Int32 Function(Pointer<Utf8> repoName);
typedef DartCreateRepo = int Function(Pointer<Utf8> repoName);

typedef NativeGetStorageStats = Pointer<Utf8> Function();
typedef DartGetStorageStats = Pointer<Utf8> Function();

typedef NativeContentPut = Pointer<Utf8> Function(Pointer<Utf8> payload);
typedef DartContentPut = Pointer<Utf8> Function(Pointer<Utf8> payload);

typedef NativeHasObject = Int32 Function(Pointer<Utf8> hash);
typedef DartHasObject = int Function(Pointer<Utf8> hash);

typedef NativeChunkRepo = Pointer<Utf8> Function(Pointer<Utf8> repoId, Pointer<Utf8> payload);
typedef DartChunkRepo = Pointer<Utf8> Function(Pointer<Utf8> repoId, Pointer<Utf8> payload);

typedef NativeScheduleDownload = Pointer<Utf8> Function(Size totalChunks);
typedef DartScheduleDownload = Pointer<Utf8> Function(int totalChunks);

/// Native Rust P2P Engine Dart FFI Interface
class NativeP2PEngine {
  static DynamicLibrary? _lib;
  static bool _isLoaded = false;

  static DartInitNode? _initNode;
  static DartStoreBlob? _storeBlob;
  static DartGetTelemetry? _getTelemetry;
  static DartFreeString? _freeString;
  static DartInitLocalStorage? _initLocalStorage;
  static DartCreateRepo? _createRepo;
  static DartGetStorageStats? _getStorageStats;
  static DartContentPut? _contentPut;
  static DartHasObject? _hasObject;
  static DartChunkRepo? _chunkRepo;
  static DartScheduleDownload? _scheduleDownload;

  static bool get isNativeLoaded => _isLoaded;

  /// Attempts to load the native p2p_engine shared library
  static void initialize() {
    if (_isLoaded) return;

    try {
      if (Platform.isLinux) {
        try {
          _lib = DynamicLibrary.open('libp2p_engine.so');
        } catch (_) {
          _lib = DynamicLibrary.open('libcodehub_core.so');
        }
      } else if (Platform.isMacOS) {
        try {
          _lib = DynamicLibrary.open('libp2p_engine.dylib');
        } catch (_) {
          _lib = DynamicLibrary.open('libcodehub_core.dylib');
        }
      } else if (Platform.isWindows) {
        try {
          _lib = DynamicLibrary.open('p2p_engine.dll');
        } catch (_) {
          _lib = DynamicLibrary.open('codehub_core.dll');
        }
      }

      if (_lib != null) {
        _initNode = _lib!.lookupFunction<NativeInitNode, DartInitNode>('codehub_init_node');
        _storeBlob = _lib!.lookupFunction<NativeStoreBlob, DartStoreBlob>('codehub_store_git_blob');
        _getTelemetry = _lib!.lookupFunction<NativeGetTelemetry, DartGetTelemetry>('codehub_get_telemetry_json');
        _freeString = _lib!.lookupFunction<NativeFreeString, DartFreeString>('codehub_free_string');
        _initLocalStorage = _lib!.lookupFunction<NativeInitLocalStorage, DartInitLocalStorage>('codehub_init_local_storage_engine');
        _createRepo = _lib!.lookupFunction<NativeCreateRepo, DartCreateRepo>('codehub_create_repository');
        _getStorageStats = _lib!.lookupFunction<NativeGetStorageStats, DartGetStorageStats>('codehub_get_storage_stats_json');
        _contentPut = _lib!.lookupFunction<NativeContentPut, DartContentPut>('codehub_content_put');
        _hasObject = _lib!.lookupFunction<NativeHasObject, DartHasObject>('codehub_has_object');
        _chunkRepo = _lib!.lookupFunction<NativeChunkRepo, DartChunkRepo>('codehub_chunk_repository_payload');
        _scheduleDownload = _lib!.lookupFunction<NativeScheduleDownload, DartScheduleDownload>('codehub_schedule_parallel_swarm_download');

        _isLoaded = true;
      }
    } catch (_) {
      // Dynamic library not present in debug path; fallback mode active
      _isLoaded = false;
    }
  }

  /// Initializes native node blockstore
  static int initNode(String storagePath) {
    if (!_isLoaded || _initNode == null) return -1;
    final pathPtr = storagePath.toNativeUtf8();
    try {
      return _initNode!(pathPtr);
    } finally {
      calloc.free(pathPtr);
    }
  }

  /// Initializes ~/.codehub/ local repository storage engine
  static int initLocalStorageEngine() {
    if (!_isLoaded || _initLocalStorage == null) return -1;
    return _initLocalStorage!();
  }

  /// Creates a managed local repository in ~/.codehub/repositories/repo_name/
  static int createRepository(String repoName) {
    if (!_isLoaded || _createRepo == null) return -1;
    final repoPtr = repoName.toNativeUtf8();
    try {
      return _createRepo!(repoPtr);
    } finally {
      calloc.free(repoPtr);
    }
  }

  /// Returns storage diagnostic JSON metrics for ~/.codehub/
  static String? getStorageStatsJson() {
    if (!_isLoaded || _getStorageStats == null || _freeString == null) return null;
    final resPtr = _getStorageStats!();
    if (resPtr == nullptr) return null;
    try {
      return resPtr.toDartString();
    } finally {
      _freeString!(resPtr);
    }
  }

  /// Stores a Git object blob payload in native blockstore
  static String? storeGitBlob(String payload) {
    if (!_isLoaded || _storeBlob == null || _freeString == null) return null;
    final payloadPtr = payload.toNativeUtf8();
    try {
      final resPtr = _storeBlob!(payloadPtr);
      if (resPtr == nullptr) return null;
      final resultStr = resPtr.toDartString();
      _freeString!(resPtr);
      return resultStr;
    } finally {
      calloc.free(payloadPtr);
    }
  }

  /// Retrieves live JSON telemetry from native Rust libp2p swarm
  static String? getTelemetryJson() {
    if (!_isLoaded || _getTelemetry == null || _freeString == null) return null;
    final resPtr = _getTelemetry!();
    if (resPtr == nullptr) return null;
    try {
      return resPtr.toDartString();
    } finally {
      _freeString!(resPtr);
    }
  }

  /// Stores object using SHA-256 content addressing and automatic deduplication
  static String? putContentAddressedObject(String payload) {
    if (!_isLoaded || _contentPut == null || _freeString == null) return null;
    final payloadPtr = payload.toNativeUtf8();
    try {
      final resPtr = _contentPut!(payloadPtr);
      if (resPtr == nullptr) return null;
      final resultStr = resPtr.toDartString();
      _freeString!(resPtr);
      return resultStr;
    } finally {
      calloc.free(payloadPtr);
    }
  }

  /// Checks if object hash exists in content-addressed blockstore
  static bool hasContentAddressedObject(String hash) {
    if (!_isLoaded || _hasObject == null) return false;
    final hashPtr = hash.toNativeUtf8();
    try {
      return _hasObject!(hashPtr) == 1;
    } finally {
      calloc.free(hashPtr);
    }
  }

  /// Splits repository payload into 1 MB BitTorrent-style chunks
  static String? chunkRepositoryPayload(String repoId, String payload) {
    if (!_isLoaded || _chunkRepo == null || _freeString == null) return null;
    final repoPtr = repoId.toNativeUtf8();
    final payloadPtr = payload.toNativeUtf8();
    try {
      final resPtr = _chunkRepo!(repoPtr, payloadPtr);
      if (resPtr == nullptr) return null;
      final resultStr = resPtr.toDartString();
      _freeString!(resPtr);
      return resultStr;
    } finally {
      calloc.free(repoPtr);
      calloc.free(payloadPtr);
    }
  }

  /// Schedules non-overlapping parallel stream chunk downloads across active swarm peers
  static String? scheduleParallelSwarmDownload(int totalChunks) {
    if (!_isLoaded || _scheduleDownload == null || _freeString == null) return null;
    final resPtr = _scheduleDownload!(totalChunks);
    if (resPtr == nullptr) return null;
    try {
      final resultStr = resPtr.toDartString();
      _freeString!(resPtr);
      return resultStr;
    } catch (_) {
      return null;
    }
  }
}
