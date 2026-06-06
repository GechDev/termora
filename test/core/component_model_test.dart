import 'package:termora/src/core/app.dart';
import 'package:termora/src/core/build_context.dart';
import 'package:termora/src/core/element.dart';
import 'package:termora/src/core/widget.dart';
import 'package:termora/src/layout/edge_insets.dart';
import 'package:termora/src/rendering/backend.dart';
import 'package:termora/src/style/border.dart';
import 'package:termora/src/widgets/basic.dart';
import 'package:termora/src/widgets/container.dart';
import 'package:test/test.dart';

// Test Stateless Widget
class Greeter extends StatelessWidget {
  final String name;
  const Greeter(this.name, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text('Hello, $name!');
  }
}

// Test Stateful Widget
class CounterWidget extends StatefulWidget {
  final int initialValue;
  const CounterWidget({super.key, this.initialValue = 0});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  late int count;
  int initCallCount = 0;
  int disposeCallCount = 0;
  int didUpdateCallCount = 0;

  @override
  void initState() {
    super.initState();
    count = widget.initialValue;
    initCallCount++;
  }

  @override
  void didUpdateWidget(covariant CounterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    didUpdateCallCount++;
  }

  @override
  void dispose() {
    disposeCallCount++;
    super.dispose();
  }

  void increment() {
    setState(() {
      count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text('Count: $count');
  }
}

void main() {
  group('StatelessWidget and Composition', () {
    test('renders nested StatelessWidget and Text into buffer', () {
      final backend = VirtualTerminalBackend(width: 20, height: 3);
      final app = TermoraApp(
        child: const Greeter('Alice'),
        backend: backend,
      );

      app.renderFrame();
      final ascii = app.doubleBuffer.current.toAsciiString();
      expect(ascii, contains('Hello, Alice!'));
    });

    test('renders Container with Border and Padding around Text', () {
      final backend = VirtualTerminalBackend(width: 15, height: 3);
      final app = TermoraApp(
        child: const Container(
          border: Border.ascii(),
          padding: EdgeInsets.symmetric(horizontal: 1),
          child: Text('Hi'),
        ),
        backend: backend,
      );

      app.renderFrame();
      final ascii = app.doubleBuffer.current.toAsciiString();
      expect(ascii, contains('+-------------+'));
      expect(ascii, contains('| Hi          |'));
      expect(ascii, contains('+-------------+'));
    });
  });

  group('StatefulWidget Lifecycle', () {
    test('calls initState, setState, and rebuilds element', () {
      final backend = VirtualTerminalBackend(width: 15, height: 2);
      const counter = CounterWidget(initialValue: 5);
      final app = TermoraApp(
        child: counter,
        backend: backend,
      );

      app.renderFrame();
      expect(app.doubleBuffer.current.toAsciiString(), contains('Count: 5'));

      // Find state and increment
      final rootElem = app.rootElement!;
      final statefulElem = rootElem.child! as StatefulElement;
      final state = statefulElem.state as _CounterWidgetState;

      expect(state.initCallCount, equals(1));

      // Trigger setState
      state.increment();
      app.renderFrame();

      expect(app.doubleBuffer.current.toAsciiString(), contains('Count: 6'));
    });
  });
}
