import 'package:termora/src/rendering/backend.dart';
import 'package:termora/src/rendering/cell.dart';
import 'package:termora/src/rendering/double_buffer.dart';
import 'package:termora/src/style/color.dart';
import 'package:termora/src/style/style.dart';
import 'package:test/test.dart';

void main() {
  group('DoubleBuffer Diffing & Rendering', () {
    test('initial render writes all cells and flushes', () {
      final backend = VirtualTerminalBackend(width: 5, height: 2);
      final doubleBuffer = DoubleBuffer(5, 2);

      doubleBuffer.current.writeString(0, 0, 'Hi');
      doubleBuffer.render(backend);

      expect(backend.outputText, contains('Hi'));
      expect(
          backend.outputText, contains('\x1B[1;1H')); // cursor home / position
    });

    test('identical frame produces zero output (diff optimization)', () {
      final backend = VirtualTerminalBackend(width: 5, height: 2);
      final doubleBuffer = DoubleBuffer(5, 2);

      doubleBuffer.current.writeString(0, 0, 'Hi');
      doubleBuffer.render(backend);

      backend.clearOutput();

      // Render again without modifications
      doubleBuffer.render(backend);
      expect(backend.outputText, isEmpty);
    });

    test('delta update emits only modified cell', () {
      final backend = VirtualTerminalBackend(width: 5, height: 1);
      final doubleBuffer = DoubleBuffer(5, 1);

      doubleBuffer.current.writeString(0, 0, 'Hello');
      doubleBuffer.render(backend);

      backend.clearOutput();

      // Modify only index 1 ('e' -> 'a')
      doubleBuffer.current.set(1, 0, const Cell.char('a'));
      doubleBuffer.render(backend);

      // Should move cursor to (1, 0) -> \x1B[1;2H and write 'a'
      expect(backend.outputText, equals('\x1B[1;2Ha'));
    });

    test('applies styling and resets when finished', () {
      final backend = VirtualTerminalBackend(width: 4, height: 1);
      final doubleBuffer = DoubleBuffer(4, 1);

      doubleBuffer.current.writeString(
        0,
        0,
        'Go',
        const Style(foregroundColor: Color.green),
      );
      doubleBuffer.render(backend);

      expect(backend.outputText, contains('\x1B[32m')); // fg green
      expect(backend.outputText, contains('\x1B[0m')); // final reset
    });

    test('resizing marks buffer for full redraw', () {
      final backend = VirtualTerminalBackend(width: 3, height: 1);
      final doubleBuffer = DoubleBuffer(3, 1);

      doubleBuffer.current.writeString(0, 0, 'Cat');
      doubleBuffer.render(backend);

      backend.clearOutput();

      // Resize
      doubleBuffer.resize(4, 1);
      doubleBuffer.render(backend);

      expect(backend.outputText, isNotEmpty);
      expect(backend.outputText, contains('Cat'));
    });
  });

  group('VirtualTerminalBackend Lifecycle', () {
    test('tracks screen and cursor state accurately', () {
      final backend = VirtualTerminalBackend(width: 80, height: 24);
      expect(backend.isRawMode, isFalse);
      expect(backend.isAlternateScreen, isFalse);
      expect(backend.isCursorVisible, isTrue);

      backend.enterAlternateScreen();
      backend.hideCursor();
      backend.enableRawMode();

      expect(backend.isAlternateScreen, isTrue);
      expect(backend.isCursorVisible, isFalse);
      expect(backend.isRawMode, isTrue);

      backend.showCursor();
      backend.exitAlternateScreen();
      backend.disableRawMode();

      expect(backend.isCursorVisible, isTrue);
      expect(backend.isAlternateScreen, isFalse);
      expect(backend.isRawMode, isFalse);
    });

    test('simulates input stream', () async {
      final backend = VirtualTerminalBackend();
      final received = <List<int>>[];
      final sub = backend.input.listen(received.add);

      backend.simulateInput([65, 66]); // 'AB'
      await Future<void>.delayed(Duration.zero);

      expect(received, hasLength(1));
      expect(received.first, equals([65, 66]));

      await sub.cancel();
      backend.dispose();
    });
  });
}
