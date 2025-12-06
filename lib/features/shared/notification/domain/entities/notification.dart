class Notification {
  final String id;
  final String recipientId; // <-- Đã thêm
  final String senderId;    // <-- Đã thêm
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String targetUrl;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.recipientId,
    required this.senderId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.targetUrl,
    required this.createdAt,
  });

  // Factory parse JSON
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] ?? '',
      // Backend trả về null thì gán chuỗi rỗng
      recipientId: json['recipientId'] ?? '', 
      senderId: json['senderId'] ?? '',           
      title: json['title'] ?? 'Thông báo',
      message: json['message'] ?? '',
      type: json['type'] ?? 'SYSTEM',
      isRead: json['read'] ?? false,
      targetUrl: json['targetUrl'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  
  Notification copyWith({bool? isRead}) {
    return Notification(
      id: id,
      recipientId: recipientId,
      senderId: senderId,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      targetUrl: targetUrl,
      createdAt: createdAt,
    );
  }
}