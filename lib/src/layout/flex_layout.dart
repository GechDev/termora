/// The direction in which a flex container places its children.
enum Axis {
  horizontal,
  vertical,
}

/// How children are aligned along the flex container's main axis.
enum MainAxisAlignment {
  /// Place children as close to the start of the main axis as possible.
  start,

  /// Place children as close to the end of the main axis as possible.
  end,

  /// Place children as close to the middle of the main axis as possible.
  center,

  /// Place free space evenly between the children.
  spaceBetween,

  /// Place free space evenly between children, with half space before the first and after the last child.
  spaceAround,

  /// Place free space evenly between and around all children.
  spaceEvenly,
}

/// How children are aligned along the flex container's cross axis.
enum CrossAxisAlignment {
  /// Align children to the start of the cross axis.
  start,

  /// Align children to the end of the cross axis.
  end,

  /// Center children along the cross axis.
  center,

  /// Require children to stretch to fill the cross axis.
  stretch,
}

/// How much space should be occupied by the flex container in the main direction.
enum MainAxisSize {
  /// Minimize the amount of free space along the main axis.
  min,

  /// Maximize the amount of free space along the main axis.
  max,
}

/// How a flexible widget shares space with other flex children.
enum FlexFit {
  /// Force the child to expand to fill all allocated space.
  tight,

  /// Let the child take up to the allocated space, but shrink if desired.
  loose,
}
