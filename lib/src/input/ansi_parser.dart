import 'dart:convert';

import 'event.dart';
import 'key_code.dart';

/// Decodes raw terminal byte streams into structured [KeyEvent]s.
class AnsiInputParser {
  final List<int> _buffer = <int>[];

  /// Parses an incoming chunk of [bytes] and emits any completed [KeyEvent]s.
  List<KeyEvent> parse(List<int> bytes) {
    _buffer.addAll(bytes);
    final events = <KeyEvent>[];

    while (_buffer.isNotEmpty) {
      final first = _buffer[0];

      // Escape sequence start
      if (first == 0x1B) {
        if (_buffer.length == 1) {
          // Solitary escape key
          events.add(const KeyEvent(code: KeyCode.escape));
          _buffer.removeAt(0);
          break;
        }

        final second = _buffer[1];

        // CSI sequence: ESC [
        if (second == 0x5B) {
          final csiEvent = _tryParseCsi();
          if (csiEvent != null) {
            events.add(csiEvent);
            continue;
          } else {
            // Incomplete sequence in buffer: wait for more bytes
            break;
          }
        }

        // SS3 sequence: ESC O (common for F1-F4)
        if (second == 0x4F) {
          if (_buffer.length >= 3) {
            final third = _buffer[2];
            final fKey = _ss3ToKeyCode(third);
            events.add(KeyEvent(code: fKey));
            _buffer.removeRange(0, 3);
            continue;
          } else {
            break;
          }
        }

        // Alt + key (ESC followed by standard key)
        if (_buffer.length >= 2) {
          final char = String.fromCharCode(_buffer[1]);
          events.add(KeyEvent(
            code: KeyCode.character,
            character: char,
            isAlt: true,
          ));
          _buffer.removeRange(0, 2);
          continue;
        }

        break;
      }

      // Control characters (Ctrl + A..Z: 1..26)
      if (first >= 1 && first <= 26 && first != 9 && first != 10 && first != 13) {
        final char = String.fromCharCode(first + 96);
        events.add(KeyEvent(
          code: KeyCode.character,
          character: char,
          isCtrl: true,
        ));
        _buffer.removeAt(0);
        continue;
      }

      // Standard control keys
      switch (first) {
        case 9: // Tab
          events.add(const KeyEvent(code: KeyCode.tab));
          _buffer.removeAt(0);
          continue;
        case 10: // Line Feed
        case 13: // Carriage Return
          events.add(const KeyEvent(code: KeyCode.enter));
          _buffer.removeAt(0);
          continue;
        case 8: // Backspace
        case 127: // DEL / Backspace on unix
          events.add(const KeyEvent(code: KeyCode.backspace));
          _buffer.removeAt(0);
          continue;
        case 32: // Space
          events.add(const KeyEvent(code: KeyCode.space, character: ' '));
          _buffer.removeAt(0);
          continue;
      }

      // Standard UTF-8 characters
      final utf8Result = _tryDecodeUtf8();
      if (utf8Result != null) {
        events.add(KeyEvent.char(utf8Result));
        continue;
      }

      // If cannot decode UTF-8 yet, break and wait for remaining bytes
      break;
    }

    return events;
  }

  KeyEvent? _tryParseCsi() {
    // Find terminating character (between 0x40 and 0x7E)
    var termIndex = -1;
    for (var i = 2; i < _buffer.length; i++) {
      final b = _buffer[i];
      if (b >= 0x40 && b <= 0x7E) {
        termIndex = i;
        break;
      }
    }

    if (termIndex == -1) return null; // Incomplete

    final terminator = String.fromCharCode(_buffer[termIndex]);
    final paramStr = String.fromCharCodes(_buffer.sublist(2, termIndex));
    _buffer.removeRange(0, termIndex + 1);

    switch (terminator) {
      case 'A':
        return const KeyEvent(code: KeyCode.arrowUp);
      case 'B':
        return const KeyEvent(code: KeyCode.arrowDown);
      case 'C':
        return const KeyEvent(code: KeyCode.arrowRight);
      case 'D':
        return const KeyEvent(code: KeyCode.arrowLeft);
      case 'H':
        return const KeyEvent(code: KeyCode.home);
      case 'F':
        return const KeyEvent(code: KeyCode.end);
      case 'Z': // Shift+Tab
        return const KeyEvent(code: KeyCode.tab, isShift: true);
      case '~':
        switch (paramStr) {
          case '1':
          case '7':
            return const KeyEvent(code: KeyCode.home);
          case '2':
            return const KeyEvent(code: KeyCode.insert);
          case '3':
            return const KeyEvent(code: KeyCode.delete);
          case '4':
          case '8':
            return const KeyEvent(code: KeyCode.end);
          case '5':
            return const KeyEvent(code: KeyCode.pageUp);
          case '6':
            return const KeyEvent(code: KeyCode.pageDown);
          case '11':
            return const KeyEvent(code: KeyCode.f1);
          case '12':
            return const KeyEvent(code: KeyCode.f2);
          case '13':
            return const KeyEvent(code: KeyCode.f3);
          case '14':
            return const KeyEvent(code: KeyCode.f4);
          case '15':
            return const KeyEvent(code: KeyCode.f5);
          case '17':
            return const KeyEvent(code: KeyCode.f6);
          case '18':
            return const KeyEvent(code: KeyCode.f7);
          case '19':
            return const KeyEvent(code: KeyCode.f8);
          case '20':
            return const KeyEvent(code: KeyCode.f9);
          case '21':
            return const KeyEvent(code: KeyCode.f10);
          case '23':
            return const KeyEvent(code: KeyCode.f11);
          case '24':
            return const KeyEvent(code: KeyCode.f12);
        }
    }

    return const KeyEvent(code: KeyCode.unknown);
  }

  KeyCode _ss3ToKeyCode(int code) {
    switch (code) {
      case 0x50:
        return KeyCode.f1;
      case 0x51:
        return KeyCode.f2;
      case 0x52:
        return KeyCode.f3;
      case 0x53:
        return KeyCode.f4;
      default:
        return KeyCode.unknown;
    }
  }

  String? _tryDecodeUtf8() {
    final first = _buffer[0];
    int neededBytes;

    if ((first & 0x80) == 0) {
      neededBytes = 1;
    } else if ((first & 0xE0) == 0xC0) {
      neededBytes = 2;
    } else if ((first & 0xF0) == 0xE0) {
      neededBytes = 3;
    } else if ((first & 0xF8) == 0xF0) {
      neededBytes = 4;
    } else {
      // Invalid UTF-8 start byte: drop it
      _buffer.removeAt(0);
      return null;
    }

    if (_buffer.length < neededBytes) return null; // Waiting for more bytes

    try {
      final decoded = utf8.decode(_buffer.sublist(0, neededBytes));
      _buffer.removeRange(0, neededBytes);
      return decoded;
    } catch (_) {
      _buffer.removeAt(0);
      return null;
    }
  }
}
