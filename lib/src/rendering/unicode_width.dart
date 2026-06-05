/// Utility for determining character width in monospace terminal columns.
class UnicodeWidth {
  UnicodeWidth._();

  /// Returns the terminal column width of [char] (0, 1, or 2).
  static int codePointWidth(int codePoint) {
    // Non-printable or control characters
    if (codePoint < 32 || (codePoint >= 0x7F && codePoint < 0xA0)) {
      return 0;
    }

    // Zero-width combining characters and joiners
    if ((codePoint >= 0x0300 &&
            codePoint <= 0x036F) || // Combining Diacritical Marks
        (codePoint >= 0x200B &&
            codePoint <= 0x200F) || // Zero-width spaces & marks
        (codePoint == 0x200D) || // Zero-width joiner
        (codePoint >= 0xFE00 && codePoint <= 0xFE0F)) {
      // Variation selectors
      return 0;
    }

    // Wide character ranges:
    // CJK Radicals, Ideographs, Hangul, Fullwidth Forms
    if ((codePoint >= 0x1100 && codePoint <= 0x115F) || // Hangul Jamo
        (codePoint >= 0x2E80 &&
            codePoint <= 0x9FFF) || // CJK Radicals & Unified Ideographs
        (codePoint >= 0xAC00 && codePoint <= 0xD7AF) || // Hangul Syllables
        (codePoint >= 0xF900 &&
            codePoint <= 0xFAFF) || // CJK Compatibility Ideographs
        (codePoint >= 0xFE10 && codePoint <= 0xFE19) || // Vertical forms
        (codePoint >= 0xFE30 &&
            codePoint <= 0xFE6F) || // CJK Compatibility Forms
        (codePoint >= 0xFF01 &&
            codePoint <= 0xFF60) || // Fullwidth ASCII variants
        (codePoint >= 0xFFE0 &&
            codePoint <= 0xFFE6) || // Fullwidth symbol variants
        (codePoint >= 0x1F300 &&
            codePoint <=
                0x1F64F) || // Miscellaneous Symbols and Pictographs, Emoticons
        (codePoint >= 0x1F680 &&
            codePoint <= 0x1F6FF) || // Transport and Map Symbols
        (codePoint >= 0x1F900 &&
            codePoint <= 0x1F9FF) || // Supplemental Symbols and Pictographs
        (codePoint >= 0x20000 && codePoint <= 0x2FFFD) || // CJK Extensions
        (codePoint >= 0x30000 && codePoint <= 0x3FFFD)) {
      return 2;
    }

    return 1;
  }

  /// Calculates the total visual column width of a string.
  static int stringWidth(String text) {
    if (text.isEmpty) return 0;
    var total = 0;
    for (final rune in text.runes) {
      total += codePointWidth(rune);
    }
    return total;
  }
}
