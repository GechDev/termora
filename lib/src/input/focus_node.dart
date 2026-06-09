import 'event.dart';

/// An object that can be used by a stateful widget to obtain the keyboard focus and handle events.
class FocusNode {
  bool _hasFocus = false;
  bool canRequestFocus;
  final List<void Function()> _listeners = <void Function()>[];
  bool Function(KeyEvent event)? onKeyEvent;

  FocusNode({
    this.canRequestFocus = true,
    this.onKeyEvent,
  });

  /// Whether this node has the current input focus.
  bool get hasFocus => _hasFocus;

  /// Requests that this node becomes the primary focused node.
  void requestFocus() {
    if (!canRequestFocus || _hasFocus) return;
    _hasFocus = true;
    _notifyListeners();
  }

  /// Relinquishes focus.
  void unfocus() {
    if (!_hasFocus) return;
    _hasFocus = false;
    _notifyListeners();
  }

  /// Adds a listener that fires whenever focus state changes.
  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  /// Removes a registered listener.
  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in List<void Function()>.from(_listeners)) {
      listener();
    }
  }

  /// Dispatches [event] to this node. Returns true if handled.
  bool handleKeyEvent(KeyEvent event) {
    if (!_hasFocus) return false;
    if (onKeyEvent != null) {
      return onKeyEvent!(event);
    }
    return false;
  }

  /// Disposes this node.
  void dispose() {
    _listeners.clear();
    _hasFocus = false;
  }
}
