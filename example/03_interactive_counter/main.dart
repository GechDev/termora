import 'package:termora/termora.dart';

void main() async {
  final focusNode = FocusNode();

  final app = TermoraApp(
    child: Theme(
      data: TermoraThemeData.dark(),
      child: Center(
        child: Container(
          width: 44,
          border: const Border.double(
            Style(foregroundColor: Color.cyan),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          child: Column(
            children: [
              const Text(
                '🎮 Interactive Counter',
                style: Style(
                  foregroundColor: Color.brightCyan,
                  modifiers: {TextModifier.bold},
                ),
              ),
              const SizedBox(height: 1),
              CounterDisplay(focusNode: focusNode),
              const SizedBox(height: 1),
              const Text(
                'Controls: [↑/+] Increment | [↓/-] Decrement | [R] Reset | [Ctrl+C] Exit',
                style: Style(foregroundColor: Color.brightBlack),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  app.focusManager.register(focusNode);
  await app.run();
}

class CounterDisplay extends StatefulWidget {
  final FocusNode focusNode;
  const CounterDisplay({super.key, required this.focusNode});

  @override
  State<CounterDisplay> createState() => _CounterDisplayState();
}

class _CounterDisplayState extends State<CounterDisplay> {
  int _count = 0;

  @override
  void initState() {
    super.initState();
    widget.focusNode.onKeyEvent = (event) {
      if (event.code == KeyCode.arrowUp || event.character == '+') {
        setState(() => _count++);
        return true;
      } else if (event.code == KeyCode.arrowDown || event.character == '-') {
        setState(() => _count--);
        return true;
      } else if (event.character == 'r' || event.character == 'R') {
        setState(() => _count = 0);
        return true;
      }
      return false;
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      border: const Border.rounded(
        Style(foregroundColor: Color.yellow),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      child: Text(
        'Current Value: $_count',
        style: const Style(
          foregroundColor: Color.brightYellow,
          modifiers: {TextModifier.bold},
        ),
      ),
    );
  }
}
