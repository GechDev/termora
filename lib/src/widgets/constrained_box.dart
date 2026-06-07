import '../core/build_context.dart';
import '../core/element.dart';
import '../core/widget.dart';
import '../layout/box_constraints.dart';
import '../layout/geometry.dart';
import '../rendering/render_object.dart';

/// A widget that imposes additional constraints on its child.
class ConstrainedBox extends RenderObjectWidget {
  final BoxConstraints additionalConstraints;
  final Widget? child;

  const ConstrainedBox({
    super.key,
    required this.additionalConstraints,
    this.child,
  });

  @override
  RenderConstrainedBox createRenderObject(BuildContext context) {
    return RenderConstrainedBox(additionalConstraints: additionalConstraints);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderConstrainedBox renderObject,
  ) {
    renderObject.additionalConstraints = additionalConstraints;
  }

  @override
  ConstrainedBoxElement createElement() => ConstrainedBoxElement(this);
}

/// Element for [ConstrainedBox].
class ConstrainedBoxElement extends RenderObjectElement {
  Element? _childElement;

  ConstrainedBoxElement(ConstrainedBox super.widget);

  @override
  ConstrainedBox get widget => super.widget as ConstrainedBox;

  @override
  RenderConstrainedBox get renderObject =>
      super.renderObject as RenderConstrainedBox;

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
    final box = newWidget as ConstrainedBox;
    _childElement = updateChild(_childElement, box.child);
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

/// RenderObject for [ConstrainedBox].
class RenderConstrainedBox extends RenderObject {
  BoxConstraints _additionalConstraints;
  RenderObject? _child;

  RenderConstrainedBox({required BoxConstraints additionalConstraints})
      : _additionalConstraints = additionalConstraints;

  BoxConstraints get additionalConstraints => _additionalConstraints;
  set additionalConstraints(BoxConstraints value) {
    if (_additionalConstraints == value) return;
    _additionalConstraints = value;
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
    final effectiveConstraints = constraints.enforce(_additionalConstraints);
    if (_child != null) {
      _child!.layout(effectiveConstraints);
      size = _child!.size;
    } else {
      size = effectiveConstraints.constrain(effectiveConstraints.smallest);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_child != null) {
      context.paintChild(_child!, offset);
    }
  }

  @override
  void visitChildren(void Function(RenderObject child) visitor) {
    if (_child != null) visitor(_child!);
  }
}
