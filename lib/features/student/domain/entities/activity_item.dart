class ActivityItem {
  final int id;
  final String name;
  final DateTime date; // yyyy-MM-dd
  final String dayOfWeek;
  final String startTime; // HH:mm:ss
  final String endTime;   // HH:mm:ss

  ActivityItem({
    required this.id,
    required this.name,
    required this.date,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: (json['id'] ?? 0) is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: (json['name'] ?? '').toString(),
      date: DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
      dayOfWeek: (json['dayOfWeek'] ?? '').toString(),
      startTime: (json['startTime'] ?? '').toString(),
      endTime: (json['endTime'] ?? '').toString(),
    );
  }
}
