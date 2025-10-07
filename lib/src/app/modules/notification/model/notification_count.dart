class NotificationCount {
  final int total;
  final int read;
  final int unread;

  NotificationCount({
    required this.total,
    required this.read,
    required this.unread,
  });

  factory NotificationCount.fromJson(Map<String, dynamic> json) => NotificationCount(
      total: json['total_notifications'] ?? 0,
      read: json['read_notifications'] ?? 0,
      unread: json['unread_notifications'] ?? 0,
    );
}
