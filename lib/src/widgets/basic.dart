import 'dart:math' as math;

import '../core/build_context.dart';
import '../core/element.dart';
import '../layout/geometry.dart';
import '../rendering/render_object.dart';
import '../rendering/unicode_width.dart';
import '../style/style.dart';

/// A widget that displays a string of text with optional styling.
class Text extends RenderObjectWidget {
  final String data;
  final Style style;

  const Text(
    this.data, {
    super.key,
    this.style = Style.none,
  });

  @override
  RenderText createRenderObject(BuildContext context) {
    return RenderText(data: data, style: style);
  }

  @override
  void updateRenderObject(BuildContext context, RenderText renderObject) {
    renderObject
      ..data = data
      ..style = style;
  }

  @override
  RenderTextElement createElement() => RenderTextElement(this);
}

/// Element for [Text] widgets.
class RenderTextElement extends RenderObjectElement {
  RenderTextElement(super.widget);

  @override
  void visitChildren(void Function(Element element) visitor) {}
}

/// RenderObject that measures and paints text.
class RenderText extends RenderObject {
  String _data;
  Style _style;

  RenderText({
    required String data,
    Style style = Style.none,
  })  : _data = data,
        _style = style;

  String get data => _data;
  set data(String value) {
    if (_data == value) return;
    _data = value;
    markNeedsLayout();
  }

  Style get style => _style;
  set style(Style value) {
    if (_style == value) return;
    _style = value;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    final lines = _data.split('\n');
    var maxLineWidth = 0;
    for (final line in lines) {
      final lineWidth = UnicodeWidth.stringWidth(line);
      if (lineWidth > maxLineWidth) {
        maxLineWidth = lineWidth;
      }
    }

    final naturalWidth = maxLineWidth;
    final naturalHeight = math.max(1, lines.length);

    size = constraints.constrain(Size(naturalWidth, naturalHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final lines = _data.split('\n');
    for (var i = 0; i < lines.length; i++) {
      final lineY = offset.y + i;
      if (lineY >= offset.y + size.height) break;

      context.buffer.writeString(offset.x, lineY, lines[i], _style);
    }
  }
}
