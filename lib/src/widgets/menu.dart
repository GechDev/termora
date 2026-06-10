import '../core/build_context.dart';
import '../core/widget.dart';
import '../input/event.dart';
import '../input/focus_node.dart';
import '../input/key_code.dart';
import '../layout/edge_insets.dart';
import '../layout/flex_layout.dart';
import '../style/border.dart';
import '../style/color.dart';
import '../style/modifier.dart';
import '../style/style.dart';
import 'basic.dart';
import 'container.dart';
import 'flex.dart';
import 'flexible.dart';

/// An individual item in a terminal [Menu].
class MenuItem<T> {
  final T value;
  final String label;
  final bool enabled;

  const MenuItem({
    required this.value,
    required this.label,
    this.enabled = true,
  });
}

/// An interactive vertical list menu navigating with Up/Down arrows and Enter.
class Menu<T> extends StatefulWidget {
  final List<MenuItem<T>> items;
  final void Function(T value)? onSelected;
  final int initialIndex;
  final FocusNode? focusNode;
  final String? title;
  final Border? border;

  const Menu({
    super.key,
    required this.items,
    this.onSelected,
    this.initialIndex = 0,
    this.focusNode,
    this.title,
    this.border,
  });

  @override
  State<Menu<T>> createState() => _MenuState<T>();
}

class _MenuState<T> extends State<Menu<T>> {
  late FocusNode _focusNode;
  bool _internalFocus = false;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex
        .clamp(0, widget.items.isEmpty ? 0 : widget.items.length - 1);
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _internalFocus = true;
    }

    _focusNode.addListener(_handleFocus);
    _focusNode.onKeyEvent = _handleKey;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    if (_internalFocus) _focusNode.dispose();
    super.dispose();
  }

  void _handleFocus() {
    if (mounted) setState(() {});
  }

  bool _handleKey(KeyEvent event) {
    if (widget.items.isEmpty) return false;

    if (event.code == KeyCode.arrowUp) {
      setState(() {
        _selectedIndex =
            (_selectedIndex - 1 + widget.items.length) % widget.items.length;
      });
      return true;
    } else if (event.code == KeyCode.arrowDown) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1) % widget.items.length;
      });
      return true;
    } else if (event.code == KeyCode.enter || event.code == KeyCode.space) {
      final selectedItem = widget.items[_selectedIndex];
      if (selectedItem.enabled && widget.onSelected != null) {
        widget.onSelected!(selectedItem.value);
      }
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final hasFocus = _focusNode.hasFocus;
    final borderColor = hasFocus ? Color.brightCyan : Color.white;

    final itemWidgets = <Widget>[];
    if (widget.title != null) {
      itemWidgets.add(
        Text(
          widget.title!,
          style: const Style(
            foregroundColor: Color.brightYellow,
            modifiers: {TextModifier.bold},
          ),
        ),
      );
      itemWidgets.add(const SizedBox(height: 1));
    }

    for (var i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      final isSelected = i == _selectedIndex;

      final prefix = isSelected ? '► ' : '  ';
      final style = isSelected
          ? const Style(
              foregroundColor: Color.brightCyan,
              modifiers: {TextModifier.bold},
            )
          : (item.enabled
              ? const Style(foregroundColor: Color.white)
              : const Style(
                  foregroundColor: Color.brightBlack,
                  modifiers: {TextModifier.dim},
                ));

      itemWidgets.add(Text('$prefix${item.label}', style: style));
    }

    return Container(
      border: widget.border ??
          Border.rounded(
            Style(foregroundColor: borderColor),
          ),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: itemWidgets,
      ),
    );
  }
}
