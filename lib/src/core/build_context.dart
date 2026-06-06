import 'widget.dart';

/// A handle to the location of a widget in the element tree.
abstract interface class BuildContext {
  /// The [Widget] associated with this context.
  Widget get widget;

  /// Whether the associated [Element] is currently mounted in the tree.
  bool get mounted;
}
