import 'dart:math' as math;

import '../core/build_context.dart';
import '../core/element.dart';
import '../layout/geometry.dart';
import '../rendering/render_object.dart';
import '../rendering/unicode_width.dart';
import '../style/style.dart';

/// An immutable span of styled text.
class TextSpan {
  final String? text;
  final Style? style;
  final List<TextSpan> children;

  const TextSpan({
    this.text,
    this.style,
    this.children = const <TextSpan>[],
  });

  /// Computes the unstyled plain text of this span and all its children.
  String toPlainText() {
    final buffer = StringBuffer();
    if (text != null) buffer.write(text);
    for (final child in children) {
      buffer.write(child.toPlainText());
    }
    return buffer.toString();
  }

  /// Total visual width in terminal monospace columns.
  int get visualWidth => UnicodeWidth.stringWidth(toPlainText());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TextSpan &&
          other.text == text &&
          other.style == style &&
          other.children.length == children.length &&
          _listEquals(other.children, children));

  static bool _listEquals(List<TextSpan> a, List<TextSpan> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(text, style, Object.hashAll(children));
}

/// A paragraph of rich text with different styles per span.
class RichText extends RenderObjectWidget {
  final TextSpan text;

  const RichText({
    super.key,
    required this.text,
  });

  @override
  RenderRichText createRenderObject(BuildContext context) {
    return RenderRichText(text: text);
  }

  @override
  void updateRenderObject(BuildContext context, RenderRichText renderObject) {
    renderObject.text = text;
  }

  @override
  RichTextElement createElement() => RichTextElement(this);
}

/// Element for [RichText].
class RichTextElement extends RenderObjectElement {
  RichTextElement(super.widget);

  @override
  void visitChildren(void Function(Element element) visitor) {}
}

/// RenderObject that paints multi-styled [TextSpan]s.
class RenderRichText extends RenderObject {
  TextSpan _text;

  RenderRichText({required TextSpan text}) : _text = text;

  TextSpan get text => _text;
  set text(TextSpan value) {
    if (_text == value) return;
    _text = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final plain = _text.toPlainText();
    final lines = plain.split('\n');
    var maxLineWidth = 0;
    for (final line in lines) {
      final w = UnicodeWidth.stringWidth(line);
      if (w > maxLineWidth) maxLineWidth = w;
    }

    size = constraints.constrain(
      Size(maxLineWidth, math.max(1, lines.length)),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var curX = offset.x;
    var curY = offset.y;

    void paintSpan(TextSpan span, Style inheritedStyle) {
      final effectiveStyle = inheritedStyle.merge(span.style);

      if (span.text != null && span.text!.isNotEmpty) {
        final lines = span.text!.split('\n');
        for (var i = 0; i < lines.length; i++) {
          if (i > 0) {
            curY++;
            curX = offset.x;
          }
          final line = lines[i];
          if (line.isNotEmpty) {
            final written = context.buffer.writeString(
              curX,
              curY,
              line,
              effectiveStyle,
            );
            curX += written;
          }
        }
      }

      for (final child in span.children) {
        paintSpan(child, effectiveStyle);
      }
    }

    paintSpan(_text, Style.none);
  }
}
