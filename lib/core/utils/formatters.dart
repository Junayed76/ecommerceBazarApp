/// Small, dependency-free formatting helpers shared by the UI.
class Formatters {
  Formatters._();

  /// `12.5` -> `$12.50`
  static String money(double value) => '\$${value.toStringAsFixed(2)}';

  /// `2026-11-01 09:05`
  static String dateTime(DateTime value) {
    final date =
        '${value.year}-${_two(value.month)}-${_two(value.day)}';
    final time = '${_two(value.hour)}:${_two(value.minute)}';
    return '$date $time';
  }

  /// `electronics` -> `Electronics`
  static String titleCase(String value) {
    if (value.isEmpty) return value;
    return value
        .split(RegExp(r'[\s_-]+'))
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
