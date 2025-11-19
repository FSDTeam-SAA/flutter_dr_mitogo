import 'package:casarancha/app/data/models/post_model.dart';
import 'package:get/get.dart';

class Comment {
  String? id;
  String? postId;
  Author? authorId;
  String? content;
  String? clientId;
  bool? isGhostComment;
  RxInt? reactionCount;
  bool? isDeleted;
  bool? isPinned;
  RxInt? replyCount;
  DateTime? createdAt;
  DateTime? updatedAt;
  RxString? reactedEmoji;

  Comment({
    this.id,
    this.postId,
    this.authorId,
    this.content,
    this.isGhostComment,
    this.reactionCount,
    this.isDeleted,
    this.isPinned,
    this.replyCount,
    this.createdAt,
    this.updatedAt,
    this.reactedEmoji,
    this.clientId,
  });

  factory Comment.fromJson(json) {
    return Comment(
      id: json["_id"] ?? "",
      postId: json["postId"] ?? "",
      authorId:
          json["authorId"] != null ? Author.fromJson(json["authorId"]) : null,
      content: json["content"] ?? "",
      isGhostComment: json["isGhostComment"] ?? false,
      reactionCount: RxInt(json["reactionCount"] ?? 0),
      isDeleted: json["isDeleted"] ?? false,
      isPinned: json["isPinned"] ?? false,
      replyCount: RxInt(json["replyCount"] ?? 0),
      createdAt:
          json["createdAt"] != null
              ? DateTime.parse(json["createdAt"] ?? "")
              : null,
      updatedAt:
          json["updatedAt"] != null
              ? DateTime.parse(json["updatedAt"] ?? "")
              : null,
      reactedEmoji: RxString(json["emoji"] ?? ""),
      clientId: json["clientId"] ?? "",
    );
  }

  @override
  String toString() {
    return 'Comment(id: $id, postId: $postId, authorId: $authorId, content: $content, '
        'isGhostComment: $isGhostComment, reactionCount: $reactionCount, isDeleted: $isDeleted, '
        'isPinned: $isPinned, replyCount: $replyCount, createdAt: $createdAt, updatedAt: $updatedAt, reactedEmoji: $reactedEmoji)';
  }
}
