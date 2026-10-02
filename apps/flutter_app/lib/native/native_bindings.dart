/// Conditional export for CodeHub Native Engine bindings:
/// - Desktop (Linux/macOS/Windows) uses `native_bindings_ffi.dart` with direct C-ABI libp2p FFI.
/// - Web uses `native_bindings_web.dart` with safe fallback methods.
library;

export 'native_bindings_web.dart'
    if (dart.library.ffi) 'native_bindings_ffi.dart';
