import 'package:termora/termora.dart';

void main() async {
  final app = TermoraApp(
    child: Theme(
      data: TermoraThemeData.dark(),
      child: Center(
        child: Container(
          width: 50,
          border: Border.rounded(
            Style(foregroundColor: ColorPalette.nord.primary),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          child: Column(
            children: [
              const RichText(
                text: TextSpan(
                  text: '✨ Termora ',
                  style: Style(
                    foregroundColor: Color.brightCyan,
                    modifiers: {TextModifier.bold},
                  ),
                  children: [
                    TextSpan(
                      text: 'Styling Gallery',
                      style: Style(foregroundColor: Color.brightYellow),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    border: Border.single(
                      Style(foregroundColor: ColorPalette.dracula.success),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: const Text('Dracula'),
                  ),
                  Container(
                    border: Border.double(
                      Style(foregroundColor: ColorPalette.nord.primary),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: const Text('Nord'),
                  ),
                  Container(
                    border: Border.heavy(
                      Style(
                          foregroundColor:
                              ColorPalette.catppuccinMocha.secondary),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: const Text('Mocha'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  app.renderFrame();
}
