import 'package:masic_generation/features/profile/data/models/user_model.dart';

class CreateJobModel {
  String? user;
  String? type;
  String? bio;
  String? jobSpec;
  UserContact? contact;
  List<EducationHistory>? education;
  List<UserExperience>? experience;
  String? cvUrl;
  String? certificateUrl;

  CreateJobModel({
    this.user,
    this.type,
    this.bio,
    this.jobSpec,
    this.contact,
    this.education,
    this.experience,
    this.cvUrl,
    this.certificateUrl,
  });

  CreateJobModel.fromJson(Map<String, dynamic> json) {
    user = json['user'];
    type = json['type'];
    bio = json['bio'];
    jobSpec = json['jobSpec'];

    contact = json['contact'] != null
        ? UserContact.fromJson(json['contact'])
        : null;

    if (json['education'] != null) {
      education = <EducationHistory>[];
      json['education'].forEach((v) {
        education!.add(EducationHistory.fromJson(v));
      });
    }

    if (json['experience'] != null) {
      experience = <UserExperience>[];
      json['experience'].forEach((v) {
        experience!.add(UserExperience.fromJson(v));
      });
    }

    cvUrl = json['cvUrl'];
    certificateUrl = json['certificateUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['user'] = user;
    data['type'] = type;
    data['bio'] = bio;
    data['jobSpec'] = jobSpec;

    if (contact != null) {
      data['contact'] = contact!.toJson();
    }

    if (education != null) {
      data['education'] = education!.map((v) => v.toJson()).toList();
    }

    if (experience != null) {
      data['experience'] = experience!.map((v) => v.toJson()).toList();
    }

    data['cvUrl'] = cvUrl;
    data['certificateUrl'] = certificateUrl;

    return data;
  }
}
