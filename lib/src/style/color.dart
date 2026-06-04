import '../rendering/ansi.dart';

/// Represents a color usable in terminal rendering.
sealed class Color {
  const Color();

  /// Generates the ANSI escape sequence for this color as foreground.
  String toForegroundAnsi();

  /// Generates the ANSI escape sequence for this color as background.
  String toBackgroundAnsi();

  // Named standard 16 colors
  static const Color black =
      NamedColor._(0, 'black', Ansi.fgBlack, Ansi.bgBlack);
  static const Color red = NamedColor._(1, 'red', Ansi.fgRed, Ansi.bgRed);
  static const Color green =
      NamedColor._(2, 'green', Ansi.fgGreen, Ansi.bgGreen);
  static const Color yellow =
      NamedColor._(3, 'yellow', Ansi.fgYellow, Ansi.bgYellow);
  static const Color blue = NamedColor._(4, 'blue', Ansi.fgBlue, Ansi.bgBlue);
  static const Color magenta =
      NamedColor._(5, 'magenta', Ansi.fgMagenta, Ansi.bgMagenta);
  static const Color cyan = NamedColor._(6, 'cyan', Ansi.fgCyan, Ansi.bgCyan);
  static const Color white =
      NamedColor._(7, 'white', Ansi.fgWhite, Ansi.bgWhite);

  static const Color brightBlack =
      NamedColor._(8, 'brightBlack', Ansi.fgBrightBlack, Ansi.bgBrightBlack);
  static const Color brightRed =
      NamedColor._(9, 'brightRed', Ansi.fgBrightRed, Ansi.bgBrightRed);
  static const Color brightGreen =
      NamedColor._(10, 'brightGreen', Ansi.fgBrightGreen, Ansi.bgBrightGreen);
  static const Color brightYellow = NamedColor._(
      11, 'brightYellow', Ansi.fgBrightYellow, Ansi.bgBrightYellow);
  static const Color brightBlue =
      NamedColor._(12, 'brightBlue', Ansi.fgBrightBlue, Ansi.bgBrightBlue);
  static const Color brightMagenta = NamedColor._(
      13, 'brightMagenta', Ansi.fgBrightMagenta, Ansi.bgBrightMagenta);
  static const Color brightCyan =
      NamedColor._(14, 'brightCyan', Ansi.fgBrightCyan, Ansi.bgBrightCyan);
  static const Color brightWhite =
      NamedColor._(15, 'brightWhite', Ansi.fgBrightWhite, Ansi.bgBrightWhite);

  /// Creates a color from the 256-color palette (0–255).
  const factory Color.ansi256(int code) = Ansi256Color;

  /// Creates a 24-bit TrueColor RGB color.
  const factory Color.rgb(int r, int g, int b) = RgbColor;
}

/// One of the standard 16 ANSI colors.
final class NamedColor extends Color {
  final int index;
  final String name;
  final String _fgAnsi;
  final String _bgAnsi;

  const NamedColor._(this.index, this.name, this._fgAnsi, this._bgAnsi);

  @override
  String toForegroundAnsi() => _fgAnsi;

  @override
  String toBackgroundAnsi() => _bgAnsi;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is NamedColor && other.index == index);

  @override
  int get hashCode => index.hashCode;

  @override
  String toString() => 'Color.$name';
}

/// A color from the 256-color extended ANSI palette.
final class Ansi256Color extends Color {
  final int code;

  const Ansi256Color(int code)
      : code = code < 0 ? 0 : (code > 255 ? 255 : code);

  @override
  String toForegroundAnsi() => Ansi.fg256(code);

  @override
  String toBackgroundAnsi() => Ansi.bg256(code);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Ansi256Color && other.code == code);

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'Color.ansi256($code)';
}

/// A 24-bit TrueColor RGB color.
final class RgbColor extends Color {
  final int r;
  final int g;
  final int b;

  const RgbColor(int r, int g, int b)
      : r = r < 0 ? 0 : (r > 255 ? 255 : r),
        g = g < 0 ? 0 : (g > 255 ? 255 : g),
        b = b < 0 ? 0 : (b > 255 ? 255 : b);

  @override
  String toForegroundAnsi() => Ansi.fgRgb(r, g, b);

  @override
  String toBackgroundAnsi() => Ansi.bgRgb(r, g, b);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RgbColor && other.r == r && other.g == g && other.b == b);

  @override
  int get hashCode => Object.hash(r, g, b);

  @override
  String toString() => 'Color.rgb($r, $g, $b)';
}
