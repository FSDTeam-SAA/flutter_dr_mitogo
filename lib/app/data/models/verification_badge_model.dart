class VerificationBadges {
  final bool profile;
  final bool work;
  final bool school;
  final WorkDetails? workDetails;
  final SchoolDetails? schoolDetails;

  VerificationBadges({
    this.profile = false,
    this.work = false,
    this.school = false,
    this.workDetails,
    this.schoolDetails,
  });

  factory VerificationBadges.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return VerificationBadges();
    }
    return VerificationBadges(
      profile: json['profile'] ?? false,
      work: json['work'] ?? false,
      school: json['school'] ?? false,
      workDetails: json['workDetails'] != null
          ? WorkDetails.fromJson(json['workDetails'])
          : null,
      schoolDetails: json['schoolDetails'] != null
          ? SchoolDetails.fromJson(json['schoolDetails'])
          : null,
    );
  }
}

class WorkDetails {
  final String? company;
  final String? position;

  WorkDetails({this.company, this.position});

  factory WorkDetails.fromJson(Map<String, dynamic> json) {
    return WorkDetails(
      company: json['company'],
      position: json['position'],
    );
  }
}

class SchoolDetails {
  final String? name;
  final String? email;

  SchoolDetails({this.name, this.email});

  factory SchoolDetails.fromJson(Map<String, dynamic> json) {
    return SchoolDetails(
      name: json['name'],
      email: json['email'],
    );
  }
}
