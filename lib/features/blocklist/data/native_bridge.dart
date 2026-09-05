final class DayStats {
  final String date;
  final int minutes;
  final int items;

  const DayStats({required this.date, required this.minutes, required this.items});

  factory DayStats.fromMap(Map<Object?, Object?> map) {
    return DayStats(
      date: map['date'] as String? ?? '',
      minutes: map['minutes'] as int? ?? 0,
      items: map['items'] as int? ?? 0,
    );
  }
}

abstract interface class NativeBridge {
  Future<List<DayStats>> getStats();
}
