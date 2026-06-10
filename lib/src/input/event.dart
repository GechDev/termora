import 'key_code.dart';

/// Base class for all high-level terminal events (keyboard, resize, mouse).
sealed class TerminalEvent {
  const TerminalEvent();
}

/// A keyboard event generated when the user presses or releases a key.
final class KeyEvent extends TerminalEvent {
  /// The logical key that was triggered.
  final KeyCode code;

  /// The character string associated with the key press, if applicable.
  final String? character;

  /// Whether the Control (Ctrl) modifier key was active.
  final bool isCtrl;

  /// Whether the Alt / Option modifier key was active.
  final bool isAlt;

  /// Whether the Shift modifier key was active.
  final bool isShift;

  const KeyEvent({
    required this.code,
    this.character,
    this.isCtrl = false,
    this.isAlt = false,
    this.isShift = false,
  });

  /// Factory helper for a standard character press.
  factory KeyEvent.char(String char) => KeyEvent(
        code: KeyCode.character,
        character: char,
      );

  /// Factory helper for a standard enter key press.
  factory KeyEvent.enter() => const KeyEvent(code: KeyCode.enter);

  /// Factory helper for an escape key press.
  factory KeyEvent.escape() => const KeyEvent(code: KeyCode.escape);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KeyEvent &&
          other.code == code &&
          other.character == character &&
          other.isCtrl == isCtrl &&
          other.isAlt == isAlt &&
          other.isShift == isShift);

  @override
  int get hashCode => Object.hash(code, character, isCtrl, isAlt, isShift);

  @override
  String toString() =>
      'KeyEvent(code: $code, char: "$character", ctrl: $isCtrl, alt: $isAlt, shift: $isShift)';
}

/// An event triggered when the terminal window dimensions change.
final class ResizeEvent extends TerminalEvent {
  final int width;
  final int height;

  const ResizeEvent(this.width, this.height);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResizeEvent && other.width == width && other.height == height);

  @override
  int get hashCode => Object.hash(width, height);

  @override
  String toString() => 'ResizeEvent(${width}x$height)';
}
