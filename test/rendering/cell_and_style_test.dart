import 'package:termora/src/rendering/cell.dart';
import 'package:termora/src/style/color.dart';
import 'package:termora/src/style/modifier.dart';
import 'package:termora/src/style/style.dart';
import 'package:test/test.dart';

void main() {
  group('Color', () {
    test('named colors produce ANSI foreground and background', () {
      expect(Color.red.toForegroundAnsi(), equals('\x1B[31m'));
      expect(Color.blue.toBackgroundAnsi(), equals('\x1B[44m'));
      expect(Color.brightCyan.toForegroundAnsi(), equals('\x1B[96m'));
    });

    test('ansi256 color produces correct 256-color escapes', () {
      const c = Color.ansi256(200);
      expect(c.toForegroundAnsi(), equals('\x1B[38;5;200m'));
      expect(c.toBackgroundAnsi(), equals('\x1B[48;5;200m'));
    });

    test('rgb color produces 24-bit TrueColor escapes', () {
      const c = Color.rgb(255, 128, 64);
      expect(c.toForegroundAnsi(), equals('\x1B[38;2;255;128;64m'));
      expect(c.toBackgroundAnsi(), equals('\x1B[48;2;255;128;64m'));
    });
  });

  group('Style', () {
    test('empty style produces reset', () {
      expect(Style.none.toAnsi(), equals('\x1B[0m'));
    });

    test('composed style produces combined ANSI sequences', () {
      const style = Style(
        foregroundColor: Color.green,
        backgroundColor: Color.black,
        modifiers: {TextModifier.bold, TextModifier.underline},
      );
      final ansi = style.toAnsi();
      expect(ansi, contains('\x1B[0m'));
      expect(ansi, contains('\x1B[1m'));
      expect(ansi, contains('\x1B[4m'));
      expect(ansi, contains('\x1B[32m'));
      expect(ansi, contains('\x1B[40m'));
    });

    test('style diffing emits minimal delta when adding modifier', () {
      const s1 = Style(foregroundColor: Color.red);
      const s2 =
          Style(foregroundColor: Color.red, modifiers: {TextModifier.bold});
      final delta = s2.diffAnsi(s1);
      expect(delta, equals('\x1B[1m'));
    });

    test('style merge combines attributes', () {
      const base =
          Style(foregroundColor: Color.yellow, modifiers: {TextModifier.bold});
      const override = Style(backgroundColor: Color.blue);
      final merged = base.merge(override);
      expect(merged.foregroundColor, equals(Color.yellow));
      expect(merged.backgroundColor, equals(Color.blue));
      expect(merged.modifiers, contains(TextModifier.bold));
    });
  });

  group('Cell', () {
    test('default cell is blank with width 1', () {
      const cell = Cell.empty;
      expect(cell.character, equals(' '));
      expect(cell.style, equals(Style.none));
      expect(cell.width, equals(1));
      expect(cell.isWideLeading, isFalse);
      expect(cell.isWideTrailing, isFalse);
    });

    test('wide characters leading and trailing cells', () {
      const leading = Cell.char('字', Style.none, 2);
      const trailing = Cell.wideContinuation;
      expect(leading.width, equals(2));
      expect(leading.isWideLeading, isTrue);
      expect(trailing.width, equals(0));
      expect(trailing.isWideTrailing, isTrue);
    });
  });
}
