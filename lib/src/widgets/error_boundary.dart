import '../core/build_context.dart';
import '../core/widget.dart';
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

/// A widget that catches build errors in its subtree and displays a fallback UI.
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context, Object error, StackTrace? stack)?
      errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stack;

  /// Resets the error boundary to attempt re-rendering the child.
  void reset() {
    setState(() {
      _error = null;
      _stack = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _error!, _stack);
      }

      return Container(
        border: const Border.heavy(
          Style(
            foregroundColor: Color.brightRed,
            modifiers: {TextModifier.bold},
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚠️ An unhandled error occurred in component tree',
              style: Style(
                foregroundColor: Color.brightRed,
                modifiers: {TextModifier.bold},
              ),
            ),
            const SizedBox(height: 1),
            Text(
              '$_error',
              style: const Style(
                foregroundColor: Color.white,
                modifiers: {TextModifier.italic},
              ),
            ),
          ],
        ),
      );
    }

    try {
      return widget.child;
    } catch (e, s) {
      _error = e;
      _stack = s;
      return build(context);
    }
  }
}
