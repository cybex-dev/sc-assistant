extension IterableExt<E> on Iterable<E> {

  /// Reduces a collection to a single value by iteratively combining elements of the collection using the provided function.
  /// If the collection is empty, returns [orElse] if provided, otherwise throws a [StateError].
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4];
  /// final sum = numbers.reduceOrDefault((value, element) => value + element, () => 0);
  /// print(sum); // 10
  /// ```
  E reduceOrDefault(E Function(E, E) combine, [E Function()? orElse]) {
    if (isEmpty) {
      if (orElse != null) {
        return orElse();
      } else {
        throw StateError('No element');
      }
    }
    return reduce(combine);
  }
}