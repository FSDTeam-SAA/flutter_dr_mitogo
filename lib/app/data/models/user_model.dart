import 'package:get/get.dart';
import 'package:casarancha/app/data/models/verification_badge_model.dart';

class UserModel {
  String? id;
  String? email;
  String? phoneNumber;
  String? displayName;
  String? bio;
  String? anonymousId;
  String? avatarUrl;
  String? education;
  String? work;
  DateTime? dateOfBirth;
  String? username;
  RxInt? followerCount;
  RxInt? followingCount;
  RxBool? isFollowing = false.obs;
  bool? isVerified;
  VerificationBadges? verificationBadges;
  String? coverPhotoUrl;
  String? password;
  DateTime? createdAt;
  GhostProgression? ghostProgression;
  RxBool? ghostMode = false.obs;

  UserModel({
    this.id,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.bio,
    this.anonymousId,
    this.avatarUrl,
    this.education,
    this.work,
    this.dateOfBirth,
    this.username,
    this.followerCount,
    this.followingCount,
    this.isVerified,
    this.verificationBadges,
    this.coverPhotoUrl,
    this.password,
    this.createdAt,
    this.isFollowing,
    this.ghostProgression,
    this.ghostMode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json["phoneNumber"] ?? "",
      displayName: json['displayName'] ?? '',
      bio: json['bio'] ?? '',
      anonymousId: json['anonymousId'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      education: json['education'] ?? '',
      work: json['work'] ?? '',
      dateOfBirth:
          json['dateOfBirth'] != null
              ? DateTime.parse(json['dateOfBirth'])
              : DateTime(1970),
      username: json['username'] ?? '',
      followerCount: RxInt(json['stats']?['followerCount'] ?? 0),
      followingCount: RxInt(json['stats']?['followingCount'] ?? 0),
      isVerified: json['isVerified'] ?? false,
      verificationBadges: VerificationBadges.fromJson(json['verificationBadges']),
      coverPhotoUrl: json['coverPhotoUrl'] ?? '',
      createdAt:
          json["createdAt"] != null
              ? DateTime.parse(json["createdAt"])
              : DateTime.now(),
      isFollowing: RxBool(json['isFollowing'] ?? false),
      ghostProgression:
          json["ghostProgression"] != null
              ? GhostProgression.fromJson(json["ghostProgression"])
              : null,
      ghostMode: RxBool(json['ghostMode'] ?? false),
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {};
    if (email != null && email?.isNotEmpty == true) {
      map['email'] = email;
    }
    if (phoneNumber != null && phoneNumber?.isNotEmpty == true) {
      map['phoneNumber'] = phoneNumber;
    }
    if (displayName != null && displayName?.isNotEmpty == true) {
      map['display_name'] = displayName;
    }
    if (bio != null && bio?.isNotEmpty == true) {
      map['bio'] = bio;
    }
    if (avatarUrl != null && avatarUrl?.isNotEmpty == true) {
      map['avatarUrl'] = avatarUrl;
    }
    if (education != null && education?.isNotEmpty == true) {
      map['education'] = education;
    }
    if (work != null && work?.isNotEmpty == true) {
      map['work'] = work;
    }
    if (dateOfBirth != null) {
      map['dateOfBirth'] = dateOfBirth!.toIso8601String();
    }
    if (username != null && username?.isNotEmpty == true) {
      map['username'] = username;
    }
    if (followerCount != null && followingCount != null) {
      map['stats'] = {
        'followerCount': followerCount?.value,
        'followingCount': followingCount?.value,
      };
    }
    if (password != null && password?.isNotEmpty == true) {
      map['password'] = password;
    }
    return map;
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, displayName: $displayName, bio: $bio, '
        'anonymousId: $anonymousId, avatarUrl: $avatarUrl, education: $education, work: $work, '
        'dateOfBirth: $dateOfBirth, username: $username, '
        'followerCount: $followerCount, followingCount: $followingCount)';
  }
}

class GhostProgression {
  final String level;
  final int postsMade;
  final int friendsInvited;
  final int daysActive;
  final DateTime lastLevelUp;
  final NextLevelRequirements nextLevelRequirements;

  GhostProgression({
    required this.level,
    required this.postsMade,
    required this.friendsInvited,
    required this.daysActive,
    required this.lastLevelUp,
    required this.nextLevelRequirements,
  });

  factory GhostProgression.fromJson(Map<String, dynamic> json) {
    return GhostProgression(
      level: json['level'],
      postsMade: json['postsMade'],
      friendsInvited: json['friendsInvited'],
      daysActive: json['daysActive'],
      lastLevelUp: DateTime.parse(json['lastLevelUp']),
      nextLevelRequirements: NextLevelRequirements.fromJson(
        json['nextLevelRequirements'],
      ),
    );
  }
}

class NextLevelRequirements {
  final String level;
  final int postsNeeded;
  final int friendsNeeded;
  final int daysActiveNeeded;

  NextLevelRequirements({
    required this.level,
    required this.postsNeeded,
    required this.friendsNeeded,
    required this.daysActiveNeeded,
  });

  factory NextLevelRequirements.fromJson(Map<String, dynamic> json) {
    return NextLevelRequirements(
      level: json["level"],
      postsNeeded: json['postsNeeded'],
      friendsNeeded: json['friendsNeeded'],
      daysActiveNeeded: json['daysActiveNeeded'],
    );
  }
}
