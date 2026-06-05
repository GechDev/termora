import 'package:termora/src/rendering/cell.dart';
import 'package:termora/src/rendering/screen_buffer.dart';
import 'package:termora/src/rendering/unicode_width.dart';
import 'package:test/test.dart';

void main() {
  group('UnicodeWidth', () {
    test('standard ASCII characters have width 1', () {
      expect(UnicodeWidth.stringWidth('Hello, World!'), equals(13));
    });

    test('wide characters (CJK and Emoji) have width 2', () {
      expect(UnicodeWidth.codePointWidth('字'.runes.first), equals(2));
      expect(UnicodeWidth.stringWidth('你好'), equals(4));
    });
  });

  group('ScreenBuffer', () {
    test('initializes empty buffer with specified dimensions', () {
      final buffer = ScreenBuffer(10, 5);
      expect(buffer.width, equals(10));
      expect(buffer.height, equals(5));
      expect(buffer.get(0, 0), equals(Cell.empty));
      expect(buffer.get(9, 4), equals(Cell.empty));
    });

    test('out of bounds accesses are safely clamped/handled', () {
      final buffer = ScreenBuffer(5, 5);
      expect(buffer.get(-1, 0), equals(Cell.empty));
      expect(buffer.get(10, 10), equals(Cell.empty));
      // Writing out of bounds should not throw
      buffer.set(-1, -1, const Cell.char('X'));
      buffer.set(100, 100, const Cell.char('X'));
    });

    test('writeString writes ASCII text properly', () {
      final buffer = ScreenBuffer(10, 2);
      final written = buffer.writeString(1, 0, 'Termora');
      expect(written, equals(7));
      expect(buffer.get(0, 0).character, equals(' '));
      expect(buffer.get(1, 0).character, equals('T'));
      expect(buffer.get(7, 0).character, equals('a'));
      expect(buffer.get(8, 0).character, equals(' '));
    });

    test('writeString handles wide characters and continuation cells', () {
      final buffer = ScreenBuffer(6, 1);
      buffer.writeString(0, 0, '你好');
      expect(buffer.get(0, 0).character, equals('你'));
      expect(buffer.get(0, 0).width, equals(2));
      expect(buffer.get(1, 0).width, equals(0)); // continuation cell
      expect(buffer.get(2, 0).character, equals('好'));
      expect(buffer.get(2, 0).width, equals(2));
      expect(buffer.get(3, 0).width, equals(0));
    });

    test('writeString clips at buffer boundary', () {
      final buffer = ScreenBuffer(5, 1);
      final written = buffer.writeString(0, 0, 'LongTextHere');
      expect(written, equals(5));
      expect(buffer.toAsciiString(), equals('LongT'));
    });

    test('fill fills rectangular region', () {
      final buffer = ScreenBuffer(4, 3);
      buffer.fill(1, 1, 2, 2, const Cell.char('#'));
      const expected = '    \n'
          ' ## \n'
          ' ## ';
      expect(buffer.toAsciiString(), equals(expected));
    });

    test('blit copies one buffer into another', () {
      final target = ScreenBuffer(6, 3);
      final source = ScreenBuffer(3, 2, initialCell: const Cell.char('*'));
      target.blit(source, destX: 2, destY: 1);
      const expected = '      \n'
          '  *** \n'
          '  *** ';
      expect(target.toAsciiString(), equals(expected));
    });

    test('resize creates new buffer preserving overlapping region', () {
      final original = ScreenBuffer(3, 2, initialCell: const Cell.char('A'));
      final resized = original.resize(4, 3);
      expect(resized.width, equals(4));
      expect(resized.height, equals(3));
      expect(resized.get(0, 0).character, equals('A'));
      expect(resized.get(2, 1).character, equals('A'));
      expect(resized.get(3, 0).character, equals(' '));
    });
  });
}
