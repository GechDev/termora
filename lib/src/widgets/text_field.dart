import '../core/build_context.dart';
import '../core/widget.dart';
import '../input/event.dart';
import '../input/focus_node.dart';
import '../input/key_code.dart';
import '../layout/edge_insets.dart';
import '../style/border.dart';
import '../style/color.dart';
import '../style/modifier.dart';
import '../style/style.dart';
import 'basic.dart';
import 'container.dart';

/// A controller for an editable text field.
class TextEditingController {
  String _text;
  int _cursorPosition;
  final List<void Function()> _listeners = [];

  TextEditingController({String text = ''})
      : _text = text,
        _cursorPosition = text.length;

  /// The current text value.
  String get text => _text;
  set text(String newText) {
    _text = newText;
    _cursorPosition = _cursorPosition.clamp(0, _text.length);
    _notifyListeners();
  }

  /// Current cursor index within the text string.
  int get cursorPosition => _cursorPosition;
  set cursorPosition(int pos) {
    _cursorPosition = pos.clamp(0, _text.length);
    _notifyListeners();
  }

  /// Clears the text field contents.
  void clear() {
    _text = '';
    _cursorPosition = 0;
    _notifyListeners();
  }

  /// Appends a listener.
  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  /// Removes a listener.
  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in List.of(_listeners)) {
      listener();
    }
  }

  /// Disposes resources.
  void dispose() {
    _listeners.clear();
  }
}

/// An interactive single-line terminal input field.
class TextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final bool obscureText;
  final void Function(String text)? onChanged;
  final void Function(String text)? onSubmitted;
  final Border? border;
  final int? width;

  const TextField({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.border,
    this.width,
  });

  @override
  State<TextField> createState() => _TextFieldState();
}

class _TextFieldState extends State<TextField> {
  late TextEditingController _controller;
  bool _internalController = false;

  late FocusNode _focusNode;
  bool _internalFocus = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _internalController = true;
    }
    _controller.addListener(_handleUpdate);

    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _internalFocus = true;
    }
    _focusNode.addListener(_handleUpdate);
    _focusNode.onKeyEvent = _handleKey;
  }

  @override
  void dispose() {
    _controller.removeListener(_handleUpdate);
    if (_internalController) _controller.dispose();

    _focusNode.removeListener(_handleUpdate);
    if (_internalFocus) _focusNode.dispose();

    super.dispose();
  }

  void _handleUpdate() {
    if (mounted) setState(() {});
  }

  bool _handleKey(KeyEvent event) {
    final text = _controller.text;
    final cursor = _controller.cursorPosition;

    if (event.code == KeyCode.arrowLeft) {
      if (cursor > 0) {
        _controller.cursorPosition = cursor - 1;
      }
      return true;
    } else if (event.code == KeyCode.arrowRight) {
      if (cursor < text.length) {
        _controller.cursorPosition = cursor + 1;
      }
      return true;
    } else if (event.code == KeyCode.home) {
      _controller.cursorPosition = 0;
      return true;
    } else if (event.code == KeyCode.end) {
      _controller.cursorPosition = text.length;
      return true;
    } else if (event.code == KeyCode.backspace) {
      if (cursor > 0) {
        final before = text.substring(0, cursor - 1);
        final after = text.substring(cursor);
        _controller._text = '$before$after';
        _controller._cursorPosition = cursor - 1;
        _controller._notifyListeners();
        widget.onChanged?.call(_controller.text);
      }
      return true;
    } else if (event.code == KeyCode.delete) {
      if (cursor < text.length) {
        final before = text.substring(0, cursor);
        final after = text.substring(cursor + 1);
        _controller._text = '$before$after';
        _controller._notifyListeners();
        widget.onChanged?.call(_controller.text);
      }
      return true;
    } else if (event.code == KeyCode.enter) {
      widget.onSubmitted?.call(_controller.text);
      return true;
    } else if (event.code == KeyCode.character && event.character != null) {
      final ch = event.character!;
      final before = text.substring(0, cursor);
      final after = text.substring(cursor);
      _controller._text = '$before$ch$after';
      _controller._cursorPosition = cursor + ch.length;
      _controller._notifyListeners();
      widget.onChanged?.call(_controller.text);
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final hasFocus = _focusNode.hasFocus;
    final borderColor = hasFocus ? Color.brightCyan : Color.brightBlack;

    final rawText =
        widget.obscureText ? '•' * _controller.text.length : _controller.text;

    Widget content;
    if (rawText.isEmpty && !hasFocus && widget.placeholder != null) {
      content = Text(
        widget.placeholder!,
        style: const Style(
          foregroundColor: Color.brightBlack,
          modifiers: {TextModifier.italic},
        ),
      );
    } else {
      content = Text(
        rawText,
        style: const Style(foregroundColor: Color.white),
      );
    }

    return Container(
      width: widget.width,
      border: widget.border ??
          Border.single(
            Style(foregroundColor: borderColor),
          ),
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: content,
    );
  }
}
