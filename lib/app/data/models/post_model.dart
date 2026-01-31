import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:casarancha/app/data/models/verification_badge_model.dart';

class PostModel {
  final String? id;
  final Content? content;
  final List<Media>? media;
  Author? author;
  final Stats? stats;
  final Visibility? visibility;
  final GhostMode? ghostMode;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final RxString? reactedEmoji;
  final List? repostChain;
  final int? repostDepth;
  RxBool? isBookmarked;
  final bool? isExplicitContent;
  final bool? ageRestrictedContent;
  Location? location;
  final Poll? poll;
  final List<String>? customHashtags;
  final List<String>? mentionedUserIds;
  final bool? allowComments;
  final bool? showPostTime;
  final bool? allowSharing;
  final bool? allowReposting;
  final bool? hideFromTimeline;
  bool? applyFomo;

  final String? postType;
  final bool? showVerificationBadge;

  final String? originalPostId;
  final String? repostComment;

  final String? groupId;
  final String? groupName;

  final PostModel? originalPost;
  final bool? isDeleted;

  final RxBool isExpanded = false.obs;

  PostModel({
    this.id,
    this.content,
    this.media,
    this.author,
    this.stats,
    this.visibility,
    this.ghostMode,
    this.createdAt,
    this.updatedAt,
    this.reactedEmoji,
    this.repostChain,
    this.repostDepth,
    this.isBookmarked,
    this.isExplicitContent,
    this.ageRestrictedContent,
    this.location,
    this.poll,
    this.customHashtags,
    this.mentionedUserIds,

    this.allowComments = true,
    this.showPostTime = true,
    this.allowSharing = true,
    this.allowReposting = true,
    this.hideFromTimeline = false,
    this.applyFomo = true,

    this.postType = "regular",
    this.showVerificationBadge = false,
    this.originalPostId,
    this.repostComment,

    this.groupId,
    this.originalPost,
    this.groupName,

    this.isDeleted,
  });

  factory PostModel.fromJson(json) {
    return PostModel(
      id: json['id'] ?? "",
      content:
          json['content'] != null ? Content.fromJson(json['content']) : null,
      media:
          json['media'] != null
              ? (json['media'] as List).map((e) => Media.fromJson(e)).toList()
              : [],
      author: json['author'] != null ? Author.fromJson(json['author']) : null,
      stats: json['stats'] != null ? Stats.fromJson(json['stats']) : null,
      postType: json['postType'] ?? "regular",
      visibility:
          json['visibility'] != null
              ? Visibility.fromJson(json['visibility'])
              : null,
      ghostMode:
          json['ghostMode'] != null
              ? GhostMode.fromJson(json['ghostMode'])
              : null,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
      reactedEmoji: RxString(json['reactedEmoji'] ?? ""),
      repostChain:
          json['repostChain'] != null
              ? List<dynamic>.from(json['repostChain'])
              : null,
      repostDepth: json['repostDepth'] ?? 0,
      isBookmarked: RxBool(json['isBookmarked'] ?? false),
      isExplicitContent: json['isExplicitContent'] ?? false,
      ageRestrictedContent: json['ageRestrictedContent'] ?? false,
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
      poll: json['poll'] != null ? Poll.fromJson(json['poll']) : null,
      originalPost:
          json['originalPost'] != null
              ? PostModel.fromJson(json['originalPost'])
              : null,
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (content != null) {
      data['text'] = content?.text;
    }
    if (customHashtags != null) {
      data['customHashtags'] = customHashtags;
    }
    if (mentionedUserIds != null) {
      data['mentionedUserIds'] = mentionedUserIds;
    }
    if (visibility != null) {
      data['visibilityType'] =
          visibility?.type; //public,followers,private,ghost,confession,or group
    }
    data['allowComments'] = allowComments;
    data['showPostTime'] = showPostTime;
    data['allowSharing'] = allowSharing;
    data['allowReposting'] = allowReposting;
    data['hideFromTimeline'] = hideFromTimeline;
    if (applyFomo != null) {
      data['applyFomo'] = applyFomo;
    }

    data['showVerificationBadge'] = showVerificationBadge;
    data['postType'] = postType; //ghost,confession,regular,repost

    if (originalPostId != null) {
      data['originalPostId'] = originalPostId;
    }
    if (repostComment != null) {
      data['repostComment'] = repostComment;
    }

    if (groupId != null) {
      data['groupId'] = groupId;
    }
    if (poll != null) {
      data['poll'] = poll?.toJson();
    }
    if (location != null) {
      data['location'] = location?.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return 'PostModel(id: $id, content: $content, media: $media, author: $author, stats: $stats, visibility: $visibility, ghostMode: $ghostMode, createdAt: $createdAt, updatedAt: $updatedAt, reactedEmoji: $reactedEmoji, repostChain: $repostChain, repostDepth: $repostDepth, isBookmarked: $isBookmarked, isExplicitContent: $isExplicitContent, ageRestrictedContent: $ageRestrictedContent)';
  }
}

class Content {
  final String? text;
  final Formatting? formatting;

  Content({this.text, this.formatting});

  Map<String, dynamic> toJson() {
    return {'text': text};
  }

  factory Content.fromJson(json) {
    return Content(
      text: json['text'],
      formatting:
          json['formatting'] != null
              ? Formatting.fromJson(json['formatting'])
              : Formatting(),
    );
  }
}

class Formatting {
  final String? alignment;
  final bool? isBold;
  final String? font;

  Formatting({this.alignment, this.isBold, this.font});

  factory Formatting.fromJson(json) {
    return Formatting(
      alignment: json['alignment'] ?? "",
      isBold: json['isBold'] ?? false,
      font: json['font'] ?? "",
    );
  }
}

class Media {
  final String? type; // "image" | "video" | "audio"
  final String? url;
  final String? thumbnailUrl;
  final double? duration; // seconds
  final int? size; // bytes
  final Dimensions? dimensions;
  final Metadata? metadata;

  Media({
    this.type,
    this.url,
    this.thumbnailUrl,
    this.duration,
    this.size,
    this.dimensions,
    this.metadata,
  });

  factory Media.fromJson(json) {
    return Media(
      type: json['type'] ?? "",
      url: json['url'] ?? "",
      thumbnailUrl: json['thumbnailUrl'] ?? "",
      duration:
          (json['duration'] != null)
              ? (json['duration'] as num).toDouble()
              : null,
      size: json['size'] ?? 0,
      dimensions:
          json['dimensions'] != null
              ? Dimensions.fromJson(json['dimensions'])
              : null,
      metadata:
          json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null,
    );
  }
}

class Dimensions {
  final int width;
  final int height;

  Dimensions({required this.width, required this.height});

  factory Dimensions.fromJson(Map<String, dynamic> json) {
    return Dimensions(
      width: json['width'] as int,
      height: json['height'] as int,
    );
  }
}

class Metadata {
  final String? format;
  final String? quality;
  final bool? isProcessed;

  Metadata({this.format, this.quality, this.isProcessed});

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      format: json['format'] as String?,
      quality: json['quality'] as String?,
      isProcessed: json['isProcessed'] as bool?,
    );
  }
}

class Author {
  final String? id;
  final String? anonymousId;
  final String? username;
  final String? avatarUrl;
  final bool? isVerified;
  final String? level;
  final String? displayName;
  final String? education;
  final String? work;
  final VerificationBadges? verificationBadges;

  Author({
    this.id,
    this.anonymousId,
    this.username,
    this.avatarUrl,
    this.isVerified,
    this.level,
    this.displayName,
    this.education,
    this.work,
    this.verificationBadges,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'] ?? json['_id'],
      anonymousId: json['anonymousId'] ?? "",
      username: json['username'] ?? "",
      avatarUrl: json['avatarUrl'] ?? "",
      isVerified: json['isVerified'] ?? false,
      level: json['level'] ?? "",
      displayName: json['displayName'] ?? "",
      education: json['education'] ?? "",
      work: json['work'] ?? "",
      verificationBadges: VerificationBadges.fromJson(json['verificationBadges']),
    );
  }

  @override
  String toString() {
    return 'Author(id: $id, anonymousId: $anonymousId, username: $username, avatarUrl: $avatarUrl, isVerified: $isVerified, level: $level, displayName: $displayName)';
  }
}

class Stats {
  final RxInt? reactionCount;
  final RxInt? comments;
  final int? reposts;
  final int? shares;
  final RxInt? views;
  final int? saves;

  Stats({
    this.reactionCount,
    this.comments,
    this.reposts,
    this.shares,
    this.views,
    this.saves,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      reactionCount: RxInt(json['reactionCount'] ?? 0),
      comments: RxInt(json['comments'] ?? 0),
      reposts: json['reposts'] ?? 0,
      shares: json['shares'] ?? 0,
      views: RxInt(json['views'] ?? 0),
      saves: json['saves'] ?? 0,
    );
  }
}

class Visibility {
  String? type;
  final bool? allowComments;
  final bool? showPostTime;
  final bool? allowSharing;
  final bool? allowReposting;
  final bool? hideFromTimeline;
  final List<String>? restrictedAgeGroups;

  Visibility({
    this.type,
    this.allowComments,
    this.showPostTime,
    this.allowSharing,
    this.allowReposting,
    this.hideFromTimeline,
    this.restrictedAgeGroups,
  });

  factory Visibility.fromJson(Map<String, dynamic> json) {
    return Visibility(
      type: json['type'] ?? "",
      allowComments: json['allowComments'] ?? false,
      showPostTime: json['showPostTime'] ?? false,
      allowSharing: json['allowSharing'] ?? false,
      allowReposting: json['allowReposting'] ?? false,
      hideFromTimeline: json['hideFromTimeline'] ?? false,
      restrictedAgeGroups:
          json['restrictedAgeGroups'] != null
              ? List<String>.from(json['restrictedAgeGroups'])
              : [],
    );
  }
}

class GhostMode {
  final bool? isGhostPost;
  final String? anonymousId;
  final bool? showVerificationBadge;
  final List<String>? allowedVerificationTypes;

  GhostMode({
    this.isGhostPost,
    this.anonymousId,
    this.showVerificationBadge,
    this.allowedVerificationTypes,
  });

  factory GhostMode.fromJson(Map<String, dynamic> json) {
    return GhostMode(
      isGhostPost: json['isGhostPost'] ?? false,
      anonymousId: json['anonymousId'] ?? "",
      showVerificationBadge: json['showVerificationBadge'] ?? false,
      allowedVerificationTypes:
          json['allowedVerificationTypes'] != null
              ? List<String>.from(json['allowedVerificationTypes'])
              : [],
    );
  }
}

class Location {
  final String? name;
  final List<double>? coordinates;
  final bool? isVisible;

  Location({this.name, this.coordinates, this.isVisible});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'] ?? "",
      coordinates:
          json['coordinates'] != null
              ? List<double>.from(json['coordinates'])
              : [],
      isVisible: json['isVisible'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (name != null) {
      data['name'] = name;
    }
    if (coordinates != null) {
      data['coordinates'] = coordinates;
    }
    if (isVisible != null) {
      data['isVisible'] = isVisible;
    }
    return data;
  }
}

class Poll {
  final String? question;
  final List<PollOptions>? options;
  final bool? allowMultipleChoices;
  final int? totalVotes;
  final bool? isActive;
  final DateTime? expiresAt;
  final bool? hasVoted;
  final String? selectedOptionId;

  Poll({
    this.question,
    this.allowMultipleChoices = false,
    this.totalVotes,
    this.isActive,
    this.options,
    this.expiresAt,
    this.hasVoted,
    this.selectedOptionId,
  });

  factory Poll.fromJson(Map<String, dynamic> json) {
    return Poll(
      question: json['question'] ?? "",
      totalVotes: json['totalVotes'] ?? 0,
      options:
          json['options'] != null
              ? List<PollOptions>.from(
                json['options'].map((x) => PollOptions.fromJson(x)),
              )
              : [],
      allowMultipleChoices: json['allowMultipleChoices'] ?? false,
      isActive: json['isActive'] ?? false,
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      hasVoted: json['hasVoted'] ?? false,
      selectedOptionId: json['selectedOptionId'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (question != null) {
      data['question'] = question;
    }
    if (options != null) {
      data['options'] = options?.map((x) => x.text).toList();
    }
    if (allowMultipleChoices != null) {
      data['allowMultipleChoices'] = allowMultipleChoices;
    }
    if (isActive != null) {
      data['isActive'] = isActive;
    }
    if (expiresAt != null) {
      data['expiresAt'] = expiresAt;
    }
    return data;
  }
}

class PollOptions {
  final String? id;
  final String? text;
  final int? voteCount;
  final List? voters;
  final Color? color;

  PollOptions({this.id, this.text, this.voteCount, this.voters, this.color});

  factory PollOptions.fromJson(Map<String, dynamic> json) {
    return PollOptions(
      id: json['id'] ?? "",
      text: json['text'] ?? "",
      voteCount: json['voteCount'] ?? 0,
      voters: json['voters'] != null ? List<dynamic>.from(json['voters']) : [],
    );
  }

  double getPercentage(double totalVotes) {
    if (totalVotes == 0) return 0.0;
    return (voteCount! / totalVotes) * 100;
  }
}
