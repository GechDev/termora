import 'dart:math' as math;

import '../core/build_context.dart';
import '../core/element.dart';
import '../core/widget.dart';
import '../layout/box_constraints.dart';
import '../layout/flex_layout.dart';
import '../layout/geometry.dart';
import '../rendering/render_object.dart';

/// A [RenderObjectWidget] that accepts multiple children.
abstract class MultiChildRenderObjectWidget extends RenderObjectWidget {
  final List<Widget> children;

  const MultiChildRenderObjectWidget({
    super.key,
    this.children = const <Widget>[],
  });

  @override
  MultiChildRenderObjectElement createElement();
}

/// Element for widgets with multiple child elements.
class MultiChildRenderObjectElement extends RenderObjectElement {
  List<Element> _children = <Element>[];

  MultiChildRenderObjectElement(MultiChildRenderObjectWidget super.widget);

  @override
  MultiChildRenderObjectWidget get widget =>
      super.widget as MultiChildRenderObjectWidget;

  @override
  void mount(Element? parent) {
    super.mount(parent);
    _children = widget.children.map((childWidget) {
      final childElem = childWidget.createElement();
      childElem.mount(this);
      return childElem;
    }).toList();
    _syncChildRenderObjects();
  }

  @override
  void update(Widget newWidget) {
    super.update(newWidget);
    final multiWidget = newWidget as MultiChildRenderObjectWidget;
    final newChildren = <Element>[];

    for (var i = 0; i < multiWidget.children.length; i++) {
      final oldChild = i < _children.length ? _children[i] : null;
      final updated = updateChild(oldChild, multiWidget.children[i]);
      if (updated != null) newChildren.add(updated);
    }

    for (var i = multiWidget.children.length; i < _children.length; i++) {
      _children[i].unmount();
    }

    _children = newChildren;
    _syncChildRenderObjects();
  }

  void _syncChildRenderObjects() {
    if (renderObject is RenderFlex) {
      final flex = renderObject as RenderFlex;
      flex.children = _collectChildRenderObjects();
    }
  }

  List<RenderObject> _collectChildRenderObjects() {
    final list = <RenderObject>[];
    for (final child in _children) {
      final ro = _findChildRenderObject(child);
      if (ro != null) list.add(ro);
    }
    return list;
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
    for (final child in _children) {
      child.unmount();
    }
    _children.clear();
    super.unmount();
  }

  @override
  void visitChildren(void Function(Element element) visitor) {
    for (final child in _children) {
      visitor(child);
    }
  }
}

/// A widget that displays its children in a one-dimensional array.
class Flex extends MultiChildRenderObjectWidget {
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const Flex({
    super.key,
    required this.direction,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    super.children,
  });

  @override
  RenderFlex createRenderObject(BuildContext context) {
    return RenderFlex(
      direction: direction,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderFlex renderObject) {
    renderObject
      ..direction = direction
      ..mainAxisAlignment = mainAxisAlignment
      ..crossAxisAlignment = crossAxisAlignment
      ..mainAxisSize = mainAxisSize;
  }

  @override
  MultiChildRenderObjectElement createElement() =>
      MultiChildRenderObjectElement(this);
}

/// A widget that displays its children in a horizontal array.
class Row extends Flex {
  const Row({
    super.key,
    super.mainAxisAlignment,
    super.crossAxisAlignment,
    super.mainAxisSize,
    super.children,
  }) : super(direction: Axis.horizontal);
}

/// A widget that displays its children in a vertical array.
class Column extends Flex {
  const Column({
    super.key,
    super.mainAxisAlignment,
    super.crossAxisAlignment,
    super.mainAxisSize,
    super.children,
  }) : super(direction: Axis.vertical);
}

/// Interface for render objects that can declare flex sizing factors.
abstract interface class HasFlexFactor {
  int get flex;
  FlexFit get fit;
}

/// RenderObject for [Flex], [Row], and [Column].
class RenderFlex extends RenderObject {
  Axis _direction;
  MainAxisAlignment _mainAxisAlignment;
  CrossAxisAlignment _crossAxisAlignment;
  MainAxisSize _mainAxisSize;
  List<RenderObject> _children = <RenderObject>[];

  RenderFlex({
    required Axis direction,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
  })  : _direction = direction,
        _mainAxisAlignment = mainAxisAlignment,
        _crossAxisAlignment = crossAxisAlignment,
        _mainAxisSize = mainAxisSize;

  Axis get direction => _direction;
  set direction(Axis value) {
    if (_direction == value) return;
    _direction = value;
    markNeedsLayout();
  }

  MainAxisAlignment get mainAxisAlignment => _mainAxisAlignment;
  set mainAxisAlignment(MainAxisAlignment value) {
    if (_mainAxisAlignment == value) return;
    _mainAxisAlignment = value;
    markNeedsLayout();
  }

  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;
  set crossAxisAlignment(CrossAxisAlignment value) {
    if (_crossAxisAlignment == value) return;
    _crossAxisAlignment = value;
    markNeedsLayout();
  }

  MainAxisSize get mainAxisSize => _mainAxisSize;
  set mainAxisSize(MainAxisSize value) {
    if (_mainAxisSize == value) return;
    _mainAxisSize = value;
    markNeedsLayout();
  }

  List<RenderObject> get children => _children;
  set children(List<RenderObject> value) {
    _children = value;
    for (final child in _children) {
      child.parent = this;
    }
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final isHorizontal = _direction == Axis.horizontal;
    final maxMain = isHorizontal ? constraints.maxWidth : constraints.maxHeight;
    final maxCross = isHorizontal ? constraints.maxHeight : constraints.maxWidth;

    var totalFlex = 0;
    var usedMainSpace = 0;
    var maxChildCross = 0;

    // Pass 1: Measure non-flexible children
    for (final child in _children) {
      if (child is HasFlexFactor && (child as HasFlexFactor).flex > 0) {
        totalFlex += (child as HasFlexFactor).flex;
      } else {
        final childConstraints = isHorizontal
            ? BoxConstraints(maxWidth: math.max(0, maxMain - usedMainSpace))
            : BoxConstraints(maxHeight: math.max(0, maxMain - usedMainSpace));
        child.layout(childConstraints);
        final mainSize = isHorizontal ? child.size.width : child.size.height;
        final crossSize = isHorizontal ? child.size.height : child.size.width;
        usedMainSpace += mainSize;
        maxChildCross = math.max(maxChildCross, crossSize);
      }
    }

    // Pass 2: Measure flexible children
    final remainingMain = math.max(0, maxMain - usedMainSpace);
    if (totalFlex > 0) {
      for (final child in _children) {
        if (child is HasFlexFactor && (child as HasFlexFactor).flex > 0) {
          final flexChild = child as HasFlexFactor;
          final allocated = (remainingMain * flexChild.flex) ~/ totalFlex;
          final childConstraints = isHorizontal
              ? (flexChild.fit == FlexFit.tight
                  ? BoxConstraints.tightFor(width: allocated)
                  : BoxConstraints(maxWidth: allocated))
              : (flexChild.fit == FlexFit.tight
                  ? BoxConstraints.tightFor(height: allocated)
                  : BoxConstraints(maxHeight: allocated));
          child.layout(childConstraints);
          final mainSize = isHorizontal ? child.size.width : child.size.height;
          final crossSize = isHorizontal ? child.size.height : child.size.width;
          usedMainSpace += mainSize;
          maxChildCross = math.max(maxChildCross, crossSize);
        }
      }
    }

    // Determine final flex container size
    final finalMain = _mainAxisSize == MainAxisSize.max
        ? maxMain
        : math.min(maxMain, usedMainSpace);
    final finalCross = math.min(maxCross, maxChildCross);

    size = constraints.constrain(
      isHorizontal ? Size(finalMain, finalCross) : Size(finalCross, finalMain),
    );

    // Pass 3: Position children along main and cross axes
    final freeMainSpace = math.max(0, finalMain - usedMainSpace);
    var mainOffset = 0;
    var spaceBetweenChildren = 0;

    switch (_mainAxisAlignment) {
      case MainAxisAlignment.start:
        mainOffset = 0;
        break;
      case MainAxisAlignment.end:
        mainOffset = freeMainSpace;
        break;
      case MainAxisAlignment.center:
        mainOffset = freeMainSpace ~/ 2;
        break;
      case MainAxisAlignment.spaceBetween:
        if (_children.length > 1) {
          spaceBetweenChildren = freeMainSpace ~/ (_children.length - 1);
        }
        break;
      case MainAxisAlignment.spaceAround:
        if (_children.isNotEmpty) {
          final space = freeMainSpace ~/ _children.length;
          mainOffset = space ~/ 2;
          spaceBetweenChildren = space;
        }
        break;
      case MainAxisAlignment.spaceEvenly:
        if (_children.isNotEmpty) {
          final space = freeMainSpace ~/ (_children.length + 1);
          mainOffset = space;
          spaceBetweenChildren = space;
        }
        break;
    }

    var currentMain = mainOffset;
    for (final child in _children) {
      final childMain = isHorizontal ? child.size.width : child.size.height;
      final childCross = isHorizontal ? child.size.height : child.size.width;

      var currentCross = 0;
      switch (_crossAxisAlignment) {
        case CrossAxisAlignment.start:
          currentCross = 0;
          break;
        case CrossAxisAlignment.end:
          currentCross = math.max(0, finalCross - childCross);
          break;
        case CrossAxisAlignment.center:
          currentCross = math.max(0, (finalCross - childCross) ~/ 2);
          break;
        case CrossAxisAlignment.stretch:
          currentCross = 0;
          break;
      }

      child.offset = isHorizontal
          ? Offset(currentMain, currentCross)
          : Offset(currentCross, currentMain);

      currentMain += childMain + spaceBetweenChildren;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    for (final child in _children) {
      context.paintChild(child, offset + child.offset);
    }
  }

  @override
  void visitChildren(void Function(RenderObject child) visitor) {
    for (final child in _children) {
      visitor(child);
    }
  }
}
