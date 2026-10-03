class UserModel {
  UserContact? contact;
  List<String>? certificateUrl;
  String? sId;
  String? email;
  String? name;
  String? arabicName;
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
    this.arabicName,
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

    sId = json['_id']?.toString();
    email = json['email']?.toString();
    name = json['name']?.toString() ?? json['label']?.toString();
    arabicName = json['arabicName']?.toString();
    role = json['role']?.toString();
    country = json['country']?.toString();
    countryCode = json['countryCode']?.toString();
    motherTree = json['motherTree']?.toString();
    linkedMember = json['linkedMember']?.toString() ?? json['_id']?.toString();
    treeJoinStatus = json['treeJoinStatus']?.toString();
    adminScope = json['adminScope']?.toString();
    adminGrantedBy = json['adminGrantedBy']?.toString();
    isActive = json['isActive'];
    isVerified = json['isVerified'];
    isDeleted = json['isDeleted'];
    createdAt = json['createdAt']?.toString();
    updatedAt = json['updatedAt']?.toString();
    iV = json['__v'];
    address = json['address']?.toString();
    age = json['age'] is int ? json['age'] : int.tryParse('${json['age'] ?? ''}');
    city = json['city']?.toString();
    dateOfBirth = json['dateOfBirth']?.toString();
    district = json['district']?.toString();
    education = json['education']?.toString();
    educationLevel = json['educationLevel']?.toString();
    employmentStatus = json['employmentStatus']?.toString();
    fieldOfWork = json['fieldOfWork']?.toString();
    gender = json['gender']?.toString();
    linkedinLink = json['linkedinLink']?.toString();
    region = json['region']?.toString();
    spouseName = json['spouseName']?.toString();
    spousePhone = json['spousePhone']?.toString();
    universityName = json['universityName']?.toString();
    profileImage = json['profileImage']?.toString();
    bio = json['bio']?.toString();
    cvUrl = json['cvUrl']?.toString();
    phone = json['phone']?.toString();

    // Check linkedUser if populated on tree/member responses
    if (json['linkedUser'] is Map) {
      final lu = json['linkedUser'] as Map;
      if (profileImage == null || profileImage!.isEmpty) {
        profileImage = lu['profileImage']?.toString();
      }
      if (name == null || name!.isEmpty) {
        name = lu['name']?.toString();
      }
      if (arabicName == null || arabicName!.isEmpty) {
        arabicName = lu['arabicName']?.toString();
      }
      if (email == null || email!.isEmpty) {
        email = lu['email']?.toString();
      }
      if (phone == null || phone!.isEmpty) {
        phone = lu['phone']?.toString();
      }
    }

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
    addIfNotNull('arabicName', arabicName);
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

  String? get resolvedLinkedIn {
    final contactLink = contact?.linkedin?.trim();
    if (contactLink != null && contactLink.isNotEmpty) return contactLink;
    final field = linkedinLink?.trim();
    if (field != null && field.isNotEmpty) return field;
    return null;
  }

  String get normalizedRole => (role ?? '').trim().toLowerCase();

  bool get hideEmailOnProfile {
    const hidden = 'mohammad@gmail.com';
    if (email?.trim().toLowerCase() == hidden) return true;
    if (contact?.email?.trim().toLowerCase() == hidden) return true;
    return false;
  }

  bool get hasDisplayName =>
      (name?.trim().isNotEmpty ?? false) ||
      (arabicName?.trim().isNotEmpty ?? false);

  String? get displayRoleLabel => roleLabelOf(role);

  static String? roleLabelOf(String? role) {
    switch ((role ?? '').trim().toLowerCase()) {
      case 'superadmin':
      case 'super_admin':
        return 'Super Admin';
      case 'admin':
        return 'Admin';
      default:
        return null;
    }
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