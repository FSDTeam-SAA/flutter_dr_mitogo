class GroupModel {
  final String? id;
  final String? name;
  final String? description;
  final String? avatarUrl;
  final String? ownerUrl;
  final int? postCount;

  GroupModel({
    this.id,
    this.name,
    this.description,
    this.avatarUrl,
    this.ownerUrl,
    this.postCount,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      avatarUrl: json["avatarUrl"] ?? "",
      ownerUrl: json["ownerDetails"]?["avatarUrl"] ?? "",
      postCount: json["postCount"] ?? 0,
    );
  }
}
