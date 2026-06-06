import 'package:meta/meta.dart';

import 'build_context.dart';
import 'element.dart';
import 'key.dart';

/// The blueprint and configuration for an [Element] in the user interface.
abstract class Widget {
  /// An optional key used to identify and preserve element state across builds.
  final Key? key;

  const Widget({this.key});

  /// Inflates this widget into a concrete [Element] in the element tree.
  Element createElement();

  /// Whether the [newWidget] can be used to update an element currently configured with [oldWidget].
  static bool canUpdate(Widget oldWidget, Widget newWidget) {
    return oldWidget.runtimeType == newWidget.runtimeType &&
        oldWidget.key == newWidget.key;
  }
}

/// A widget that does not require mutable state.
abstract class StatelessWidget extends Widget {
  const StatelessWidget({super.key});

  /// Describes the part of the user interface represented by this widget.
  Widget build(BuildContext context);

  @override
  StatelessElement createElement() => StatelessElement(this);
}

/// A widget that has mutable state.
abstract class StatefulWidget extends Widget {
  const StatefulWidget({super.key});

  /// Creates the mutable state object for this widget in the element tree.
  State<StatefulWidget> createState();

  @override
  StatefulElement createElement() => StatefulElement(this);
}

/// The logic and internal state for a [StatefulWidget].
abstract class State<T extends StatefulWidget> {
  T? _widget;
  StatefulElement? _element;

  /// The current configuration widget for this state.
  T get widget => _widget!;

  /// The context in the element tree for this state.
  BuildContext get context => _element!;

  /// Whether this state object is currently in a tree.
  bool get mounted => _element != null && _element!.mounted;

  /// Called once when this object is inserted into the tree.
  @mustCallSuper
  void initState() {}

  /// Called whenever the widget configuration changes.
  @mustCallSuper
  void didUpdateWidget(covariant T oldWidget) {}

  /// Notifies the framework that the internal state of this object has changed.
  void setState(void Function() fn) {
    assert(mounted, 'Cannot call setState on an unmounted State object');
    fn();
    _element?.markNeedsBuild();
  }

  /// Called when this object is removed from the tree permanently.
  @mustCallSuper
  void dispose() {}

  /// Builds the widget tree representing this state.
  Widget build(BuildContext context);

  @internal
  void mountState(StatefulElement element) {
    _element = element;
    _widget = element.widget as T;
  }

  @internal
  void updateWidget(T newWidget) {
    _widget = newWidget;
  }

  @internal
  void unmountState() {
    _element = null;
  }
}
