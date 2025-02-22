extension InterableExt<T> on Iterable<T> {
  /// Returns a Map containing the elements from the given Iterable
  /// indexed by the key returned from [keySelector] function applied to each element. (from Kotlin)
  Map<K, T> associateBy<K>({required K Function(T element) keySelector}) {
    return {for (final s in this) keySelector(s): s};
  }
}
