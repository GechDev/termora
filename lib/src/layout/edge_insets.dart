/// Immutable insets for padding and margins in terminal cells.
class EdgeInsets {
  final int left;
  final int top;
  final int right;
  final int bottom;

  const EdgeInsets.fromLTRB(this.left, this.top, this.right, this.bottom)
      : assert(left >= 0 && top >= 0 && right >= 0 && bottom >= 0);

  /// Zero insets.
  static const EdgeInsets zero = EdgeInsets.all(0);

  /// Creates insets with symmetrical horizontal and vertical values.
  const EdgeInsets.symmetric({int horizontal = 0, int vertical = 0})
      : left = horizontal,
        top = vertical,
        right = horizontal,
        bottom = vertical;

  /// Creates insets where all boundaries have the same value.
  const EdgeInsets.all(int value)
      : left = value,
        top = value,
        right = value,
        bottom = value;

  /// Creates insets with only the specified sides non-zero.
  const EdgeInsets.only({
    this.left = 0,
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
  });

  int get horizontal => left + right;
  int get vertical => top + bottom;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EdgeInsets &&
          other.left == left &&
          other.top == top &&
          other.right == right &&
          other.bottom == bottom);

  @override
  int get hashCode => Object.hash(left, top, right, bottom);

  @override
  String toString() => 'EdgeInsets($left, $top, $right, $bottom)';
}
