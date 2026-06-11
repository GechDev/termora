import '../widgets/error_boundary.dart';
import 'build_context.dart';
import 'inherited_widget.dart';
import 'widget.dart';

/// An instantiation of a [Widget] at a particular location in the tree.
abstract class Element implements BuildContext {
  Widget _widget;
  Element? _parent;
  int _depth = 0;
  bool _dirty = true;
  bool _mounted = false;

  Element(Widget widget) : _widget = widget;

  @override
  Widget get widget => _widget;

  @override
  bool get mounted => _mounted;

  /// The parent element in the tree.
  Element? get parent => _parent;

  /// Depth of this element from the root of the tree.
  int get depth => _depth;

  /// Whether this element needs to be rebuilt.
  bool get dirty => _dirty;

  /// Clears the dirty flag once element reconstruction is complete.
  void clearDirty() {
    _dirty = false;
  }

  /// Inserts this element into the tree under [parent].
  void mount(Element? parent) {
    assert(!_mounted, 'Element is already mounted');
    _parent = parent;
    _depth = parent != null ? parent.depth + 1 : 0;
    _mounted = true;
    _dirty = true;
    rebuild();
  }

  /// Updates this element's configuration with [newWidget].
  void update(Widget newWidget) {
    assert(_mounted, 'Cannot update an unmounted element');
    assert(Widget.canUpdate(_widget, newWidget));
    _widget = newWidget;
    markNeedsBuild();
    rebuild();
  }

  /// Marks this element as needing a rebuild.
  void markNeedsBuild() {
    _dirty = true;
  }

  /// Rebuilds this element if marked dirty.
  void rebuild() {
    if (!_mounted || !_dirty) return;
    performRebuild();
  }

  /// Performs the actual element reconstruction and updates child elements.
  void performRebuild();

  /// Removes this element and its descendants from the tree.
  void unmount() {
    assert(_mounted, 'Cannot unmount an unmounted element');
    _mounted = false;
  }

  /// Updates an existing [child] element or creates a new one to match [newWidget].
  Element? updateChild(Element? child, Widget? newWidget) {
    if (newWidget == null) {
      if (child != null) {
        child.unmount();
      }
      return null;
    }

    if (child != null) {
      if (Widget.canUpdate(child.widget, newWidget)) {
        child.update(newWidget);
        return child;
      }
      child.unmount();
    }

    final newChild = newWidget.createElement();
    newChild.mount(this);
    return newChild;
  }

  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>() {
    var ancestor = _parent;
    while (ancestor != null) {
      if (ancestor is InheritedElement && ancestor.widget is T) {
        ancestor.addDependent(this);
        return ancestor.widget as T;
      }
      ancestor = ancestor.parent;
    }
    return null;
  }

  /// Visits immediate children of this element.
  void visitChildren(void Function(Element element) visitor);
}

/// Base class for elements that compose other widgets.
abstract class ComponentElement extends Element {
  Element? _child;

  ComponentElement(super.widget);

  /// The child element constructed by [build].
  Element? get child => _child;

  /// Builds the widget tree representing this element.
  Widget build();

  @override
  void performRebuild() {
    clearDirty();
    Widget built;
    try {
      built = build();
    } catch (e, s) {
      built = ErrorWidget.builder(e, s);
    }
    _child = updateChild(_child, built);
  }

  @override
  void unmount() {
    _child?.unmount();
    _child = null;
    super.unmount();
  }

  @override
  void visitChildren(void Function(Element element) visitor) {
    if (_child != null) {
      visitor(_child!);
    }
  }
}

/// Element that hosts a [StatelessWidget].
class StatelessElement extends ComponentElement {
  StatelessElement(StatelessWidget super.widget);

  @override
  StatelessWidget get widget => super.widget as StatelessWidget;

  @override
  Widget build() => widget.build(this);
}

/// Element that hosts a [StatefulWidget] and manages its [State] lifecycle.
class StatefulElement extends ComponentElement {
  final State<StatefulWidget> state;

  StatefulElement(StatefulWidget super.widget) : state = widget.createState();

  @override
  StatefulWidget get widget => super.widget as StatefulWidget;

  @override
  void mount(Element? parent) {
    state.mountState(this);
    state.initState();
    super.mount(parent);
  }

  @override
  void update(Widget newWidget) {
    final oldWidget = widget;
    state.updateWidget(newWidget as StatefulWidget);
    super.update(newWidget);
    state.didUpdateWidget(oldWidget);
  }

  @override
  Widget build() => state.build(this);

  @override
  void unmount() {
    state.dispose();
    state.unmountState();
    super.unmount();
  }
}
