import '../style/style.dart';

/// Represents a single character position in a terminal screen buffer.
class Cell {
  /// The character displayed in this cell.
  final String character;

  /// The visual style (colors and modifiers) applied to this cell.
  final Style style;

  /// Visual column width of this cell in the terminal (0, 1, or 2).
  ///
  /// - 1: Standard character width (ASCII, Latin, etc.)
  /// - 2: Full-width / CJK character leading cell
  /// - 0: Continuation trailing cell of a preceding full-width character
  final int width;

  const Cell({
    this.character = ' ',
    this.style = Style.none,
    this.width = 1,
  });

  /// An empty blank cell with default style.
  static const Cell empty = Cell();

  /// A continuation cell representing the second column occupied by a wide character.
  static const Cell wideContinuation = Cell(character: '', width: 0);

  /// Convenient constructor for a single character with optional style and width.
  const Cell.char(this.character, [this.style = Style.none, this.width = 1]);

  /// Whether this cell represents a wide (2-column) character's leading cell.
  bool get isWideLeading => width == 2;

  /// Whether this cell represents the invisible continuation column of a wide character.
  bool get isWideTrailing => width == 0;

  /// Creates a copy of this cell with optional updated values.
  Cell copyWith({
    String? character,
    Style? style,
    int? width,
  }) {
    return Cell(
      character: character ?? this.character,
      style: style ?? this.style,
      width: width ?? this.width,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cell &&
          other.character == character &&
          other.style == style &&
          other.width == width);

  @override
  int get hashCode => Object.hash(character, style, width);

  @override
  String toString() => 'Cell("$character", style: $style, width: $width)';
}
