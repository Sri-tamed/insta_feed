/// Formats large numbers to compact form — e.g. 12500 → "12.5K"
/// Mirrors Instagram's like count display style.
class NumberFormatter {
  NumberFormatter._();

  static String compact(int number) {
    if (number >= 1000000) {
      final m = number / 1000000;
      return '${_stripTrailingZero(m.toStringAsFixed(1))}M';
    }
    if (number >= 1000) {
      final k = number / 1000;
      return '${_stripTrailingZero(k.toStringAsFixed(1))}K';
    }
    return number.toString();
  }

  static String _stripTrailingZero(String s) {
    // "12.0K" → "12K", "12.5K" → "12.5K"
    if (s.endsWith('.0')) return s.substring(0, s.length - 2);
    return s;
  }
}
