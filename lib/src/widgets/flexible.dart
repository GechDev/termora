import '../core/build_context.dart';
import '../core/element.dart';
import '../core/widget.dart';
import '../layout/box_constraints.dart';
import '../layout/flex_layout.dart';
import '../layout/geometry.dart';
import '../rendering/render_object.dart';
import 'flex.dart';

/// A widget that controls how a child of a [Row], [Column], or [Flex] flexes.
class Flexible extends RenderObjectWidget {
  final int flex;
  final FlexFit fit;
  final Widget child;

  const Flexible({
    super.key,
    this.flex = 1,
    this.fit = FlexFit.loose,
    required this.child,
  }) : assert(flex > 0, 'Flex factor must be strictly positive');

  @override
  RenderFlexible createRenderObject(BuildContext context) {
    return RenderFlexible(flex: flex, fit: fit);
  }

  @override
  void updateRenderObject(BuildContext context, RenderFlexible renderObject) {
    renderObject
      ..flex = flex
      ..fit = fit;
  }

  @override
  FlexibleElement createElement() => FlexibleElement(this);
}

/// Element for [Flexible] managing child element synchronization.
class FlexibleElement extends RenderObjectElement {
  Element? _childElement;

  FlexibleElement(Flexible super.widget);

  @override
  Flexible get widget => super.widget as Flexible;

  @override
  RenderFlexible get renderObject => super.renderObject as RenderFlexible;

  @override
  void mount(Element? parent) {
    super.mount(parent);
    _childElement = updateChild(null, widget.child);
    renderObject.child = _findChildRenderObject(_childElement);
  }

  @override
  void update(Widget newWidget) {
    super.update(newWidget);
    final flexible = newWidget as Flexible;
    _childElement = updateChild(_childElement, flexible.child);
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

/// A widget that expands a child of a [Row], [Column], or [Flex] so that the child fills the available space.
class Expanded extends Flexible {
  const Expanded({
    super.key,
    super.flex = 1,
    required super.child,
  }) : super(fit: FlexFit.tight);
}

/// Creates flexible empty space in a [Flex], [Row], or [Column].
class Spacer extends StatelessWidget {
  final int flex;

  const Spacer({super.key, this.flex = 1})
      : assert(flex > 0, 'Spacer flex factor must be positive');

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: const SizedBox(width: 0, height: 0),
    );
  }
}

/// RenderObject for [Flexible] implementing [HasFlexFactor].
class RenderFlexible extends RenderObject implements HasFlexFactor {
  int _flex;
  FlexFit _fit;
  RenderObject? _child;

  RenderFlexible({
    required int flex,
    required FlexFit fit,
  })  : _flex = flex,
        _fit = fit;

  @override
  int get flex => _flex;
  set flex(int value) {
    if (_flex == value) return;
    _flex = value;
    markNeedsLayout();
  }

  @override
  FlexFit get fit => _fit;
  set fit(FlexFit value) {
    if (_fit == value) return;
    _fit = value;
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
      _child!.layout(constraints);
      size = _child!.size;
    } else {
      size = constraints.constrain(constraints.smallest);
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

/// A box with a specified size.
class SizedBox extends RenderObjectWidget {
  final int? width;
  final int? height;
  final Widget? child;

  const SizedBox({super.key, this.width, this.height, this.child});

  /// Creates a box that will become as large as its parent allows.
  const SizedBox.expand({super.key, this.child})
      : width = null,
        height = null;

  /// Creates a box with zero width and height.
  const SizedBox.shrink({super.key, this.child})
      : width = 0,
        height = 0;

  @override
  RenderSizedBox createRenderObject(BuildContext context) {
    return RenderSizedBox(width: width, height: height);
  }

  @override
  void updateRenderObject(BuildContext context, RenderSizedBox renderObject) {
    renderObject
      ..width = width
      ..height = height;
  }

  @override
  SizedBoxElement createElement() => SizedBoxElement(this);
}

/// Element for [SizedBox].
class SizedBoxElement extends RenderObjectElement {
  Element? _childElement;

  SizedBoxElement(SizedBox super.widget);

  @override
  SizedBox get widget => super.widget as SizedBox;

  @override
  RenderSizedBox get renderObject => super.renderObject as RenderSizedBox;

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
    final box = newWidget as SizedBox;
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

/// RenderObject for [SizedBox].
class RenderSizedBox extends RenderObject {
  int? _width;
  int? _height;
  RenderObject? _child;

  RenderSizedBox({int? width, int? height})
      : _width = width,
        _height = height;

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
    final tightConstraints = constraints.enforce(
      BoxConstraints.tightFor(width: _width, height: _height),
    );

    if (_child != null) {
      _child!.layout(tightConstraints);
      size = _child!.size;
    } else {
      size = tightConstraints.constrain(
        Size(_width ?? 0, _height ?? 0),
      );
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
