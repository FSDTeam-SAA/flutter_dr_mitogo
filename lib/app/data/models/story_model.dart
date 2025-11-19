class StoryModel {
  final String? id;
  final String? userId;
  final String? avatarUrl;
  final String? displayName;
  final List<Stories>? stories;

  StoryModel({
    this.id,
    this.userId,
    this.avatarUrl,
    this.displayName,
    this.stories,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['_id'] ?? "",
      userId: json['userId'] ?? "",
      displayName: json['displayName'] ?? "",
      avatarUrl: json["avatarUrl"]??"",
      stories:
          json['stories'] != null
              ? List<Stories>.from(
                json['stories'].map((x) => Stories.fromMap(x)),
              )
              : <Stories>[],
    );
  }

  @override
  String toString() {
    return '''
    StoryModel(
    id: $id, 
    userId: $userId, 
    displayName: $displayName,
    avatarUrl: $avatarUrl, 
    stories: $stories
    )''';
  }
}

class Stories {
  final String? content;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? mediaType;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final List<String>? viewedBy;
  final String? id;

  Stories({
    this.content,
    this.mediaUrl,
    this.mediaType,
    this.createdAt,
    this.expiresAt,
    this.viewedBy,
    this.id,
    this.thumbnailUrl,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'content': content ?? "",
      'mediaUrl': mediaUrl ?? "",
      'mediaType': mediaType ?? "",
      'createdAt': createdAt ?? "",
      'expiresAt': expiresAt ?? "",
      'viewedBy': viewedBy ?? [],
      'id': id ?? "",
    };
  }

  factory Stories.fromMap(Map<String, dynamic> map) {
    return Stories(
      content: map['content'] ?? "",
      mediaUrl: map['mediaUrl'] ?? "",
      thumbnailUrl: map['thumbnailUrl'] ?? "",
      mediaType: map['mediaType'] ?? "",
      createdAt:
          map['createdAt'] != null
              ? DateTime.tryParse(map['createdAt'].toString())
              : DateTime.now(),
      expiresAt:
          map['expiresAt'] != null
              ? DateTime.tryParse(map['expiresAt'].toString())
              : DateTime.now(),
      viewedBy:
          map['viewedBy'] != null ? List<String>.from((map['viewedBy'])) : [],
      id: map['id'] ?? "",
    );
  }

  @override
  String toString() {
    return '''
    Stories(
    content: $content, 
    mediaUrl: $mediaUrl, 
    mediaType: $mediaType, 
    createdAt: $createdAt, 
    expiresAt: $expiresAt, 
    viewedBy: $viewedBy, 
    id: $id 
    )''';
  }
}
