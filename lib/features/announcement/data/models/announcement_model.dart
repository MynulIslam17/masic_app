class AnnouncementModel {
  String? sId;
  CreatedBy? createdBy;
  String? title;
  String? bannerUrl;
  String? description;
  String? status;
  String? declineReason;
  String? targetType;
  GroupFilter? groupFilter;
  List<String>? targetUsers;
  String? createdAt;
  String? updatedAt;

  AnnouncementModel({
    this.sId,
    this.createdBy,
    this.title,
    this.bannerUrl,
    this.description,
    this.status,
    this.declineReason,
    this.targetType,
    this.groupFilter,
    this.targetUsers,
    this.createdAt,
    this.updatedAt,
  });

  AnnouncementModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    createdBy = json['createdBy'] != null
        ? CreatedBy.fromJson(json['createdBy'])
        : null;
    title = json['title'];
    bannerUrl = json['bannerUrl'];
    description = json['description'];
    status = json['status'];
    declineReason = json['declineReason'];
    targetType = json['targetType'];
    groupFilter = json['groupFilter'] != null
        ? GroupFilter.fromJson(json['groupFilter'])
        : null;
    targetUsers = json['targetUsers'] != null
        ? List<String>.from(json['targetUsers'])
        : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (createdBy != null) {
      data['createdBy'] = createdBy!.toJson();
    }
    data['title'] = title;
    data['bannerUrl'] = bannerUrl;
    data['description'] = description;
    data['status'] = status;
    data['declineReason'] = declineReason;
    data['targetType'] = targetType;
    if (groupFilter != null) {
      data['groupFilter'] = groupFilter!.toJson();
    }
    data['targetUsers'] = targetUsers;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class CreatedBy {
  String? profileImage;
  String? sId;

  CreatedBy({this.profileImage, this.sId});

  CreatedBy.fromJson(Map<String, dynamic> json) {
    profileImage = json['profileImage'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['profileImage'] = profileImage;
    data['_id'] = sId;
    return data;
  }
}

class GroupFilter {
  AgeRange? ageRange;
  String? gender;
  String? employmentStatus;
  String? educationLevel;

  GroupFilter({
    this.ageRange,
    this.gender,
    this.employmentStatus,
    this.educationLevel,
  });

  GroupFilter.fromJson(Map<String, dynamic> json) {
    ageRange = json['ageRange'] != null
        ? AgeRange.fromJson(json['ageRange'])
        : null;
    gender = json['gender'];
    employmentStatus = json['employmentStatus'];
    educationLevel = json['educationLevel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (ageRange != null) {
      data['ageRange'] = ageRange!.toJson();
    }
    data['gender'] = gender;
    data['employmentStatus'] = employmentStatus;
    data['educationLevel'] = educationLevel;
    return data;
  }
}

class AgeRange {
  int? min;
  int? max;

  AgeRange({this.min, this.max});

  AgeRange.fromJson(Map<String, dynamic> json) {
    min = json['min'];
    max = json['max'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['min'] = min;
    data['max'] = max;
    return data;
  }
}
