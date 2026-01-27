class FomoWindow {
  final String id;
  final String title;
  final String? description;
  final String status;
  final DateTime startTime;
  final DateTime endTime;
  final int postCount;
  final int participantCount;

  FomoWindow({
    required this.id,
    required this.title,
    required this.status,
    required this.startTime,
    required this.endTime,
    this.description,
    this.postCount = 0,
    this.participantCount = 0,
  });

  factory FomoWindow.fromJson(Map<String, dynamic> json) {
    return FomoWindow(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? json['name'] ?? 'FOMO Window',
      description: json['description'],
      status: json['status'] ?? 'active',
      startTime: DateTime.tryParse(json['startTime'] ?? json['start_date'] ?? '') ??
          DateTime.now(),
      endTime: DateTime.tryParse(json['endTime'] ?? json['end_date'] ?? '') ??
          DateTime.now(),
      postCount: json['stats']?['postCount'] ?? json['postCount'] ?? 0,
      participantCount: json['stats']?['participantCount'] ??
          json['participantCount'] ??
          0,
    );
  }
}
