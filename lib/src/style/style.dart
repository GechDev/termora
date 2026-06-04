import '../rendering/ansi.dart';
import 'color.dart';
import 'modifier.dart';

/// Defines visual attributes for a character or region in the terminal.
class Style {
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Set<TextModifier> modifiers;

  const Style({
    this.foregroundColor,
    this.backgroundColor,
    this.modifiers = const <TextModifier>{},
  });

  /// An empty style with no colors or modifiers applied.
  static const Style none = Style();

  /// Generates the complete ANSI escape sequence to apply this entire style.
  String toAnsi() {
    if (this == none) return Ansi.reset;

    final buffer = StringBuffer();
    // Start with reset to ensure clean baseline
    buffer.write(Ansi.reset);

    for (final modifier in modifiers) {
      buffer.write(modifier.ansiCode);
    }
    if (foregroundColor != null) {
      buffer.write(foregroundColor!.toForegroundAnsi());
    }
    if (backgroundColor != null) {
      buffer.write(backgroundColor!.toBackgroundAnsi());
    }
    return buffer.toString();
  }

  /// Generates an optimized delta ANSI escape sequence to transition from [previous] to this style.
  String diffAnsi(Style previous) {
    if (this == previous) return '';

    // If modifiers were removed, we need a reset
    final removedModifiers = previous.modifiers.difference(modifiers);
    final needReset = removedModifiers.isNotEmpty ||
        (previous.foregroundColor != null && foregroundColor == null) ||
        (previous.backgroundColor != null && backgroundColor == null);

    if (needReset) {
      return toAnsi();
    }

    final buffer = StringBuffer();

    // Add newly added modifiers
    final addedModifiers = modifiers.difference(previous.modifiers);
    for (final mod in addedModifiers) {
      buffer.write(mod.ansiCode);
    }

    // Update foreground color if changed
    if (foregroundColor != previous.foregroundColor &&
        foregroundColor != null) {
      buffer.write(foregroundColor!.toForegroundAnsi());
    }

    // Update background color if changed
    if (backgroundColor != previous.backgroundColor &&
        backgroundColor != null) {
      buffer.write(backgroundColor!.toBackgroundAnsi());
    }

    return buffer.toString();
  }

  /// Creates a copy of this style with selected fields replaced.
  Style copyWith({
    Color? foregroundColor,
    bool clearForegroundColor = false,
    Color? backgroundColor,
    bool clearBackgroundColor = false,
    Set<TextModifier>? modifiers,
  }) {
    return Style(
      foregroundColor: clearForegroundColor
          ? null
          : (foregroundColor ?? this.foregroundColor),
      backgroundColor: clearBackgroundColor
          ? null
          : (backgroundColor ?? this.backgroundColor),
      modifiers: modifiers ?? this.modifiers,
    );
  }

  /// Merges this style with [other], with [other]'s non-null properties overriding this.
  Style merge(Style? other) {
    if (other == null || other == none) return this;
    return Style(
      foregroundColor: other.foregroundColor ?? foregroundColor,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      modifiers: {...modifiers, ...other.modifiers},
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Style &&
          other.foregroundColor == foregroundColor &&
          other.backgroundColor == backgroundColor &&
          other.modifiers.length == modifiers.length &&
          other.modifiers.containsAll(modifiers));

  @override
  int get hashCode => Object.hash(
        foregroundColor,
        backgroundColor,
        Object.hashAll(modifiers),
      );

  @override
  String toString() =>
      'Style(fg: $foregroundColor, bg: $backgroundColor, mod: $modifiers)';
}
