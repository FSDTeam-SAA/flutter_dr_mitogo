class AdCampaign {
  final String id;
  final String name;
  final String contentType; // text | image | video | audio
  final String? contentText;
  final String? mediaUrl;
  final String? linkUrl;
  final String? placement;

  AdCampaign({
    required this.id,
    required this.name,
    required this.contentType,
    this.contentText,
    this.mediaUrl,
    this.linkUrl,
    this.placement,
  });

  factory AdCampaign.fromJson(Map<String, dynamic> json) {
    return AdCampaign(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? 'Ad',
      contentType: json['contentType'] ?? 'text',
      contentText: json['contentText'],
      mediaUrl: json['mediaUrl'],
      linkUrl: json['linkUrl'],
      placement: json['placement'] ?? 'feed',
    );
  }
}
