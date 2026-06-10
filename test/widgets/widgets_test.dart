import 'package:termora/termora.dart';
import 'package:test/test.dart';

void main() {
  group('Button Widget', () {
    test('renders label and executes onPressed when activated by key', () {
      var pressedCount = 0;
      final focusNode = FocusNode();
      final backend = VirtualTerminalBackend(width: 25, height: 3);

      final app = TermoraApp(
        backend: backend,
        child: Button(
          focusNode: focusNode,
          onPressed: () => pressedCount++,
          child: const Text('Submit'),
        ),
      );

      app.focusManager.register(focusNode);
      app.renderFrame();
      expect(app.doubleBuffer.current.toAsciiString(), contains('Submit'));

      // Send Enter key
      app.dispatchKeyEvent(const KeyEvent(code: KeyCode.enter));
      expect(pressedCount, equals(1));

      // Send Space key
      app.dispatchKeyEvent(const KeyEvent(code: KeyCode.space));
      expect(pressedCount, equals(2));
    });
  });

  group('Menu Widget', () {
    test('navigates options with arrow keys and triggers onSelected', () {
      String? selectedValue;
      final focusNode = FocusNode();
      final backend = VirtualTerminalBackend(width: 30, height: 10);

      final app = TermoraApp(
        backend: backend,
        child: Menu<String>(
          title: 'Options',
          focusNode: focusNode,
          items: const [
            MenuItem(value: 'opt1', label: 'Option One'),
            MenuItem(value: 'opt2', label: 'Option Two'),
            MenuItem(value: 'opt3', label: 'Option Three'),
          ],
          onSelected: (val) => selectedValue = val,
        ),
      );

      app.focusManager.register(focusNode);
      app.renderFrame();
      final buffer1 = app.doubleBuffer.current.toAsciiString();
      expect(buffer1, contains('Options'));
      expect(buffer1, contains('Option One'));
      expect(buffer1, contains('► Option One'));

      // Down arrow -> selects Option Two
      app.dispatchKeyEvent(const KeyEvent(code: KeyCode.arrowDown));
      app.renderFrame();
      expect(app.doubleBuffer.current.toAsciiString(), contains('► Option Two'));

      // Press Enter
      app.dispatchKeyEvent(const KeyEvent(code: KeyCode.enter));
      expect(selectedValue, equals('opt2'));

      // Down arrow again -> selects Option Three
      app.dispatchKeyEvent(const KeyEvent(code: KeyCode.arrowDown));
      app.renderFrame();
      expect(app.doubleBuffer.current.toAsciiString(), contains('► Option Three'));
    });
  });

  group('TextField & TextEditingController', () {
    test('updates text and cursor with character inputs and deletions', () {
      final controller = TextEditingController(text: 'Term');
      final focusNode = FocusNode();
      final backend = VirtualTerminalBackend(width: 30, height: 3);
      String? submittedText;

      final app = TermoraApp(
        backend: backend,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onSubmitted: (t) => submittedText = t,
        ),
      );

      app.focusManager.register(focusNode);
      app.renderFrame();
      expect(app.doubleBuffer.current.toAsciiString(), contains('Term'));

      // Append characters 'o', 'r', 'a'
      app.dispatchKeyEvent(const KeyEvent(code: KeyCode.character, character: 'o'));
      app.dispatchKeyEvent(const KeyEvent(code: KeyCode.character, character: 'r'));
      app.dispatchKeyEvent(const KeyEvent(code: KeyCode.character, character: 'a'));
      expect(controller.text, equals('Termora'));

      // Backspace deletes 'a'
      app.dispatchKeyEvent(const KeyEvent(code: KeyCode.backspace));
      expect(controller.text, equals('Termor'));

      // Arrow left moves cursor, then insert 'X'
      app.dispatchKeyEvent(const KeyEvent(code: KeyCode.arrowLeft));
      app.dispatchKeyEvent(const KeyEvent(code: KeyCode.character, character: 'X'));
      expect(controller.text, equals('TermoXr'));

      // Submit
      app.dispatchKeyEvent(const KeyEvent(code: KeyCode.enter));
      expect(submittedText, equals('TermoXr'));
    });
  });

  group('Table Widget', () {
    test('renders formatted headers and table rows with borders', () {
      final backend = VirtualTerminalBackend(width: 40, height: 7);
      final table = Table.fromStrings(
        headers: ['Name', 'Role'],
        data: [
          ['Alice', 'Admin'],
          ['Bob', 'Editor'],
        ],
      );

      final app = TermoraApp(
        backend: backend,
        child: table,
      );

      app.renderFrame();
      final rendered = app.doubleBuffer.current.toAsciiString();

      expect(rendered, contains('Name'));
      expect(rendered, contains('Role'));
      expect(rendered, contains('Alice'));
      expect(rendered, contains('Admin'));
      expect(rendered, contains('Bob'));
      expect(rendered, contains('Editor'));
      expect(rendered, contains('│'));
    });
  });

  group('ProgressBar Widget', () {
    test('calculates filled and empty glyph segments and formats percentage', () {
      final backend = VirtualTerminalBackend(width: 30, height: 1);
      const bar = ProgressBar(
        value: 0.5,
        width: 20,
        showPercentage: true,
      );

      final app = TermoraApp(
        backend: backend,
        child: bar,
      );

      app.renderFrame();
      final rendered = app.doubleBuffer.current.toAsciiString();

      expect(rendered, contains('50%'));
      expect(rendered, contains('█'));
      expect(rendered, contains('░'));
    });
  });
}
