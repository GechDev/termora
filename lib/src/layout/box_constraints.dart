import 'dart:math' as math;

import 'geometry.dart';

/// Immutable box constraints for sizing widgets in terminal cells.
class BoxConstraints {
  final int minWidth;
  final int maxWidth;
  final int minHeight;
  final int maxHeight;

  /// Sentinel constant representing unbound dimensions.
  static const int unbounded = 999999;

  const BoxConstraints({
    this.minWidth = 0,
    this.maxWidth = unbounded,
    this.minHeight = 0,
    this.maxHeight = unbounded,
  })  : assert(minWidth >= 0, 'minWidth must be >= 0'),
        assert(minHeight >= 0, 'minHeight must be >= 0'),
        assert(maxWidth >= minWidth, 'maxWidth must be >= minWidth'),
        assert(maxHeight >= minHeight, 'maxHeight must be >= minHeight');

  /// Creates box constraints that require the given width and height.
  BoxConstraints.tight(Size size)
      : minWidth = size.width,
        maxWidth = size.width,
        minHeight = size.height,
        maxHeight = size.height;

  /// Creates box constraints with tight bounds if specified.
  const BoxConstraints.tightFor({int? width, int? height})
      : minWidth = width ?? 0,
        maxWidth = width ?? unbounded,
        minHeight = height ?? 0,
        maxHeight = height ?? unbounded;

  /// Creates box constraints that forbid sizes larger than the given size.
  BoxConstraints.loose(Size size)
      : minWidth = 0,
        maxWidth = size.width,
        minHeight = 0,
        maxHeight = size.height;

  /// Creates box constraints that expand to fill the available space.
  const BoxConstraints.expand({int? width, int? height})
      : minWidth = width ?? unbounded,
        maxWidth = width ?? unbounded,
        minHeight = height ?? unbounded,
        maxHeight = height ?? unbounded;

  bool get hasBoundedWidth => maxWidth < unbounded;
  bool get hasBoundedHeight => maxHeight < unbounded;
  bool get hasTightWidth => minWidth >= maxWidth;
  bool get hasTightHeight => minHeight >= maxHeight;
  bool get isTight => hasTightWidth && hasTightHeight;

  /// The smallest size that satisfies these constraints.
  Size get smallest => Size(minWidth, minHeight);

  /// The biggest size that satisfies these constraints.
  Size get biggest => Size(maxWidth, maxHeight);

  /// Returns new constraints with minWidth and minHeight set to 0.
  BoxConstraints loosen() => BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight);

  /// Returns the closest size within these constraints.
  Size constrain(Size size) {
    return Size(
      constrainWidth(size.width),
      constrainHeight(size.height),
    );
  }

  /// Clamps [width] to satisfy [minWidth] and [maxWidth].
  int constrainWidth(int width) {
    return math.max(minWidth, math.min(width, maxWidth));
  }

  /// Clamps [height] to satisfy [minHeight] and [maxHeight].
  int constrainHeight(int height) {
    return math.max(minHeight, math.min(height, maxHeight));
  }

  /// Deflates constraints by the given amounts.
  BoxConstraints deflate({int horizontal = 0, int vertical = 0}) {
    return BoxConstraints(
      minWidth: math.max(0, minWidth - horizontal),
      maxWidth: math.max(0, maxWidth - horizontal),
      minHeight: math.max(0, minHeight - vertical),
      maxHeight: math.max(0, maxHeight - vertical),
    );
  }

  /// Returns new box constraints that respect both these constraints and the [other] constraints.
  BoxConstraints enforce(BoxConstraints other) {
    final newMinW = math.max(minWidth, other.minWidth);
    final newMaxW = math.max(newMinW, math.min(maxWidth, other.maxWidth));
    final newMinH = math.max(minHeight, other.minHeight);
    final newMaxH = math.max(newMinH, math.min(maxHeight, other.maxHeight));

    return BoxConstraints(
      minWidth: newMinW,
      maxWidth: newMaxW,
      minHeight: newMinH,
      maxHeight: newMaxH,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BoxConstraints &&
          other.minWidth == minWidth &&
          other.maxWidth == maxWidth &&
          other.minHeight == minHeight &&
          other.maxHeight == maxHeight);

  @override
  int get hashCode => Object.hash(minWidth, maxWidth, minHeight, maxHeight);

  @override
  String toString() =>
      'BoxConstraints($minWidth<=w<=$maxWidth, $minHeight<=h<=$maxHeight)';
}
