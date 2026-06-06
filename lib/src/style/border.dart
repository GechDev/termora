import 'style.dart';

/// Defines characters used to draw a box border.
class BorderChars {
  final String topLeft;
  final String topRight;
  final String bottomLeft;
  final String bottomRight;
  final String horizontal;
  final String vertical;

  const BorderChars({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
    required this.horizontal,
    required this.vertical,
  });

  /// Standard ASCII border (`+`, `-`, `|`).
  static const BorderChars ascii = BorderChars(
    topLeft: '+',
    topRight: '+',
    bottomLeft: '+',
    bottomRight: '+',
    horizontal: '-',
    vertical: '|',
  );

  /// Single Unicode box drawing border (`┌`, `┐`, `└`, `┘`, `─`, `│`).
  static const BorderChars single = BorderChars(
    topLeft: '┌',
    topRight: '┐',
    bottomLeft: '└',
    bottomRight: '┘',
    horizontal: '─',
    vertical: '│',
  );

  /// Rounded Unicode box drawing border (`╭`, `╮`, `╰`, `╯`, `─`, `│`).
  static const BorderChars rounded = BorderChars(
    topLeft: '╭',
    topRight: '╮',
    bottomLeft: '╰',
    bottomRight: '╯',
    horizontal: '─',
    vertical: '│',
  );

  /// Double Unicode box drawing border (`╔`, `╗`, `╚`, `╝`, `═`, `║`).
  static const BorderChars double = BorderChars(
    topLeft: '╔',
    topRight: '╗',
    bottomLeft: '╚',
    bottomRight: '╝',
    horizontal: '═',
    vertical: '║',
  );
}

/// Represents the visual border surrounding a container.
class Border {
  final BorderChars chars;
  final Style style;

  const Border({
    this.chars = BorderChars.single,
    this.style = Style.none,
  });

  /// Standard ASCII border.
  const Border.ascii([Style style = Style.none])
      : this(chars: BorderChars.ascii, style: style);

  /// Single-line Unicode box border.
  const Border.single([Style style = Style.none])
      : this(chars: BorderChars.single, style: style);

  /// Rounded-corner Unicode box border.
  const Border.rounded([Style style = Style.none])
      : this(chars: BorderChars.rounded, style: style);

  /// Double-line Unicode box border.
  const Border.double([Style style = Style.none])
      : this(chars: BorderChars.double, style: style);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Border && other.chars == chars && other.style == style);

  @override
  int get hashCode => Object.hash(chars, style);
}
