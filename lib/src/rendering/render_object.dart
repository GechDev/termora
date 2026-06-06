import '../core/build_context.dart';
import '../core/element.dart';
import '../core/widget.dart';
import '../layout/box_constraints.dart';
import '../layout/geometry.dart';
import 'screen_buffer.dart';

/// Context passed to [RenderObject.paint] providing access to the screen buffer.
class PaintingContext {
  final ScreenBuffer buffer;

  const PaintingContext(this.buffer);

  /// Paints [child] at the specified [offset] relative to the current coordinate space.
  void paintChild(RenderObject child, Offset offset) {
    child.paint(this, offset);
  }
}

/// An object in the render tree responsible for computing layout and painting.
abstract class RenderObject {
  BoxConstraints constraints = const BoxConstraints();
  Size size = Size.zero;
  Offset offset = Offset.zero;
  RenderObject? parent;
  bool _needsLayout = true;
  bool _needsPaint = true;

  bool get needsLayout => _needsLayout;
  bool get needsPaint => _needsPaint;

  /// Marks this render object as needing layout calculation.
  void markNeedsLayout() {
    _needsLayout = true;
    _needsPaint = true;
    parent?.markNeedsLayout();
  }

  /// Marks this render object as needing painting.
  void markNeedsPaint() {
    _needsPaint = true;
    parent?.markNeedsPaint();
  }

  /// Computes layout for this render object given [constraints].
  void layout(BoxConstraints constraints) {
    this.constraints = constraints;
    performLayout();
    _needsLayout = false;
  }

  /// Subclasses override this method to calculate [size] and layout children.
  void performLayout();

  /// Subclasses override this method to draw content to [context.buffer].
  void paint(PaintingContext context, Offset offset);

  /// Visits immediate child render objects.
  void visitChildren(void Function(RenderObject child) visitor) {}
}

/// A [Widget] that has a corresponding [RenderObject].
abstract class RenderObjectWidget extends Widget {
  const RenderObjectWidget({super.key});

  /// Creates an instance of the [RenderObject] represented by this widget.
  RenderObject createRenderObject(BuildContext context);

  /// Updates the configuration of [renderObject].
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) {}

  @override
  RenderObjectElement createElement();
}

/// An [Element] that hosts a [RenderObject].
abstract class RenderObjectElement extends Element {
  late final RenderObject renderObject;

  RenderObjectElement(RenderObjectWidget super.widget);

  @override
  RenderObjectWidget get widget => super.widget as RenderObjectWidget;

  @override
  void mount(Element? parent) {
    super.mount(parent);
    renderObject = widget.createRenderObject(this);
    _attachRenderObject();
  }

  @override
  void update(Widget newWidget) {
    super.update(newWidget);
    widget.updateRenderObject(this, renderObject);
  }

  @override
  void performRebuild() {
    clearDirty();
  }

  void _attachRenderObject() {
    RenderObject? ancestorRenderObject;
    var ancestor = parent;
    while (ancestor != null) {
      if (ancestor is RenderObjectElement) {
        ancestorRenderObject = ancestor.renderObject;
        break;
      }
      ancestor = ancestor.parent;
    }
    renderObject.parent = ancestorRenderObject;
  }

  @override
  void unmount() {
    renderObject.parent = null;
    super.unmount();
  }
}
