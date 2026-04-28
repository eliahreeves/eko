class PoolService<T, K> {
  final Map<K, _CacheEntry<T>> _map = {};
  final K Function(T) keySelector;
  final void Function(K) onInsert;
  final Duration? validTime;
  PoolService({
    required this.keySelector,
    required this.onInsert,
    this.validTime,
  });

  void put(T item, {DateTime? time}) {
    final now = time ?? DateTime.now();
    final key = keySelector(item);
    _map[key] = _CacheEntry(value: item, insertedAt: now);
    onInsert(key);
  }

  void putAll(Iterable<T> items) {
    final now = DateTime.now();
    for (final item in items) {
      put(item, time: now);
    }
  }

  T? getItem(K key) {
    final item = _map[key];
    // return null if the requested item is not present if it isn't null remove it from the map
    if (item == null) {
      return null;
    } else {
      _map.remove(key);
    }
    // if there is no duration we don't need to check if the data is fresh
    if (validTime == null) {
      return item.value;
    }
    // make sure data is fresh
    if (DateTime.now().difference(item.insertedAt) > validTime!) {
      return null;
    }
    return item.value;
  }
}

class _CacheEntry<T> {
  final T value;
  final DateTime insertedAt;
  const _CacheEntry({required this.value, required this.insertedAt});
}
