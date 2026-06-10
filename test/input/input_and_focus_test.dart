import 'package:termora/src/core/app.dart';
import 'package:termora/src/core/build_context.dart';
import 'package:termora/src/core/widget.dart';
import 'package:termora/src/input/ansi_parser.dart';
import 'package:termora/src/input/event.dart';
import 'package:termora/src/input/focus_manager.dart';
import 'package:termora/src/input/focus_node.dart';
import 'package:termora/src/input/key_code.dart';
import 'package:termora/src/rendering/backend.dart';
import 'package:termora/src/widgets/basic.dart';
import 'package:test/test.dart';

class InteractiveTestWidget extends StatefulWidget {
  final FocusNode focusNode;
  const InteractiveTestWidget({super.key, required this.focusNode});

  @override
  State<InteractiveTestWidget> createState() => _InteractiveTestWidgetState();
}

class _InteractiveTestWidgetState extends State<InteractiveTestWidget> {
  int value = 0;

  @override
  void initState() {
    super.initState();
    widget.focusNode.onKeyEvent = (event) {
      if (event.code == KeyCode.arrowUp) {
        setState(() {
          value++;
        });
        return true;
      }
      return false;
    };
  }

  @override
  Widget build(BuildContext context) {
    return Text('Val: $value');
  }
}

void main() {
  group('AnsiInputParser', () {
    test('parses basic printable ASCII and UTF-8 characters', () {
      final parser = AnsiInputParser();
      final events = parser.parse([65, 66]); // 'AB'
      expect(events, hasLength(2));
      expect(events[0].character, equals('A'));
      expect(events[1].character, equals('B'));
    });

    test('parses arrow keys escape sequences', () {
      final parser = AnsiInputParser();
      final up = parser.parse([0x1B, 0x5B, 0x41]); // ESC [ A
      final down = parser.parse([0x1B, 0x5B, 0x42]); // ESC [ B

      expect(up.first.code, equals(KeyCode.arrowUp));
      expect(down.first.code, equals(KeyCode.arrowDown));
    });

    test('parses Enter, Tab, and Backspace', () {
      final parser = AnsiInputParser();
      expect(parser.parse([10]).first.code, equals(KeyCode.enter));
      expect(parser.parse([9]).first.code, equals(KeyCode.tab));
      expect(parser.parse([127]).first.code, equals(KeyCode.backspace));
    });

    test('parses Ctrl combinations', () {
      final parser = AnsiInputParser();
      final ctrlA = parser.parse([1]);
      expect(ctrlA.first.isCtrl, isTrue);
      expect(ctrlA.first.character, equals('a'));
    });
  });

  group('FocusNode and FocusManager', () {
    test('cycles focus across registered nodes with Tab and Shift+Tab', () {
      final manager = FocusManager();
      final node1 = FocusNode();
      final node2 = FocusNode();

      manager.register(node1);
      manager.register(node2);

      expect(node1.hasFocus, isTrue);
      expect(node2.hasFocus, isFalse);

      // Press Tab -> node2
      manager.dispatchKeyEvent(const KeyEvent(code: KeyCode.tab));
      expect(node1.hasFocus, isFalse);
      expect(node2.hasFocus, isTrue);

      // Press Shift+Tab -> node1
      manager
          .dispatchKeyEvent(const KeyEvent(code: KeyCode.tab, isShift: true));
      expect(node1.hasFocus, isTrue);
      expect(node2.hasFocus, isFalse);
    });
  });

  group('TermoraApp Key Dispatch', () {
    test('routes key events to focused stateful widget and updates rendering',
        () {
      final backend = VirtualTerminalBackend(width: 15, height: 1);
      final focusNode = FocusNode();
      final app = TermoraApp(
        child: InteractiveTestWidget(focusNode: focusNode),
        backend: backend,
      );

      app.focusManager.register(focusNode);
      app.renderFrame();
      expect(app.doubleBuffer.current.toAsciiString(), contains('Val: 0'));

      // Dispatch Arrow Up
      app.dispatchKeyEvent(const KeyEvent(code: KeyCode.arrowUp));
      expect(app.doubleBuffer.current.toAsciiString(), contains('Val: 1'));
    });
  });
}
