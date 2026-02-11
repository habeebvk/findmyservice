class NotificationModel {
  final int? id;
  final String title;
  final String message;
  final String date;
  final String type; // e.g., 'review', 'booking'
  final String recipientName; // Who the notification is for
  bool isRead;

  NotificationModel({
    this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.type,
    required this.recipientName,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'date': date,
      'type': type,
      'recipientName': recipientName,
      'isRead': isRead ? 1 : 0,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      title: map['title'],
      message: map['message'],
      date: map['date'],
      type: map['type'],
      recipientName: map['recipientName'],
      isRead: map['isRead'] == 1,
    );
  }
}
