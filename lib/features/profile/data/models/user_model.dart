class UserModel {
  Contact? contact;
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
  List<Experience>? experience;

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
        ? Contact.fromJson(json['contact'])
        : null;

    if (json['certificateUrl'] is List) {
      certificateUrl = List<String>.from(json['certificateUrl']);
    } else if (json['certificateUrl'] is String &&
        json['certificateUrl'].isNotEmpty) {
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
      experience = <Experience>[];
      json['experience'].forEach((v) {
        experience!.add(Experience.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (contact != null) data['contact'] = contact!.toJson();
    if (certificateUrl != null) data['certificateUrl'] = certificateUrl;
    data['_id'] = sId;
    data['email'] = email;
    data['name'] = name;
    data['role'] = role;
    data['country'] = country;
    data['countryCode'] = countryCode;
    data['motherTree'] = motherTree;
    data['linkedMember'] = linkedMember;
    data['treeJoinStatus'] = treeJoinStatus;
    data['adminScope'] = adminScope;
    data['adminGrantedBy'] = adminGrantedBy;
    data['isActive'] = isActive;
    data['isVerified'] = isVerified;
    data['isDeleted'] = isDeleted;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['address'] = address;
    data['age'] = age;
    data['city'] = city;
    data['dateOfBirth'] = dateOfBirth;
    data['district'] = district;
    data['education'] = education;
    data['educationLevel'] = educationLevel;
    data['employmentStatus'] = employmentStatus;
    data['fieldOfWork'] = fieldOfWork;
    data['gender'] = gender;
    data['linkedinLink'] = linkedinLink;
    data['region'] = region;
    data['spouseName'] = spouseName;
    data['spousePhone'] = spousePhone;
    data['universityName'] = universityName;
    data['profileImage'] = profileImage;
    data['bio'] = bio;
    data['cvUrl'] = cvUrl;
    data['phone'] = phone;
    if (educationHistory != null) {
      data['educationHistory'] = educationHistory!
          .map((v) => v.toJson())
          .toList();
    }
    if (experience != null) {
      data['experience'] = experience!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "phone": phone,
      "profileImage": profileImage,
      "cvUrl": cvUrl,
      "certificateUrl": certificateUrl ?? [],
      "bio": bio,
      "address": address,
      "country": country,
      "countryCode": countryCode,
      "region": region,
      "city": city,
      "district": district,
      "dateOfBirth": dateOfBirth,
      "age": age,
      "gender": gender,
      "employmentStatus": employmentStatus,
      "education": education,
      "educationLevel": educationLevel,
      "universityName": universityName,
      "fieldOfWork": fieldOfWork,
      "spouseName": spouseName,
      "spousePhone": spousePhone,
      "linkedinLink": linkedinLink,

      // Contact
      "contact": {
        "phone": contact?.phone ?? phone,
        "linkedin": contact?.linkedin ?? linkedinLink,
        "address": address,
      },

      // Education History
      "educationHistory": educationHistory != null
          ? educationHistory!.map((e) => {
        "school": e.school,
        "degree": e.degree,
        "major": e.major,
        "from": e.from,
        "to": e.to,
        "isCurrent": e.isCurrent,
      }).toList()
          : [],

      // Experience
      "experience": experience != null
          ? experience!.map((e) => {
        "company": e.company,
        "position": e.position,
        "from": e.from,
        "to": e.to,
        "isCurrent": e.isCurrent,
      }).toList()
          : [],
    };
  }}

class Contact {
  String? phone;
  String? linkedin;
  String? address;


  Contact({this.phone, this.linkedin, this.address});

  Contact.fromJson(Map<String, dynamic> json) {
    phone = json['phone'];
    linkedin = json['linkedin'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['phone'] = phone;
    data['linkedin'] = linkedin;
    data['address'] = address;
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
    data['school'] = school;
    data['degree'] = degree;
    data['major'] = major;
    data['from'] = from;
    data['to'] = to;
    data['isCurrent'] = isCurrent;
    data['_id'] = sId;
    return data;
  }
}

class Experience {
  String? company;
  String? position;
  String? from;
  String? to;
  bool? isCurrent;
  String? sId;

  Experience({
    this.company,
    this.position,
    this.from,
    this.to,
    this.isCurrent,
    this.sId,
  });

  Experience.fromJson(Map<String, dynamic> json) {
    company = json['company'];
    position = json['position'];
    from = json['from'];
    to = json['to'];
    isCurrent = json['isCurrent'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['company'] = company;
    data['position'] = position;
    data['from'] = from;
    data['to'] = to;
    data['isCurrent'] = isCurrent;
    data['_id'] = sId;
    return data;
  }
}
