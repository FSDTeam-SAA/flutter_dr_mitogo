class NotificationSettingsModel {
  final bool pushNotificationSettings;
  final bool realTimeUpdates;
  final bool inboxNotifications;
  final bool vibrate;
  final bool sound;

  NotificationSettingsModel({
    required this.pushNotificationSettings,
    required this.realTimeUpdates,
    required this.inboxNotifications,
    required this.vibrate,
    required this.sound,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      pushNotificationSettings: json['pushNotificationSettings'] ?? false,
      realTimeUpdates: json['realTimeUpdates'] ?? false,
      inboxNotifications: json['inboxNotifications'] ?? false,
      vibrate: json['vibrate'] ?? false,
      sound: json['sound'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushNotificationSettings': pushNotificationSettings,
      'realTimeUpdates': realTimeUpdates,
      'inboxNotifications': inboxNotifications,
      'vibrate': vibrate,
      'sound': sound,
    };
  }

  NotificationSettingsModel copyWith({
    bool? pushNotificationSettings,
    bool? realTimeUpdates,
    bool? inboxNotifications,
    bool? vibrate,
    bool? sound,
  }) {
    return NotificationSettingsModel(
      pushNotificationSettings:
          pushNotificationSettings ?? this.pushNotificationSettings,
      realTimeUpdates: realTimeUpdates ?? this.realTimeUpdates,
      inboxNotifications: inboxNotifications ?? this.inboxNotifications,
      vibrate: vibrate ?? this.vibrate,
      sound: sound ?? this.sound,
    );
  }
}
