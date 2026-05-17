class Message {
  final String id;
  final String direction; // user_to_admin | admin_to_user
  final String messageType; // live | static
  final String? subject; // required for static messages
  final String body;
  final String? attachmentUrl;
  final bool isRead;
  final String createdAt; // ISO 8601 format

  Message({
    required this.id,
    required this.direction,
    required this.messageType,
    this.subject,
    required this.body,
    this.attachmentUrl,
    required this.isRead,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      direction: json['direction'] ?? 'user_to_admin',
      messageType: json['message_type'] ?? 'live',
      subject: json['subject'],
      body: json['body'] ?? '',
      attachmentUrl: json['attachment_url'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'direction': direction,
      'message_type': messageType,
      'subject': subject,
      'body': body,
      'attachment_url': attachmentUrl,
      'is_read': isRead,
      'created_at': createdAt,
    };
  }

  bool get isFromUser => direction == 'user_to_admin';
  bool get isFromAdmin => direction == 'admin_to_user';
  bool get isLiveMessage => messageType == 'live' || messageType == 'image';
  bool get isStaticMessage => messageType == 'static';

  DateTime get parsedCreatedAt {
    try {
      return DateTime.parse(createdAt);
    } catch (_) {
      return DateTime.now();
    }
  }
}
