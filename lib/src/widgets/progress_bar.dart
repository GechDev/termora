import 'dart:math' as math;

import '../core/build_context.dart';
import '../core/widget.dart';
import '../rendering/unicode_width.dart';
import '../style/color.dart';
import '../style/modifier.dart';
import '../style/style.dart';
import 'basic.dart';
import 'flex.dart';

/// A terminal progress bar widget with customizable glyphs, styles, and percentage readout.
class ProgressBar extends StatelessWidget {
  /// The progress value between 0.0 (0%) and 1.0 (100%).
  final double value;

  /// The total width in terminal columns, including labels and percentage.
  final int width;

  /// The character used for filled segments. Defaults to '█'.
  final String filledChar;

  /// The character used for unfilled segments. Defaults to '░'.
  final String emptyChar;

  /// Optional prefix label displayed before the progress bar.
  final String? label;

  /// Whether to display a numerical percentage label (e.g. ` 75%`).
  final bool showPercentage;

  /// Style applied to the filled portion of the bar.
  final Style filledStyle;

  /// Style applied to the empty portion of the bar.
  final Style emptyStyle;

  /// Style applied to the percentage indicator.
  final Style? percentageStyle;

  /// Style applied to the prefix label.
  final Style? labelStyle;

  const ProgressBar({
    super.key,
    required this.value,
    this.width = 30,
    this.filledChar = '█',
    this.emptyChar = '░',
    this.label,
    this.showPercentage = true,
    this.filledStyle = const Style(foregroundColor: Color.brightGreen),
    this.emptyStyle = const Style(foregroundColor: Color.brightBlack),
    this.percentageStyle,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0);
    final percentInt = (clampedValue * 100).toInt();

    final children = <Widget>[];

    var remainingWidth = width;

    // Optional prefix label
    if (label != null && label!.isNotEmpty) {
      final labelText = '$label ';
      remainingWidth -= UnicodeWidth.stringWidth(labelText);
      children.add(
        Text(
          labelText,
          style: labelStyle ??
              const Style(
                foregroundColor: Color.brightYellow,
                modifiers: {TextModifier.bold},
              ),
        ),
      );
    }

    // Percentage suffix
    String? percentageText;
    if (showPercentage) {
      percentageText = ' ${percentInt.toString().padLeft(3)}%';
      remainingWidth -= UnicodeWidth.stringWidth(percentageText);
    }

    final barWidth = math.max(0, remainingWidth);
    final filledCount = (barWidth * clampedValue).round().clamp(0, barWidth);
    final emptyCount = barWidth - filledCount;

    if (filledCount > 0) {
      children.add(
        Text(
          filledChar * filledCount,
          style: filledStyle,
        ),
      );
    }

    if (emptyCount > 0) {
      children.add(
        Text(
          emptyChar * emptyCount,
          style: emptyStyle,
        ),
      );
    }

    if (percentageText != null) {
      children.add(
        Text(
          percentageText,
          style: percentageStyle ??
              const Style(
                foregroundColor: Color.brightCyan,
                modifiers: {TextModifier.bold},
              ),
        ),
      );
    }

    return Row(
      children: children,
    );
  }
}
