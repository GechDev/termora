/// Constants and helpers for generating ANSI escape sequences.
class Ansi {
  Ansi._();

  /// Escape control character.
  static const String esc = '\x1B';

  /// Control Sequence Introducer.
  static const String csi = '$esc[';

  // Screen control
  /// Switches to alternate screen buffer.
  static const String enterAlternateScreen = '$csi?1049h';

  /// Returns to primary screen buffer.
  static const String exitAlternateScreen = '$csi?1049l';

  /// Clears the entire visible screen.
  static const String clearScreen = '${csi}2J';

  /// Clears the entire current line.
  static const String clearLine = '${csi}2K';

  /// Clears from cursor to the end of the line.
  static const String clearToEndOfLine = '${csi}0K';

  // Cursor control
  /// Hides the terminal cursor.
  static const String hideCursor = '$csi?25l';

  /// Shows the terminal cursor.
  static const String showCursor = '$csi?25h';

  /// Moves cursor to 1-based coordinate (row, col) = (y + 1, x + 1).
  static String moveTo(int x, int y) => '$csi${y + 1};${x + 1}H';

  /// Moves cursor to home position (1, 1).
  static const String cursorHome = '${csi}H';

  /// Moves cursor up [n] rows.
  static String cursorUp([int n = 1]) => '$csi${n}A';

  /// Moves cursor down [n] rows.
  static String cursorDown([int n = 1]) => '$csi${n}B';

  /// Moves cursor forward [n] columns.
  static String cursorForward([int n = 1]) => '$csi${n}C';

  /// Moves cursor back [n] columns.
  static String cursorBack([int n = 1]) => '$csi${n}D';

  // Text attributes (SGR)
  /// Resets all styling and colors.
  static const String reset = '${csi}0m';

  /// Bold or increased intensity.
  static const String bold = '${csi}1m';

  /// Faint or decreased intensity.
  static const String dim = '${csi}2m';

  /// Italic text.
  static const String italic = '${csi}3m';

  /// Underlined text.
  static const String underline = '${csi}4m';

  /// Inverted / reverse video (swaps fg and bg).
  static const String invert = '${csi}7m';

  /// Crossed-out / strikethrough text.
  static const String strikethrough = '${csi}9m';

  // Standard 16 Foreground Colors
  static const String fgBlack = '${csi}30m';
  static const String fgRed = '${csi}31m';
  static const String fgGreen = '${csi}32m';
  static const String fgYellow = '${csi}33m';
  static const String fgBlue = '${csi}34m';
  static const String fgMagenta = '${csi}35m';
  static const String fgCyan = '${csi}36m';
  static const String fgWhite = '${csi}37m';
  static const String fgDefault = '${csi}39m';

  static const String fgBrightBlack = '${csi}90m';
  static const String fgBrightRed = '${csi}91m';
  static const String fgBrightGreen = '${csi}92m';
  static const String fgBrightYellow = '${csi}93m';
  static const String fgBrightBlue = '${csi}94m';
  static const String fgBrightMagenta = '${csi}95m';
  static const String fgBrightCyan = '${csi}96m';
  static const String fgBrightWhite = '${csi}97m';

  // Standard 16 Background Colors
  static const String bgBlack = '${csi}40m';
  static const String bgRed = '${csi}41m';
  static const String bgGreen = '${csi}42m';
  static const String bgYellow = '${csi}43m';
  static const String bgBlue = '${csi}44m';
  static const String bgMagenta = '${csi}45m';
  static const String bgCyan = '${csi}46m';
  static const String bgWhite = '${csi}47m';
  static const String bgDefault = '${csi}49m';

  static const String bgBrightBlack = '${csi}100m';
  static const String bgBrightRed = '${csi}101m';
  static const String bgBrightGreen = '${csi}102m';
  static const String bgBrightYellow = '${csi}103m';
  static const String bgBrightBlue = '${csi}104m';
  static const String bgBrightMagenta = '${csi}105m';
  static const String bgBrightCyan = '${csi}106m';
  static const String bgBrightWhite = '${csi}107m';

  // 256 Colors
  /// 256-color foreground ANSI code.
  static String fg256(int code) => '${csi}38;5;${code.clamp(0, 255)}m';

  /// 256-color background ANSI code.
  static String bg256(int code) => '${csi}48;5;${code.clamp(0, 255)}m';

  // 24-bit TrueColor
  /// 24-bit RGB foreground ANSI code.
  static String fgRgb(int r, int g, int b) =>
      '${csi}38;2;${r.clamp(0, 255)};${g.clamp(0, 255)};${b.clamp(0, 255)}m';

  /// 24-bit RGB background ANSI code.
  static String bgRgb(int r, int g, int b) =>
      '${csi}48;2;${r.clamp(0, 255)};${g.clamp(0, 255)};${b.clamp(0, 255)}m';
}
