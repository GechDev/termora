import 'package:termora/termora.dart';
import 'package:test/test.dart';

void main() {
  group('Termora Foundation', () {
    test('exports package version', () {
      expect(termoraVersion, equals('0.1.0'));
    });
  });
}
