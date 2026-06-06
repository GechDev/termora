/// An identifier for [Widget]s and [Element]s.
abstract class Key {
  const Key();

  /// Creates a [ValueKey] with [value].
  const factory Key.value(dynamic value) = ValueKey<dynamic>;
}

/// A key that uses a value of type [T] to identify itself.
class ValueKey<T> extends Key {
  final T value;

  const ValueKey(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ValueKey<T> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ValueKey($value)';
}

/// A key that is unique to this instance.
class UniqueKey extends Key {
  UniqueKey();

  @override
  String toString() => 'UniqueKey(#${shortHash(this)})';

  static String shortHash(Object object) {
    return object.hashCode.toRadixString(16).padLeft(5, '0');
  }
}
