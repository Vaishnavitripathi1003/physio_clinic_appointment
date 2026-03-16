// Helper class for date formatting
class DateFormat {
  final String format;
  const DateFormat._(this.format);

  static DateFormat yMMMd() => const DateFormat._('yMMMd');

  String formats(DateTime date) {
    // Simple implementation for demo purposes
    return '${date.day}/${date.month}/${date.year}';
  }

  static DateFormat Hm() => const DateFormat._('Hm'); // For time

  String formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
