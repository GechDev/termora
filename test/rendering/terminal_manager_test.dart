import 'package:termora/src/rendering/backend.dart';
import 'package:termora/src/rendering/terminal_manager.dart';
import 'package:test/test.dart';

void main() {
  group('TerminalManager Lifecycle', () {
    test('initializes and restores virtual terminal safely', () {
      final backend = VirtualTerminalBackend();
      final manager = TerminalManager(backend: backend);

      expect(manager.isInitialized, isFalse);
      expect(backend.isAlternateScreen, isFalse);
      expect(backend.isRawMode, isFalse);

      manager.initialize();
      expect(manager.isInitialized, isTrue);
      expect(backend.isAlternateScreen, isTrue);
      expect(backend.isRawMode, isTrue);
      expect(backend.isCursorVisible, isFalse);

      manager.restore();
      expect(manager.isInitialized, isFalse);
      expect(backend.isAlternateScreen, isFalse);
      expect(backend.isRawMode, isFalse);
      expect(backend.isCursorVisible, isTrue);
    });

    test('runSafe guarantees cleanup even if exception occurs', () async {
      final backend = VirtualTerminalBackend();
      final manager = TerminalManager(backend: backend);

      expect(
        () => manager.runSafe<void>(() {
          expect(manager.isInitialized, isTrue);
          throw Exception('Fatal error during execution');
        }),
        throwsA(isA<Exception>()),
      );

      // Terminal should be restored
      expect(manager.isInitialized, isFalse);
      expect(backend.isAlternateScreen, isFalse);
      expect(backend.isCursorVisible, isTrue);
    });
  });
}
