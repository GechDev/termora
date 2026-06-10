import 'package:termora/src/core/app.dart';
import 'package:termora/src/core/build_context.dart';
import 'package:termora/src/core/widget.dart';
import 'package:termora/src/rendering/backend.dart';
import 'package:termora/src/style/border.dart';
import 'package:termora/src/style/color.dart';
import 'package:termora/src/style/modifier.dart';
import 'package:termora/src/style/palette.dart';
import 'package:termora/src/style/style.dart';
import 'package:termora/src/style/theme.dart';
import 'package:termora/src/widgets/basic.dart';
import 'package:termora/src/widgets/container.dart';
import 'package:termora/src/widgets/rich_text.dart';
import 'package:test/test.dart';

class ThemedCard extends StatelessWidget {
  const ThemedCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      border: theme.defaultBorder,
      child: Text('Themed Text',
          style: Style(foregroundColor: theme.primaryColor)),
    );
  }
}

void main() {
  group('Theme Propagation', () {
    test('descendant widgets access ambient Theme properties', () {
      final backend = VirtualTerminalBackend(width: 20, height: 3);
      final customTheme = TermoraThemeData.matrix();

      final app = TermoraApp(
        child: Theme(
          data: customTheme,
          child: const ThemedCard(),
        ),
        backend: backend,
      );

      app.renderFrame();
      final ascii = app.doubleBuffer.current.toAsciiString();
      expect(ascii, contains('Themed Text'));

      // Verify the rendered style used matrix primaryColor (brightGreen)
      final cell = app.doubleBuffer.current.get(1, 1);
      expect(cell.style.foregroundColor, equals(Color.brightGreen));
    });
  });

  group('RichText and TextSpan', () {
    test('renders multi-styled spans on the same line', () {
      final backend = VirtualTerminalBackend(width: 25, height: 1);
      final app = TermoraApp(
        child: const RichText(
          text: TextSpan(
            text: 'Hello ',
            style: Style(foregroundColor: Color.red),
            children: [
              TextSpan(
                text: 'Termora',
                style: Style(
                  foregroundColor: Color.cyan,
                  modifiers: {TextModifier.bold},
                ),
              ),
              TextSpan(
                text: '!',
                style: Style(foregroundColor: Color.yellow),
              ),
            ],
          ),
        ),
        backend: backend,
      );

      app.renderFrame();
      final buffer = app.doubleBuffer.current;
      expect(buffer.toAsciiString(), startsWith('Hello Termora!'));

      // Check styles of individual characters
      expect(buffer.get(0, 0).style.foregroundColor, equals(Color.red));
      expect(buffer.get(6, 0).style.foregroundColor, equals(Color.cyan));
      expect(buffer.get(6, 0).style.modifiers, contains(TextModifier.bold));
      expect(buffer.get(13, 0).style.foregroundColor, equals(Color.yellow));
    });
  });

  group('ColorPalette', () {
    test('presets have distinct contrast colors', () {
      expect(ColorPalette.nord.primary, isA<RgbColor>());
      expect(ColorPalette.dracula.name, equals('Dracula'));
      expect(ColorPalette.catppuccinMocha.surface, isA<RgbColor>());
    });
  });

  group('Border Presets', () {
    test('heavy and double borders have valid box glyphs', () {
      expect(BorderChars.heavy.topLeft, equals('┏'));
      expect(BorderChars.double.topLeft, equals('╔'));
      expect(BorderChars.dotted.horizontal, equals('╌'));
      expect(BorderChars.dashed.horizontal, equals('╍'));
    });
  });
}
