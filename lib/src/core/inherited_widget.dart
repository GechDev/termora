import 'element.dart';
import 'widget.dart';

/// Base class for widgets that efficiently propagate information down the tree.
abstract class InheritedWidget extends Widget {
  final Widget child;

  const InheritedWidget({super.key, required this.child});

  @override
  InheritedElement createElement() => InheritedElement(this);

  /// Whether framework should notify widgets that inherit from this widget.
  bool updateShouldNotify(covariant InheritedWidget oldWidget);
}

/// Element for [InheritedWidget] allowing descendants to look up inherited values.
class InheritedElement extends ComponentElement {
  final Set<Element> _dependents = <Element>{};

  InheritedElement(InheritedWidget super.widget);

  @override
  InheritedWidget get widget => super.widget as InheritedWidget;

  @override
  Widget build() => widget.child;

  /// Registers [dependent] as depending on this inherited element.
  void addDependent(Element dependent) {
    _dependents.add(dependent);
  }

  @override
  void update(Widget newWidget) {
    final oldWidget = widget;
    super.update(newWidget);
    if (widget.updateShouldNotify(oldWidget)) {
      _notifyDependents();
    }
  }

  void _notifyDependents() {
    for (final dependent in _dependents) {
      if (dependent.mounted) {
        dependent.markNeedsBuild();
      }
    }
  }
}
