class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? role;
  final String? country;
  final String? countryCode;

  final String? profileImage;
  final String? region;
  final String? city;
  final String? district;
  final String? dateOfBirth;
  final int? age;
  final String? gender;
  final String? employmentStatus;
  final String? education;
  final String? educationLevel;
  final String? universityName;
  final String? fieldOfWork;
  final String? spouseName;
  final String? spousePhone;
  final String? linkedinLink;

  final String? motherTree;
  final String? linkedMember;
  final String? treeJoinStatus;

  final dynamic adminScope;
  final dynamic adminGrantedBy;

  final bool? isActive;
  final bool? isVerified;
  final bool? isDeleted;

  final String? createdAt;
  final String? updatedAt;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.role,
    this.country,
    this.countryCode,
    this.profileImage,
    this.region,
    this.city,
    this.district,
    this.dateOfBirth,
    this.age,
    this.gender,
    this.employmentStatus,
    this.education,
    this.educationLevel,
    this.universityName,
    this.fieldOfWork,
    this.spouseName,
    this.spousePhone,
    this.linkedinLink,
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
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      country: json['country'],
      countryCode: json['countryCode'],
      profileImage: json['profileImage'],
      region: json['region'],
      city: json['city'],
      district: json['district'],
      dateOfBirth: json['dateOfBirth'],
      age: json['age'],
      gender: json['gender'],
      employmentStatus: json['employmentStatus'],
      education: json['education'],
      educationLevel: json['educationLevel'],
      universityName: json['universityName'],
      fieldOfWork: json['fieldOfWork'],
      spouseName: json['spouseName'],
      spousePhone: json['spousePhone'],
      linkedinLink: json['linkedinLink'],
      motherTree: json['motherTree'],
      linkedMember: json['linkedMember'],
      treeJoinStatus: json['treeJoinStatus'],
      adminScope: json['adminScope'],
      adminGrantedBy: json['adminGrantedBy'],
      isActive: json['isActive'],
      isVerified: json['isVerified'],
      isDeleted: json['isDeleted'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'country': country,
      'countryCode': countryCode,
      'profileImage': profileImage,
      'region': region,
      'city': city,
      'district': district,
      'dateOfBirth': dateOfBirth,
      'age': age,
      'gender': gender,
      'employmentStatus': employmentStatus,
      'education': education,
      'educationLevel': educationLevel,
      'universityName': universityName,
      'fieldOfWork': fieldOfWork,
      'spouseName': spouseName,
      'spousePhone': spousePhone,
      'linkedinLink': linkedinLink,
      'motherTree': motherTree,
      'linkedMember': linkedMember,
      'treeJoinStatus': treeJoinStatus,
      'adminScope': adminScope,
      'adminGrantedBy': adminGrantedBy,
      'isActive': isActive,
      'isVerified': isVerified,
      'isDeleted': isDeleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      "dateOfBirth": dateOfBirth,
      "gender": gender,
      "employmentStatus": employmentStatus,
      "education": education,
      "educationLevel": educationLevel,
      "universityName": universityName,
      "fieldOfWork": fieldOfWork,
      "spouseName": spouseName,
      "spousePhone": spousePhone,
      "linkedinLink": linkedinLink,
      //"address": address,
      "country": country,
      "countryCode": countryCode,
      "region": region,
      "city": city,
      "district": district,
    };
  }
}
