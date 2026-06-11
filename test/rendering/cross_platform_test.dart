import 'package:termora/termora.dart';
import 'package:test/test.dart';

// A widget that intentionally throws during build
class FaultyWidget extends StatelessWidget {
  const FaultyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    throw StateError('Simulated component failure');
  }
}

void main() {
  group('Cross-Platform Terminal Compatibility & Edge Cases', () {
    test('handles zero and tiny viewport bounds without crashing', () {
      final backend = VirtualTerminalBackend(width: 2, height: 1);
      final app = TermoraApp(
        backend: backend,
        child: const Text('Very long text exceeding bounds'),
      );

      expect(() => app.renderFrame(), returnsNormally);
      expect(backend.width, equals(2));
      expect(backend.height, equals(1));
    });

    test('renders multi-byte and wide unicode glyphs correctly', () {
      final backend = VirtualTerminalBackend(width: 30, height: 2);
      final app = TermoraApp(
        backend: backend,
        child: const Column(
          children: [
            Text('Hello 日本語 🚀'),
            Text('Accent: e\u0301'),
          ],
        ),
      );

      app.renderFrame();
      final ascii = app.doubleBuffer.current.toAsciiString();
      expect(ascii, contains('日本語'));
      expect(ascii, contains('🚀'));
      expect(ascii, contains('Accent:'));
    });

    test('SingleChildScrollView clips overflowing content and scrolls offset',
        () {
      final backend = VirtualTerminalBackend(width: 20, height: 3);
      final controller = ScrollController();

      final app = TermoraApp(
        backend: backend,
        child: SingleChildScrollView(
          controller: controller,
          showScrollBar: true,
          child: const Column(
            children: [
              Text('Line 1'),
              Text('Line 2'),
              Text('Line 3'),
              Text('Line 4'),
              Text('Line 5'),
            ],
          ),
        ),
      );

      app.renderFrame();
      var output = app.doubleBuffer.current.toAsciiString();
      expect(output, contains('Line 1'));
      expect(output, contains('Line 2'));
      expect(output, isNot(contains('Line 4')));

      // Scroll down
      controller.scrollDown(2);
      app.renderFrame();
      output = app.doubleBuffer.current.toAsciiString();
      expect(output, contains('Line 3'));
      expect(output, contains('Line 4'));
      expect(output, isNot(contains('Line 1')));
    });

    test('ErrorBoundary catches child exceptions and renders error card', () {
      final backend = VirtualTerminalBackend(width: 45, height: 7);
      final app = TermoraApp(
        backend: backend,
        child: const ErrorBoundary(
          child: FaultyWidget(),
        ),
      );

      expect(() => app.renderFrame(), returnsNormally);
      final output = app.doubleBuffer.current.toAsciiString();
      expect(output, contains('unhandled error'));
      expect(output, contains('Simulated component failure'));
    });

    test('dynamically handles window resize and updates buffer dimensions', () {
      final backend = VirtualTerminalBackend(width: 20, height: 4);
      var resizeCallbackFired = false;

      final app = TermoraApp(
        backend: backend,
        child: const Text('Responsive content'),
      );

      app.onResize = (w, h) {
        resizeCallbackFired = true;
      };

      app.renderFrame();
      expect(app.doubleBuffer.width, equals(20));
      expect(app.doubleBuffer.height, equals(4));

      // Trigger resize to 40x8
      app.handleResize(40, 8);
      expect(resizeCallbackFired, isTrue);
      expect(app.doubleBuffer.width, equals(40));
      expect(app.doubleBuffer.height, equals(8));
    });
  });
}
