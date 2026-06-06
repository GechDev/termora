import '../core/build_context.dart';
import '../core/element.dart';
import '../core/widget.dart';
import '../layout/edge_insets.dart';
import '../layout/geometry.dart';
import '../rendering/cell.dart';
import '../rendering/render_object.dart';
import '../style/border.dart';
import '../style/style.dart';

/// A convenience widget that combines sizing, padding, borders, and background styling.
class Container extends RenderObjectWidget {
  final Widget? child;
  final int? width;
  final int? height;
  final EdgeInsets? padding;
  final Style? style;
  final Border? border;

  const Container({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.style,
    this.border,
  });

  @override
  RenderContainer createRenderObject(BuildContext context) {
    return RenderContainer(
      width: width,
      height: height,
      padding: padding ?? EdgeInsets.zero,
      style: style,
      border: border,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderContainer renderObject) {
    renderObject
      ..width = width
      ..height = height
      ..padding = padding ?? EdgeInsets.zero
      ..style = style
      ..border = border;
  }

  @override
  ContainerElement createElement() => ContainerElement(this);
}

/// Element for [Container] managing child element synchronization.
class ContainerElement extends RenderObjectElement {
  Element? _childElement;

  ContainerElement(Container super.widget);

  @override
  Container get widget => super.widget as Container;

  @override
  RenderContainer get renderObject => super.renderObject as RenderContainer;

  @override
  void mount(Element? parent) {
    super.mount(parent);
    if (widget.child != null) {
      _childElement = updateChild(null, widget.child);
      renderObject.child = _findChildRenderObject(_childElement);
    }
  }

  @override
  void update(Widget newWidget) {
    super.update(newWidget);
    final container = newWidget as Container;
    _childElement = updateChild(_childElement, container.child);
    renderObject.child = _findChildRenderObject(_childElement);
  }

  RenderObject? _findChildRenderObject(Element? element) {
    if (element == null) return null;
    if (element is RenderObjectElement) return element.renderObject;
    if (element is ComponentElement) {
      return _findChildRenderObject(element.child);
    }
    return null;
  }

  @override
  void unmount() {
    _childElement?.unmount();
    _childElement = null;
    super.unmount();
  }

  @override
  void visitChildren(void Function(Element element) visitor) {
    if (_childElement != null) visitor(_childElement!);
  }
}

/// RenderObject that paints background, borders, and positions its single child.
class RenderContainer extends RenderObject {
  int? _width;
  int? _height;
  EdgeInsets _padding;
  Style? _style;
  Border? _border;
  RenderObject? _child;

  RenderContainer({
    int? width,
    int? height,
    EdgeInsets padding = EdgeInsets.zero,
    Style? style,
    Border? border,
  })  : _width = width,
        _height = height,
        _padding = padding,
        _style = style,
        _border = border;

  RenderObject? get child => _child;
  set child(RenderObject? value) {
    if (_child == value) return;
    _child?.parent = null;
    _child = value;
    _child?.parent = this;
    markNeedsLayout();
  }

  int? get width => _width;
  set width(int? value) {
    if (_width == value) return;
    _width = value;
    markNeedsLayout();
  }

  int? get height => _height;
  set height(int? value) {
    if (_height == value) return;
    _height = value;
    markNeedsLayout();
  }

  EdgeInsets get padding => _padding;
  set padding(EdgeInsets value) {
    if (_padding == value) return;
    _padding = value;
    markNeedsLayout();
  }

  Style? get style => _style;
  set style(Style? value) {
    if (_style == value) return;
    _style = value;
    markNeedsPaint();
  }

  Border? get border => _border;
  set border(Border? value) {
    if (_border == value) return;
    _border = value;
    markNeedsLayout();
  }

  int get _borderHorizontal => _border != null ? 2 : 0;
  int get _borderVertical => _border != null ? 2 : 0;

  @override
  void performLayout() {
    final borderH = _borderHorizontal;
    final borderV = _borderVertical;
    final insetsH = _padding.horizontal + borderH;
    final insetsV = _padding.vertical + borderV;

    if (_child != null) {
      final innerConstraints = constraints.deflate(
        horizontal: insetsH,
        vertical: insetsV,
      );
      _child!.layout(innerConstraints);
    }

    final naturalWidth = _width ?? ((_child?.size.width ?? 0) + insetsH);
    final naturalHeight = _height ?? ((_child?.size.height ?? 0) + insetsV);

    size = constraints.constrain(Size(naturalWidth, naturalHeight));

    if (_child != null) {
      final childLeft = (_border != null ? 1 : 0) + _padding.left;
      final childTop = (_border != null ? 1 : 0) + _padding.top;
      _child!.offset = Offset(childLeft, childTop);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final w = size.width;
    final h = size.height;

    // Paint background if styled with background color
    if (_style?.backgroundColor != null) {
      context.buffer.fill(
        offset.x,
        offset.y,
        w,
        h,
        Cell.char(' ', _style!),
      );
    }

    // Paint border if present
    if (_border != null && w >= 2 && h >= 2) {
      final chars = _border!.chars;
      final bStyle = _border!.style;

      // Top edge
      context.buffer.set(offset.x, offset.y, Cell.char(chars.topLeft, bStyle));
      for (var x = 1; x < w - 1; x++) {
        context.buffer
            .set(offset.x + x, offset.y, Cell.char(chars.horizontal, bStyle));
      }
      context.buffer
          .set(offset.x + w - 1, offset.y, Cell.char(chars.topRight, bStyle));

      // Sides
      for (var y = 1; y < h - 1; y++) {
        context.buffer
            .set(offset.x, offset.y + y, Cell.char(chars.vertical, bStyle));
        context.buffer.set(
            offset.x + w - 1, offset.y + y, Cell.char(chars.vertical, bStyle));
      }

      // Bottom edge
      context.buffer
          .set(offset.x, offset.y + h - 1, Cell.char(chars.bottomLeft, bStyle));
      for (var x = 1; x < w - 1; x++) {
        context.buffer.set(offset.x + x, offset.y + h - 1,
            Cell.char(chars.horizontal, bStyle));
      }
      context.buffer.set(offset.x + w - 1, offset.y + h - 1,
          Cell.char(chars.bottomRight, bStyle));
    }

    // Paint child
    if (_child != null) {
      context.paintChild(_child!, offset + _child!.offset);
    }
  }

  @override
  void visitChildren(void Function(RenderObject child) visitor) {
    if (_child != null) visitor(_child!);
  }
}
