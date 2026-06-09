import 'dart:async';
import 'package:termora/termora.dart';

void main() async {
  final focusNode = FocusNode();

  final app = TermoraApp(
    child: Theme(
      data: TermoraThemeData.dark(),
      child: Center(
        child: Container(
          width: 48,
          border: Border.rounded(
            Style(foregroundColor: ColorPalette.catppuccinMocha.primary),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          child: Column(
            children: [
              const Text(
                '⏱️ Live TUI Stopwatch',
                style: Style(
                  foregroundColor: Color.brightGreen,
                  modifiers: {TextModifier.bold},
                ),
              ),
              const SizedBox(height: 1),
              StopwatchDisplay(focusNode: focusNode),
              const SizedBox(height: 1),
              const Text(
                'Controls: [Space] Start/Pause | [R] Reset | [Ctrl+C] Exit',
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

class StopwatchDisplay extends StatefulWidget {
  final FocusNode focusNode;
  const StopwatchDisplay({super.key, required this.focusNode});

  @override
  State<StopwatchDisplay> createState() => _StopwatchDisplayState();
}

class _StopwatchDisplayState extends State<StopwatchDisplay> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_stopwatch.isRunning && mounted) {
        setState(() {});
      }
    });

    widget.focusNode.onKeyEvent = (event) {
      if (event.code == KeyCode.space) {
        setState(() {
          if (_stopwatch.isRunning) {
            _stopwatch.stop();
          } else {
            _stopwatch.start();
          }
        });
        return true;
      } else if (event.character == 'r' || event.character == 'R') {
        setState(() {
          _stopwatch.reset();
        });
        return true;
      }
      return false;
    };
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  String _formatTime() {
    final ms = _stopwatch.elapsedMilliseconds;
    final hundreds = (ms ~/ 100) % 10;
    final seconds = (ms ~/ 1000) % 60;
    final minutes = (ms ~/ 60000);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.$hundreds';
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = _stopwatch.isRunning;
    final statusColor = isRunning ? Color.green : Color.yellow;
    final statusText = isRunning ? 'RUNNING' : 'PAUSED';

    return Container(
      border: Border.single(Style(foregroundColor: statusColor)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      child: Column(
        children: [
          Text(
            _formatTime(),
            style: const Style(
              foregroundColor: Color.brightWhite,
              modifiers: {TextModifier.bold},
            ),
          ),
          Text(
            statusText,
            style: Style(foregroundColor: statusColor),
          ),
        ],
      ),
    );
  }
}
