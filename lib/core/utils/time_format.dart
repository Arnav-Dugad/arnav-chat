import 'package:intl/intl.dart';

abstract final class TimeFormat {
  static bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  /// Chat list timestamp: 14:05 · Yesterday · Mon · 12/03/26
  static String chatList(DateTime t, {DateTime? now}) {
    final n = now ?? DateTime.now();
    if (_sameDay(t, n)) return DateFormat.Hm().format(t);
    if (_sameDay(t, n.subtract(const Duration(days: 1)))) return 'Yesterday';
    if (n.difference(t).inDays < 7) return DateFormat.E().format(t);
    return DateFormat('dd/MM/yy').format(t);
  }

  static String bubble(DateTime t) => DateFormat.Hm().format(t);

  /// Day separator in the conversation: Today · Yesterday · Monday · 12 March 2026
  static String daySeparator(DateTime t, {DateTime? now}) {
    final n = now ?? DateTime.now();
    if (_sameDay(t, n)) return 'Today';
    if (_sameDay(t, n.subtract(const Duration(days: 1)))) return 'Yesterday';
    if (n.difference(t).inDays < 7) return DateFormat.EEEE().format(t);
    return DateFormat('d MMMM y').format(t);
  }

  static bool sameDay(DateTime a, DateTime b) => _sameDay(a, b);

  /// "online" · "last seen 14:05" · "last seen yesterday" · "last seen 12 Mar"
  static String lastSeen(DateTime t, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final diff = n.difference(t);
    if (diff.inMinutes < 1) return 'last seen just now';
    if (diff.inMinutes < 60) return 'last seen ${diff.inMinutes}m ago';
    if (_sameDay(t, n)) return 'last seen ${DateFormat.Hm().format(t)}';
    if (_sameDay(t, n.subtract(const Duration(days: 1)))) return 'last seen yesterday';
    return 'last seen ${DateFormat('d MMM').format(t)}';
  }

  static String duration(Duration d) {
    final m = d.inMinutes.remainder(60).toString();
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:${m.padLeft(2, '0')}:$s' : '$m:$s';
  }
}
