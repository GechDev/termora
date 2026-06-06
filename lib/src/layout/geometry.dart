/// A 2D integer offset in terminal column and row units.
class Offset {
  final int x;
  final int y;

  const Offset(this.x, this.y);

  static const Offset zero = Offset(0, 0);

  Offset operator +(Offset other) => Offset(x + other.x, y + other.y);
  Offset operator -(Offset other) => Offset(x - other.x, y - other.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Offset && other.x == x && other.y == y);

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Offset($x, $y)';
}

/// A 2D integer size in terminal column and row units.
class Size {
  final int width;
  final int height;

  const Size(this.width, this.height)
      : assert(width >= 0, 'Width must be non-negative'),
        assert(height >= 0, 'Height must be non-negative');

  static const Size zero = Size(0, 0);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Size && other.width == width && other.height == height);

  @override
  int get hashCode => Object.hash(width, height);

  @override
  String toString() => 'Size($width, $height)';
}

/// A 2D integer rectangle in terminal coordinate space.
class Rect {
  final int left;
  final int top;
  final int width;
  final int height;

  const Rect.fromLTWH(this.left, this.top, this.width, this.height);

  int get right => left + width;
  int get bottom => top + height;

  bool contains(Offset offset) {
    return offset.x >= left &&
        offset.x < right &&
        offset.y >= top &&
        offset.y < bottom;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Rect &&
          other.left == left &&
          other.top == top &&
          other.width == width &&
          other.height == height);

  @override
  int get hashCode => Object.hash(left, top, width, height);

  @override
  String toString() => 'Rect.fromLTWH($left, $top, $width, $height)';
}
