import 'package:get/get.dart';

class NotificationModel {
  final String userId;
  final String id;
  final String type;
  final String message;
  final String? link;
  RxBool isRead = false.obs;
  final DateTime createdAt;

  NotificationModel({
    required this.userId,
    required this.id,
    required this.type,
    required this.message,
    this.link,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      userId: json['userId'] ?? '',
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      link: json['link'],
      isRead: RxBool(json['isRead'] ?? false),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      '_id': id,
      'type': type,
      'message': message,
      'link': link,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
