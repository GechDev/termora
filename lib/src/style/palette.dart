import 'color.dart';

/// Curated color palettes inspired by iconic terminal themes.
class ColorPalette {
  final String name;
  final Color primary;
  final Color secondary;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  final Color surface;
  final Color background;
  final Color text;
  final Color muted;

  const ColorPalette({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.surface,
    required this.background,
    required this.text,
    required this.muted,
  });

  /// Nord color palette (arctic, north-bluish clean theme).
  static const ColorPalette nord = ColorPalette(
    name: 'Nord',
    primary: Color.rgb(136, 192, 208), // Frost ice cyan
    secondary: Color.rgb(129, 161, 193), // Frost blue
    success: Color.rgb(163, 190, 140), // Aurora green
    warning: Color.rgb(235, 203, 139), // Aurora yellow
    danger: Color.rgb(191, 97, 106), // Aurora red
    info: Color.rgb(94, 129, 172), // Frost deep blue
    surface: Color.rgb(59, 66, 82), // Polar Night light
    background: Color.rgb(46, 52, 64), // Polar Night dark
    text: Color.rgb(236, 239, 244), // Snow Storm bright
    muted: Color.rgb(76, 86, 106), // Polar Night medium
  );

  /// Dracula color palette (vibrant dark gothic theme).
  static const ColorPalette dracula = ColorPalette(
    name: 'Dracula',
    primary: Color.rgb(189, 147, 249), // Purple
    secondary: Color.rgb(255, 121, 198), // Pink
    success: Color.rgb(80, 250, 123), // Green
    warning: Color.rgb(241, 250, 140), // Yellow
    danger: Color.rgb(255, 85, 85), // Red
    info: Color.rgb(139, 233, 253), // Cyan
    surface: Color.rgb(68, 71, 90), // Current line
    background: Color.rgb(40, 42, 54), // Background
    text: Color.rgb(248, 248, 242), // Foreground
    muted: Color.rgb(98, 114, 164), // Comment
  );

  /// Catppuccin Mocha color palette (warm soothing pastel dark).
  static const ColorPalette catppuccinMocha = ColorPalette(
    name: 'Catppuccin Mocha',
    primary: Color.rgb(137, 180, 250), // Blue
    secondary: Color.rgb(203, 166, 247), // Mauve
    success: Color.rgb(166, 227, 161), // Green
    warning: Color.rgb(249, 226, 175), // Yellow
    danger: Color.rgb(243, 139, 168), // Red
    info: Color.rgb(148, 226, 213), // Teal
    surface: Color.rgb(49, 50, 68), // Surface0
    background: Color.rgb(30, 30, 46), // Base
    text: Color.rgb(205, 214, 244), // Text
    muted: Color.rgb(108, 112, 134), // Overlay0
  );
}
