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

/// Native Rust P2P Engine Dart FFI Interface
class NativeP2PEngine {
  static DynamicLibrary? _lib;
  static bool _isLoaded = false;

  static DartInitNode? _initNode;
  static DartStoreBlob? _storeBlob;
  static DartGetTelemetry? _getTelemetry;
  static DartFreeString? _freeString;

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
}
