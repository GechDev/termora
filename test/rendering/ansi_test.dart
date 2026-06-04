import 'package:termora/src/rendering/ansi.dart';
import 'package:test/test.dart';

void main() {
  group('Ansi sequences', () {
    test('screen control sequences', () {
      expect(Ansi.enterAlternateScreen, equals('\x1B[?1049h'));
      expect(Ansi.exitAlternateScreen, equals('\x1B[?1049l'));
      expect(Ansi.clearScreen, equals('\x1B[2J'));
      expect(Ansi.clearLine, equals('\x1B[2K'));
    });

    test('cursor positioning and visibility', () {
      expect(Ansi.hideCursor, equals('\x1B[?25l'));
      expect(Ansi.showCursor, equals('\x1B[?25h'));
      expect(Ansi.moveTo(0, 0), equals('\x1B[1;1H'));
      expect(Ansi.moveTo(10, 5), equals('\x1B[6;11H'));
      expect(Ansi.cursorUp(3), equals('\x1B[3A'));
      expect(Ansi.cursorDown(2), equals('\x1B[2B'));
      expect(Ansi.cursorForward(4), equals('\x1B[4C'));
      expect(Ansi.cursorBack(1), equals('\x1B[1D'));
    });

    test('text attributes and reset', () {
      expect(Ansi.reset, equals('\x1B[0m'));
      expect(Ansi.bold, equals('\x1B[1m'));
      expect(Ansi.dim, equals('\x1B[2m'));
      expect(Ansi.italic, equals('\x1B[3m'));
      expect(Ansi.underline, equals('\x1B[4m'));
      expect(Ansi.invert, equals('\x1B[7m'));
      expect(Ansi.strikethrough, equals('\x1B[9m'));
    });

    test('color generation', () {
      expect(Ansi.fgRed, equals('\x1B[31m'));
      expect(Ansi.bgBlue, equals('\x1B[44m'));
      expect(Ansi.fg256(128), equals('\x1B[38;5;128m'));
      expect(Ansi.bg256(42), equals('\x1B[48;5;42m'));
      expect(Ansi.fgRgb(255, 128, 0), equals('\x1B[38;2;255;128;0m'));
      expect(Ansi.bgRgb(10, 20, 30), equals('\x1B[48;2;10;20;30m'));
    });
  });
}
