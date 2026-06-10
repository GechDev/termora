import 'event.dart';
import 'focus_node.dart';
import 'key_code.dart';

/// Manages keyboard focus and tab navigation between [FocusNode]s.
class FocusManager {
  final List<FocusNode> _nodes = <FocusNode>[];
  FocusNode? _primaryFocus;

  /// The currently focused node, if any.
  FocusNode? get primaryFocus => _primaryFocus;

  /// Registers [node] with the focus manager.
  void register(FocusNode node) {
    if (!_nodes.contains(node)) {
      _nodes.add(node);
      if (_primaryFocus == null && node.canRequestFocus) {
        setFocus(node);
      }
    }
  }

  /// Unregisters [node].
  void unregister(FocusNode node) {
    _nodes.remove(node);
    if (_primaryFocus == node) {
      _primaryFocus = null;
      nextFocus();
    }
  }

  /// Sets focus specifically to [node].
  void setFocus(FocusNode? node) {
    if (_primaryFocus == node) return;

    _primaryFocus?.unfocus();
    _primaryFocus = node;
    _primaryFocus?.requestFocus();
  }

  /// Advances focus to the next focusable node.
  void nextFocus() {
    if (_nodes.isEmpty) return;

    final currentIndex =
        _primaryFocus != null ? _nodes.indexOf(_primaryFocus!) : -1;
    for (var i = 1; i <= _nodes.length; i++) {
      final nextIndex = (currentIndex + i) % _nodes.length;
      final candidate = _nodes[nextIndex];
      if (candidate.canRequestFocus) {
        setFocus(candidate);
        break;
      }
    }
  }

  /// Moves focus backwards to the previous focusable node.
  void previousFocus() {
    if (_nodes.isEmpty) return;

    final currentIndex =
        _primaryFocus != null ? _nodes.indexOf(_primaryFocus!) : 0;
    for (var i = 1; i <= _nodes.length; i++) {
      final prevIndex = (currentIndex - i + _nodes.length) % _nodes.length;
      final candidate = _nodes[prevIndex];
      if (candidate.canRequestFocus) {
        setFocus(candidate);
        break;
      }
    }
  }

  /// Dispatches [event] through the focus tree. Returns true if handled.
  bool dispatchKeyEvent(KeyEvent event) {
    // 1. Let focused node handle it
    if (_primaryFocus != null && _primaryFocus!.handleKeyEvent(event)) {
      return true;
    }

    // 2. Default tab navigation
    if (event.code == KeyCode.tab) {
      if (event.isShift) {
        previousFocus();
      } else {
        nextFocus();
      }
      return true;
    }

    return false;
  }
}
