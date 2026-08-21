class LocalStorageService {
  static final Map<String, dynamic> _memoryCache = {};

  static void saveString(String key, String value) {
    _memoryCache[key] = value;
  }

  static String? getString(String key) {
    return _memoryCache[key] as String?;
  }

  static void clear() {
    _memoryCache.clear();
  }
}
