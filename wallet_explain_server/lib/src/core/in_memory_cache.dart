class InMemoryCache<T> {
  InMemoryCache({required this.ttl});

  final Duration ttl;
  final Map<String, _CacheEntry<T>> _store = {};

  T? get(String key) {
    final entry = _store[key];
    if (entry == null) return null;
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _store.remove(key);
      return null;
    }
    return entry.value;
  }

  void put(String key, T value) {
    _store[key] = _CacheEntry(value: value, expiresAt: DateTime.now().add(ttl));
  }
}

class _CacheEntry<T> {
  _CacheEntry({required this.value, required this.expiresAt});

  final T value;
  final DateTime expiresAt;
}
