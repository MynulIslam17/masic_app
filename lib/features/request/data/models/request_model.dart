class RequestModel {
  String? sId;
  User? user;
  String? type;
  String? status;
  bool? isDraft;
  String? bio;
  String? jobSpec;
  Contact? contact;
  List<Education>? education;
  List<Experience>? experience;
  String? cvUrl;
  String? certificateUrl;
  String? adminNote;
  String? additionalInfoRequest;
  String? declineReason;
  String? createdAt;
  String? updatedAt;

  RequestModel({
    this.sId,
    this.user,
    this.type,
    this.status,
    this.isDraft,
    this.bio,
    this.jobSpec,
    this.contact,
    this.education,
    this.experience,
    this.cvUrl,
    this.certificateUrl,
    this.adminNote,
    this.additionalInfoRequest,
    this.declineReason,
    this.createdAt,
    this.updatedAt,
  });

  RequestModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    type = json['type'];
    status = json['status'];
    isDraft = json['isDraft'];
    bio = json['bio'];
    jobSpec = json['jobSpec'];
    contact = json['contact'] != null
        ? Contact.fromJson(json['contact'])
        : null;
    if (json['education'] != null) {
      education = <Education>[];
      json['education'].forEach((v) {
        education!.add(Education.fromJson(v));
      });
    }
    if (json['experience'] != null) {
      experience = <Experience>[];
      json['experience'].forEach((v) {
        experience!.add(Experience.fromJson(v));
      });
    }
    cvUrl = json['cvUrl'];
    certificateUrl = json['certificateUrl'];
    adminNote = json['adminNote'];
    additionalInfoRequest = json['additionalInfoRequest'];
    declineReason = json['declineReason'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['type'] = type;
    data['status'] = status;
    data['isDraft'] = isDraft;
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
    data['adminNote'] = adminNote;
    data['additionalInfoRequest'] = additionalInfoRequest;
    data['declineReason'] = declineReason;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class User {
  String? sId;
  String? email;
  String? name;
  String? profileImage;

  User({this.sId, this.email, this.name, this.profileImage});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    email = json['email'];
    name = json['name'];
    profileImage = json['profileImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['email'] = email;
    data['name'] = name;
    data['profileImage'] = profileImage;
    return data;
  }
}

class Contact {
  String? phone;
  String? email;
  String? linkedin;
  String? address;

  Contact({this.phone, this.email, this.linkedin, this.address});

  Contact.fromJson(Map<String, dynamic> json) {
    phone = json['phone'];
    email = json['email'];
    linkedin = json['linkedin'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['phone'] = phone;
    data['email'] = email;
    data['linkedin'] = linkedin;
    data['address'] = address;
    return data;
  }
}

class Education {
  String? school;
  String? degree;
  String? major;
  String? from;
  String? to;
  bool? isCurrent;

  Education({
    this.school,
    this.degree,
    this.major,
    this.from,
    this.to,
    this.isCurrent,
  });

  Education.fromJson(Map<String, dynamic> json) {
    school = json['school'];
    degree = json['degree'];
    major = json['major'];
    from = json['from'];
    to = json['to'];
    isCurrent = json['isCurrent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['school'] = school;
    data['degree'] = degree;
    data['major'] = major;
    data['from'] = from;
    data['to'] = to;
    data['isCurrent'] = isCurrent;
    return data;
  }
}

class Experience {
  String? company;
  String? position;
  String? from;
  String? to;
  bool? isCurrent;

  Experience({this.company, this.position, this.from, this.to, this.isCurrent});

  Experience.fromJson(Map<String, dynamic> json) {
    company = json['company'];
    position = json['position'];
    from = json['from'];
    to = json['to'];
    isCurrent = json['isCurrent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['company'] = company;
    data['position'] = position;
    data['from'] = from;
    data['to'] = to;
    data['isCurrent'] = isCurrent;
    return data;
  }
}
