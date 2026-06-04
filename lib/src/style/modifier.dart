import '../rendering/ansi.dart';

/// Text style modifiers for terminal rendering.
enum TextModifier {
  bold(Ansi.bold),
  dim(Ansi.dim),
  italic(Ansi.italic),
  underline(Ansi.underline),
  invert(Ansi.invert),
  strikethrough(Ansi.strikethrough);

  final String ansiCode;
  const TextModifier(this.ansiCode);
}
