import '../core/build_context.dart';
import '../core/inherited_widget.dart';
import '../core/widget.dart';
import 'border.dart';
import 'color.dart';

/// Holds color palette and styling configurations for the application.
class TermoraThemeData {
  final Color primaryColor;
  final Color secondaryColor;
  final Color successColor;
  final Color warningColor;
  final Color dangerColor;
  final Color? backgroundColor;
  final Color textColor;
  final Border defaultBorder;

  const TermoraThemeData({
    required this.primaryColor,
    required this.secondaryColor,
    required this.successColor,
    required this.warningColor,
    required this.dangerColor,
    this.backgroundColor,
    required this.textColor,
    this.defaultBorder = const Border.single(),
  });

  /// The standard modern dark theme (default).
  factory TermoraThemeData.dark() => const TermoraThemeData(
        primaryColor: Color.cyan,
        secondaryColor: Color.blue,
        successColor: Color.green,
        warningColor: Color.yellow,
        dangerColor: Color.red,
        textColor: Color.white,
        defaultBorder: Border.rounded(),
      );

  /// High-contrast theme.
  factory TermoraThemeData.highContrast() => const TermoraThemeData(
        primaryColor: Color.brightCyan,
        secondaryColor: Color.brightBlue,
        successColor: Color.brightGreen,
        warningColor: Color.brightYellow,
        dangerColor: Color.brightRed,
        textColor: Color.brightWhite,
        defaultBorder: Border.double(),
      );

  /// Matrix / retro green phosphor terminal theme.
  factory TermoraThemeData.matrix() => const TermoraThemeData(
        primaryColor: Color.brightGreen,
        secondaryColor: Color.green,
        successColor: Color.brightGreen,
        warningColor: Color.brightYellow,
        dangerColor: Color.brightRed,
        backgroundColor: Color.black,
        textColor: Color.green,
        defaultBorder: Border.single(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TermoraThemeData &&
          other.primaryColor == primaryColor &&
          other.secondaryColor == secondaryColor &&
          other.successColor == successColor &&
          other.warningColor == warningColor &&
          other.dangerColor == dangerColor &&
          other.backgroundColor == backgroundColor &&
          other.textColor == textColor &&
          other.defaultBorder == defaultBorder);

  @override
  int get hashCode => Object.hash(
        primaryColor,
        secondaryColor,
        successColor,
        warningColor,
        dangerColor,
        backgroundColor,
        textColor,
        defaultBorder,
      );
}

/// An [InheritedWidget] that provides [TermoraThemeData] to its subtree.
class Theme extends InheritedWidget {
  final TermoraThemeData data;

  const Theme({
    super.key,
    required this.data,
    required super.child,
  });

  /// Retrieves the nearest [TermoraThemeData] from the widget tree, defaulting to dark theme.
  static TermoraThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<Theme>();
    return theme?.data ?? TermoraThemeData.dark();
  }

  @override
  bool updateShouldNotify(covariant Theme oldWidget) => data != oldWidget.data;
}
