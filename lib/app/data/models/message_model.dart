import 'dart:io';

class MessageModel {
  String? id;
  String? senderId;
  String? receiverId;
  String? message;
  String? avater;
  String? messageType;
  String? mediaUrl;
  String? status;
  DateTime? timestamp;
  DateTime? createdAt;
  DateTime? updatedAt;
  File? tempFile;
  String? mediaIv;
  String? clientGeneratedId;
  MessageModel? replyToMessage;
  List<MultipleImages>? multipleImages;
  String? storyMediaUrl;

  MessageModel({
    this.id,
    this.senderId,
    this.receiverId,
    this.replyToMessage,
    this.message,
    this.messageType,
    this.avater,
    this.status,
    this.timestamp,
    this.createdAt,
    this.updatedAt,
    this.mediaUrl,
    this.tempFile,
    this.mediaIv,
    this.clientGeneratedId,
    this.multipleImages,
    this.storyMediaUrl,
  });

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? message,
    String? messageType,
    String? status,
    DateTime? timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? mediaUrl,
    File? tempFile,
    String? mediaIv,
    String? clientGeneratedId,
    MessageModel? replyToMessage,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      messageType: messageType ?? this.messageType,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      tempFile: tempFile ?? this.tempFile,
      mediaIv: mediaIv ?? this.mediaIv,
      clientGeneratedId: clientGeneratedId ?? this.clientGeneratedId,
      replyToMessage: replyToMessage ?? this.replyToMessage,
    );
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json["_id"] ?? "",
      senderId: json["senderId"] ?? "",
      receiverId: json["receiverId"] ?? "",
      message: json["message"] ?? "",
      messageType: json["messageType"] ?? "text",
      mediaUrl: json["mediaUrl"] ?? "",
      status: json["status"] ?? "sent",
      mediaIv: json["mediaIv"] ?? "",
      timestamp: json["timestamp"] != null
          ? DateTime.parse(json["timestamp"])
          : DateTime.now(),
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : DateTime.now(),
      updatedAt: json["updatedAt"] != null
          ? DateTime.parse(json["updatedAt"])
          : DateTime.now(),
      clientGeneratedId: json["clientGeneratedId"] ?? "",
      avater: json["avater"] ?? "",
      replyToMessage: json["replyToMessage"] != null
          ? MessageModel.fromJson(json["replyToMessage"])
          : null,
      multipleImages: json["multipleImages"] != null
          ? List.from(json["multipleImages"])
              .map((e) => MultipleImages.fromJson(e))
              .toList()
          : null,
      storyMediaUrl: json["storyMediaUrl"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    if (id != null) data["_id"] = id;
    if (senderId != null) data["senderId"] = senderId;
    if (receiverId != null) data["receiverId"] = receiverId;
    if (message != null) data["message"] = message;
    if (messageType != null) data["messageType"] = messageType;
    if (mediaUrl != null) data["mediaUrl"] = mediaUrl;
    if (status != null) data["status"] = status;
    if (timestamp != null) data["timestamp"] = timestamp?.toIso8601String();
    if (createdAt != null) data["createdAt"] = createdAt?.toIso8601String();
    if (updatedAt != null) data["updatedAt"] = updatedAt?.toIso8601String();
    if (mediaIv != null) data["mediaIv"] = mediaIv;
    if (clientGeneratedId != null) {
      data["clientGeneratedId"] = clientGeneratedId;
    }
    if (replyToMessage?.id != null) {
      data["replyToMessageId"] = replyToMessage?.id;
    }
    if (multipleImages != null) {
      data["multipleImages"] =
          multipleImages!.map((image) => image.toJson()).toList();
    }
    if (storyMediaUrl != null) {
      data["storyMediaUrl"] = storyMediaUrl;
    }
    return data;
  }

  @override
  String toString() {
    return 'MessageModel('
        'id: $id, '
        'senderId: $senderId, '
        'receiverId: $receiverId, '
        'message: $message, '
        'messageType: $messageType, '
        'mediaUrl: $mediaUrl, '
        'status: $status, '
        'timestamp: $timestamp, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'tempFile: ${tempFile?.path}, '
        'mediaIv: $mediaIv, '
        'clientGeneratedId: $clientGeneratedId, '
        'replyToMessage: ${replyToMessage?.id}'
        'storyMediaUrl: $storyMediaUrl'
        ')';
  }
}

class MultipleImages {
  final String filename;
  final String mimetype;
  final dynamic mediaUrl;
  final String mediaIv;

  MultipleImages({
    required this.filename,
    required this.mimetype,
    required this.mediaUrl,
    required this.mediaIv,
  });

  factory MultipleImages.fromJson(Map<String, dynamic> json) {
    return MultipleImages(
      filename: json["filename"] ?? "",
      mimetype: json["mimetype"] ?? "",
      mediaUrl: json["mediaUrl"] ?? "",
      mediaIv: json["mediaIv"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data["filename"] = filename;
    data["mimetype"] = mimetype;
    data["mediaUrl"] = mediaUrl;
    data["mediaIv"] = mediaIv;
    return data;
  }

  @override
  String toString() {
    return 'MultipleImages('
        'filename: $filename, '
        'mimetype: $mimetype, '
        'mediaUrl: $mediaUrl, '
        'mediaIv: $mediaIv'
        ')';
  }
}
