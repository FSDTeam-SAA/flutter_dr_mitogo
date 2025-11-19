

class ChatListModel {
  String? userId;
  String? displayName;
  String? avatar;
  String? lastMessage;
  int? unreadCount;
  bool? online;

  ChatListModel({
    this.userId,
    this.displayName,
    this.avatar,
    this.lastMessage,
    this.unreadCount,
    this.online,
  });

  factory ChatListModel.fromJson(Map<String, dynamic> json) {
    return ChatListModel(
      userId: json["userId"] ?? "",
      displayName: json["fullName"] ?? "",
      avatar: json["avatar"] ?? "",
      lastMessage: json["lastMessage"] ?? "",
      unreadCount: json["unreadCount"] ?? 0,
      online: json["online"] ?? false,
    );
  }
}
