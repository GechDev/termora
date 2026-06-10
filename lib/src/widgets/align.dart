import 'dart:math' as math;

import '../core/build_context.dart';
import '../core/element.dart';
import '../core/widget.dart';
import '../layout/edge_insets.dart';
import '../layout/geometry.dart';
import '../rendering/render_object.dart';

/// A point within a rectangle representing fractional placement from -1.0 to 1.0.
class Alignment {
  final double x;
  final double y;

  const Alignment(this.x, this.y);

  static const Alignment topLeft = Alignment(-1.0, -1.0);
  static const Alignment topCenter = Alignment(0.0, -1.0);
  static const Alignment topRight = Alignment(1.0, -1.0);

  static const Alignment centerLeft = Alignment(-1.0, 0.0);
  static const Alignment center = Alignment(0.0, 0.0);
  static const Alignment centerRight = Alignment(1.0, 0.0);

  static const Alignment bottomLeft = Alignment(-1.0, 1.0);
  static const Alignment bottomCenter = Alignment(0.0, 1.0);
  static const Alignment bottomRight = Alignment(1.0, 1.0);

  /// Computes the integer offset for [childSize] within [parentSize] based on this alignment.
  Offset alongOffset(Size parentSize, Size childSize) {
    final remainingW = math.max(0, parentSize.width - childSize.width);
    final remainingH = math.max(0, parentSize.height - childSize.height);

    final offsetX = ((x + 1.0) / 2.0 * remainingW).round();
    final offsetY = ((y + 1.0) / 2.0 * remainingH).round();

    return Offset(offsetX, offsetY);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Alignment && other.x == x && other.y == y);

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Alignment($x, $y)';
}

/// A widget that aligns its child within itself and optionally sizes itself based on the child's size.
class Align extends RenderObjectWidget {
  final Alignment alignment;
  final Widget? child;

  const Align({
    super.key,
    this.alignment = Alignment.center,
    this.child,
  });

  @override
  RenderAlign createRenderObject(BuildContext context) {
    return RenderAlign(alignment: alignment);
  }

  @override
  void updateRenderObject(BuildContext context, RenderAlign renderObject) {
    renderObject.alignment = alignment;
  }

  @override
  AlignElement createElement() => AlignElement(this);
}

/// A widget that centers its child within itself.
class Center extends Align {
  const Center({super.key, super.child}) : super(alignment: Alignment.center);
}

/// Element for [Align] and [Center].
class AlignElement extends RenderObjectElement {
  Element? _childElement;

  AlignElement(Align super.widget);

  @override
  Align get widget => super.widget as Align;

  @override
  RenderAlign get renderObject => super.renderObject as RenderAlign;

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
    final align = newWidget as Align;
    _childElement = updateChild(_childElement, align.child);
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

/// RenderObject that positions a single child according to an [Alignment].
class RenderAlign extends RenderObject {
  Alignment _alignment;
  RenderObject? _child;

  RenderAlign({Alignment alignment = Alignment.center})
      : _alignment = alignment;

  Alignment get alignment => _alignment;
  set alignment(Alignment value) {
    if (_alignment == value) return;
    _alignment = value;
    markNeedsLayout();
  }

  RenderObject? get child => _child;
  set child(RenderObject? value) {
    if (_child == value) return;
    _child?.parent = null;
    _child = value;
    _child?.parent = this;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    if (_child != null) {
      _child!.layout(constraints.loosen());
      size = constraints.biggest;
      _child!.offset = _alignment.alongOffset(size, _child!.size);
    } else {
      size = constraints.biggest;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_child != null) {
      context.paintChild(_child!, offset + _child!.offset);
    }
  }

  @override
  void visitChildren(void Function(RenderObject child) visitor) {
    if (_child != null) visitor(_child!);
  }
}

/// A widget that insets its child by the given padding.
class Padding extends RenderObjectWidget {
  final EdgeInsets padding;
  final Widget? child;

  const Padding({
    super.key,
    required this.padding,
    this.child,
  });

  @override
  RenderPadding createRenderObject(BuildContext context) {
    return RenderPadding(padding: padding);
  }

  @override
  void updateRenderObject(BuildContext context, RenderPadding renderObject) {
    renderObject.padding = padding;
  }

  @override
  PaddingElement createElement() => PaddingElement(this);
}

/// Element for [Padding].
class PaddingElement extends RenderObjectElement {
  Element? _childElement;

  PaddingElement(Padding super.widget);

  @override
  Padding get widget => super.widget as Padding;

  @override
  RenderPadding get renderObject => super.renderObject as RenderPadding;

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
    final p = newWidget as Padding;
    _childElement = updateChild(_childElement, p.child);
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

/// RenderObject for [Padding].
class RenderPadding extends RenderObject {
  EdgeInsets _padding;
  RenderObject? _child;

  RenderPadding({required EdgeInsets padding}) : _padding = padding;

  EdgeInsets get padding => _padding;
  set padding(EdgeInsets value) {
    if (_padding == value) return;
    _padding = value;
    markNeedsLayout();
  }

  RenderObject? get child => _child;
  set child(RenderObject? value) {
    if (_child == value) return;
    _child?.parent = null;
    _child = value;
    _child?.parent = this;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final insetsH = _padding.horizontal;
    final insetsV = _padding.vertical;

    if (_child != null) {
      final innerConstraints = constraints.deflate(
        horizontal: insetsH,
        vertical: insetsV,
      );
      _child!.layout(innerConstraints);
      size = constraints.constrain(
        Size(_child!.size.width + insetsH, _child!.size.height + insetsV),
      );
      _child!.offset = Offset(_padding.left, _padding.top);
    } else {
      size = constraints.constrain(Size(insetsH, insetsV));
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_child != null) {
      context.paintChild(_child!, offset + _child!.offset);
    }
  }

  @override
  void visitChildren(void Function(RenderObject child) visitor) {
    if (_child != null) visitor(_child!);
  }
}
