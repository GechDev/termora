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
import 'container.dart';

/// An interactive button widget triggered by Enter or Space when focused.
class Button extends StatefulWidget {
  final Widget child;
  final void Function()? onPressed;
  final FocusNode? focusNode;
  final Style? style;
  final Style? focusedStyle;
  final Border? border;
  final Border? focusedBorder;

  const Button({
    super.key,
    required this.child,
    this.onPressed,
    this.focusNode,
    this.style,
    this.focusedStyle,
    this.border,
    this.focusedBorder,
  });

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  late FocusNode _focusNode;
  bool _internalFocusNode = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _internalFocusNode = true;
    }

    _focusNode.addListener(_handleFocusChange);
    _focusNode.onKeyEvent = _handleKeyEvent;
  }

  @override
  void didUpdateWidget(covariant Button oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_handleFocusChange);
      if (_internalFocusNode) {
        _focusNode.dispose();
      }
      if (widget.focusNode != null) {
        _focusNode = widget.focusNode!;
        _internalFocusNode = false;
      } else {
        _focusNode = FocusNode();
        _internalFocusNode = true;
      }
      _focusNode.addListener(_handleFocusChange);
      _focusNode.onKeyEvent = _handleKeyEvent;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_internalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) setState(() {});
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (widget.onPressed != null &&
        (event.code == KeyCode.enter || event.code == KeyCode.space)) {
      widget.onPressed!();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final hasFocus = _focusNode.hasFocus;

    final defaultBorder = widget.border ?? const Border.single();
    final defaultFocusedBorder = widget.focusedBorder ??
        const Border.double(
          Style(
            foregroundColor: Color.brightCyan,
            modifiers: {TextModifier.bold},
          ),
        );

    return Container(
      border: hasFocus ? defaultFocusedBorder : defaultBorder,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
      style: hasFocus
          ? (widget.focusedStyle ??
              const Style(
                foregroundColor: Color.brightCyan,
                modifiers: {TextModifier.bold},
              ))
          : widget.style,
      child: widget.child,
    );
  }
}
