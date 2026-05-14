class UserModel {
  UserContact? contact;
  List<String>? certificateUrl;
  String? sId;
  String? email;
  String? name;
  String? role;
  String? country;
  String? countryCode;
  String? motherTree;
  String? linkedMember;
  String? treeJoinStatus;
  String? adminScope;
  String? adminGrantedBy;
  bool? isActive;
  bool? isVerified;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? address;
  int? age;
  String? city;
  String? dateOfBirth;
  String? district;
  String? education;
  String? educationLevel;
  String? employmentStatus;
  String? fieldOfWork;
  String? gender;
  String? linkedinLink;
  String? region;
  String? spouseName;
  String? spousePhone;
  String? universityName;
  String? profileImage;
  String? bio;
  String? cvUrl;
  String? phone;
  List<EducationHistory>? educationHistory;
  List<UserExperience>? experience;

  UserModel({
    this.contact,
    this.certificateUrl,
    this.sId,
    this.email,
    this.name,
    this.role,
    this.country,
    this.countryCode,
    this.motherTree,
    this.linkedMember,
    this.treeJoinStatus,
    this.adminScope,
    this.adminGrantedBy,
    this.isActive,
    this.isVerified,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.address,
    this.age,
    this.city,
    this.dateOfBirth,
    this.district,
    this.education,
    this.educationLevel,
    this.employmentStatus,
    this.fieldOfWork,
    this.gender,
    this.linkedinLink,
    this.region,
    this.spouseName,
    this.spousePhone,
    this.universityName,
    this.profileImage,
    this.bio,
    this.cvUrl,
    this.phone,
    this.educationHistory,
    this.experience,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    contact = json['contact'] != null
        ? UserContact.fromJson(json['contact'])
        : null;

    if (json['certificateUrl'] is List) {
      certificateUrl = List<String>.from(json['certificateUrl']);
    } else if (json['certificateUrl'] is String &&
        json['certificateUrl'].toString().isNotEmpty) {
      certificateUrl = [json['certificateUrl']];
    }

    sId = json['_id'];
    email = json['email'];
    name = json['name'];
    role = json['role'];
    country = json['country'];
    countryCode = json['countryCode'];
    motherTree = json['motherTree'];
    linkedMember = json['linkedMember'];
    treeJoinStatus = json['treeJoinStatus'];
    adminScope = json['adminScope'];
    adminGrantedBy = json['adminGrantedBy'];
    isActive = json['isActive'];
    isVerified = json['isVerified'];
    isDeleted = json['isDeleted'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    address = json['address'];
    age = json['age'];
    city = json['city'];
    dateOfBirth = json['dateOfBirth'];
    district = json['district'];
    education = json['education'];
    educationLevel = json['educationLevel'];
    employmentStatus = json['employmentStatus'];
    fieldOfWork = json['fieldOfWork'];
    gender = json['gender'];
    linkedinLink = json['linkedinLink'];
    region = json['region'];
    spouseName = json['spouseName'];
    spousePhone = json['spousePhone'];
    universityName = json['universityName'];
    profileImage = json['profileImage'];
    bio = json['bio'];
    cvUrl = json['cvUrl'];
    phone = json['phone'];

    if (json['educationHistory'] != null) {
      educationHistory = <EducationHistory>[];
      json['educationHistory'].forEach((v) {
        educationHistory!.add(EducationHistory.fromJson(v));
      });
    }

    if (json['experience'] != null) {
      experience = <UserExperience>[];
      json['experience'].forEach((v) {
        experience!.add(UserExperience.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    void addIfNotNull(String key, dynamic value) {
      if (value != null) {
        if (value is String && value.trim().isEmpty) return;
        if (value is List && value.isEmpty) return;
        data[key] = value;
      }
    }

    addIfNotNull('contact', contact?.toJson());
    addIfNotNull('certificateUrl', certificateUrl);

    addIfNotNull('_id', sId);
    addIfNotNull('email', email);
    addIfNotNull('name', name);
    addIfNotNull('role', role);
    addIfNotNull('country', country);
    addIfNotNull('countryCode', countryCode);
    addIfNotNull('motherTree', motherTree);
    addIfNotNull('linkedMember', linkedMember);
    addIfNotNull('treeJoinStatus', treeJoinStatus);
    addIfNotNull('adminScope', adminScope);
    addIfNotNull('adminGrantedBy', adminGrantedBy);

    addIfNotNull('isActive', isActive);
    addIfNotNull('isVerified', isVerified);
    addIfNotNull('isDeleted', isDeleted);

    addIfNotNull('createdAt', createdAt);
    addIfNotNull('updatedAt', updatedAt);
    addIfNotNull('__v', iV);

    addIfNotNull('address', address);
    addIfNotNull('age', age);
    addIfNotNull('city', city);
    addIfNotNull('dateOfBirth', dateOfBirth);
    addIfNotNull('district', district);
    addIfNotNull('education', education);
    addIfNotNull('educationLevel', educationLevel);
    addIfNotNull('employmentStatus', employmentStatus);
    addIfNotNull('fieldOfWork', fieldOfWork);
    addIfNotNull('gender', gender);
    addIfNotNull('linkedinLink', linkedinLink);
    addIfNotNull('region', region);
    addIfNotNull('spouseName', spouseName);
    addIfNotNull('spousePhone', spousePhone);
    addIfNotNull('universityName', universityName);
    addIfNotNull('profileImage', profileImage);
    addIfNotNull('bio', bio);
    addIfNotNull('cvUrl', cvUrl);
    addIfNotNull('phone', phone);

    if (educationHistory != null && educationHistory!.isNotEmpty) {
      data['educationHistory'] =
          educationHistory!.map((v) => v.toJson()).toList();
    }

    if (experience != null && experience!.isNotEmpty) {
      data['experience'] =
          experience!.map((v) => v.toJson()).toList();
    }

    return data;
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {};

    void addIfNotNull(String key, dynamic value) {
      if (value != null) {
        if (value is String && value.trim().isEmpty) return;
        if (value is List && value.isEmpty) return;
        data[key] = value;
      }
    }

    addIfNotNull("name", name);
    addIfNotNull("phone", phone);
    addIfNotNull("profileImage", profileImage);
    addIfNotNull("cvUrl", cvUrl);
    addIfNotNull("certificateUrl", certificateUrl);
    addIfNotNull("bio", bio);
    addIfNotNull("address", address);
    addIfNotNull("country", country);
    addIfNotNull("countryCode", countryCode);
    addIfNotNull("region", region);
    addIfNotNull("city", city);
    addIfNotNull("district", district);
    addIfNotNull("dateOfBirth", dateOfBirth);
    addIfNotNull("age", age);
    addIfNotNull("gender", gender);
    addIfNotNull("employmentStatus", employmentStatus);
    addIfNotNull("education", education);
    addIfNotNull("educationLevel", educationLevel);
    addIfNotNull("universityName", universityName);
    addIfNotNull("fieldOfWork", fieldOfWork);
    addIfNotNull("spouseName", spouseName);
    addIfNotNull("spousePhone", spousePhone);
    addIfNotNull("linkedinLink", linkedinLink);

    final contactMap = {
      "phone": contact?.phone ?? phone,
      "linkedin": contact?.linkedin ?? linkedinLink,
      "address": address,
    };

    contactMap.removeWhere(
          (key, value) =>
      value == null ||
          (value.trim().isEmpty),
    );

    if (contactMap.isNotEmpty) {
      data["contact"] = contactMap;
    }

    if (educationHistory != null && educationHistory!.isNotEmpty) {
      data["educationHistory"] = educationHistory!
          .map((e) => e.toJson())
          .toList();
    }

    if (experience != null && experience!.isNotEmpty) {
      data["experience"] =
          experience!.map((e) => e.toJson()).toList();
    }

    return data;
  }
}

class UserContact {
  String? phone;
  String? email;
  String? linkedin;
  String? address;

  UserContact({
    this.phone,
    this.email,
    this.linkedin,
    this.address,
  });

  UserContact.fromJson(Map<String, dynamic> json) {
    phone = json['phone'];
    email = json['email'];
    linkedin = json['linkedin'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    void addIfNotNull(String key, dynamic value) {
      if (value != null) {
        if (value is String && value.trim().isEmpty) return;
        data[key] = value;
      }
    }

    addIfNotNull('phone', phone);
    addIfNotNull('email', email);
    addIfNotNull('linkedin', linkedin);
    addIfNotNull('address', address);

    return data;
  }
}

class EducationHistory {
  String? school;
  String? degree;
  String? major;
  String? from;
  String? to;
  bool? isCurrent;
  String? sId;

  EducationHistory({
    this.school,
    this.degree,
    this.major,
    this.from,
    this.to,
    this.isCurrent,
    this.sId,
  });

  EducationHistory.fromJson(Map<String, dynamic> json) {
    school = json['school'];
    degree = json['degree'];
    major = json['major'];
    from = json['from'];
    to = json['to'];
    isCurrent = json['isCurrent'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    void addIfNotNull(String key, dynamic value) {
      if (value != null) {
        if (value is String && value.trim().isEmpty) return;
        data[key] = value;
      }
    }

    addIfNotNull('school', school);
    addIfNotNull('degree', degree);
    addIfNotNull('major', major);
    addIfNotNull('from', from);
    addIfNotNull('to', to);
    addIfNotNull('isCurrent', isCurrent);
    addIfNotNull('_id', sId);

    return data;
  }
}

class UserExperience {
  String? company;
  String? position;
  String? from;
  String? to;
  bool? isCurrent;
  String? sId;

  UserExperience({
    this.company,
    this.position,
    this.from,
    this.to,
    this.isCurrent,
    this.sId,
  });

  UserExperience.fromJson(Map<String, dynamic> json) {
    company = json['company'];
    position = json['position'];
    from = json['from'];
    to = json['to'];
    isCurrent = json['isCurrent'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    void addIfNotNull(String key, dynamic value) {
      if (value != null) {
        if (value is String && value.trim().isEmpty) return;
        data[key] = value;
      }
    }

    addIfNotNull('company', company);
    addIfNotNull('position', position);
    addIfNotNull('from', from);
    addIfNotNull('to', to);
    addIfNotNull('isCurrent', isCurrent);
    addIfNotNull('_id', sId);

    return data;
  }
}