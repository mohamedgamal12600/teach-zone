// price_formatter.dart
// Centralized utility for formatting prices with thousand separators and EGP currency.

class PriceFormatter {
  PriceFormatter._();

  /// Formats a numeric value with comma separators (e.g., 27800 -> "27,800").
  static String format(num value) {
    final s = value.toStringAsFixed(0);
    final buf = StringBuffer();
    final len = s.length;
    for (var i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  /// Formats a price with "EGP" prefix (e.g., 27800 -> "EGP 27,800").
  static String formatWithCurrency(num value) {
    return 'EGP ${format(value)}';
  }
}
