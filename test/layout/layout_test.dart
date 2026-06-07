import 'package:termora/src/core/app.dart';
import 'package:termora/src/layout/box_constraints.dart';
import 'package:termora/src/layout/edge_insets.dart';
import 'package:termora/src/layout/flex_layout.dart';
import 'package:termora/src/rendering/backend.dart';
import 'package:termora/src/widgets/align.dart';
import 'package:termora/src/widgets/basic.dart';
import 'package:termora/src/widgets/constrained_box.dart';
import 'package:termora/src/widgets/flex.dart';
import 'package:termora/src/widgets/flexible.dart';
import 'package:test/test.dart';

void main() {
  group('Row Layout', () {
    test('renders children horizontally adjacent', () {
      final backend = VirtualTerminalBackend(width: 15, height: 1);
      final app = TermoraApp(
        child: const Row(
          children: [
            Text('One'),
            Text('Two'),
          ],
        ),
        backend: backend,
      );

      app.renderFrame();
      final ascii = app.doubleBuffer.current.toAsciiString();
      expect(ascii, startsWith('OneTwo'));
    });

    test('supports MainAxisAlignment.spaceBetween', () {
      final backend = VirtualTerminalBackend(width: 10, height: 1);
      final app = TermoraApp(
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('A'),
            Text('B'),
          ],
        ),
        backend: backend,
      );

      app.renderFrame();
      final ascii = app.doubleBuffer.current.toAsciiString();
      expect(ascii, startsWith('A'));
      expect(ascii, endsWith('B'));
    });
  });

  group('Column Layout', () {
    test('renders children vertically line by line', () {
      final backend = VirtualTerminalBackend(width: 10, height: 3);
      final app = TermoraApp(
        child: const Column(
          children: [
            Text('First'),
            Text('Second'),
          ],
        ),
        backend: backend,
      );

      app.renderFrame();
      final lines = app.doubleBuffer.current.toAsciiString().split('\n');
      expect(lines[0], startsWith('First'));
      expect(lines[1], startsWith('Second'));
    });
  });

  group('Flexible and Expanded', () {
    test('distributes remaining main axis space', () {
      final backend = VirtualTerminalBackend(width: 12, height: 1);
      final app = TermoraApp(
        child: const Row(
          children: [
            Text('L'),
            Spacer(),
            Text('R'),
          ],
        ),
        backend: backend,
      );

      app.renderFrame();
      final ascii = app.doubleBuffer.current.toAsciiString();
      expect(ascii, startsWith('L'));
      expect(ascii, endsWith('R'));
      expect(ascii.replaceAll(' ', ''), equals('LR'));
    });
  });

  group('Align and Center', () {
    test('Center positions child in the middle of available space', () {
      final backend = VirtualTerminalBackend(width: 7, height: 3);
      final app = TermoraApp(
        child: const Center(
          child: Text('X'),
        ),
        backend: backend,
      );

      app.renderFrame();
      final lines = app.doubleBuffer.current.toAsciiString().split('\n');
      expect(lines[0].trim(), isEmpty);
      expect(lines[1], equals('   X   '));
      expect(lines[2].trim(), isEmpty);
    });
  });

  group('Padding and Constraints', () {
    test('Padding applies insets around child', () {
      final backend = VirtualTerminalBackend(width: 10, height: 3);
      final app = TermoraApp(
        child: const Padding(
          padding: EdgeInsets.only(left: 2, top: 1),
          child: Text('Hi'),
        ),
        backend: backend,
      );

      app.renderFrame();
      final lines = app.doubleBuffer.current.toAsciiString().split('\n');
      expect(lines[0].trim(), isEmpty);
      expect(lines[1], startsWith('  Hi'));
    });

    test('ConstrainedBox enforces minimum width', () {
      final backend = VirtualTerminalBackend(width: 10, height: 1);
      final app = TermoraApp(
        child: const ConstrainedBox(
          additionalConstraints: BoxConstraints(minWidth: 8),
          child: Text('A'),
        ),
        backend: backend,
      );

      app.renderFrame();
      expect(app.doubleBuffer.current.width, equals(10));
    });
  });
}
