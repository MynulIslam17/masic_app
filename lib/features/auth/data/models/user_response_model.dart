class UserResponseModel {
  final String? id;
  final String? email;
  final String? password;
  final String? name;
  final String? arabicName;
  final String? role;
  final String? country;
  final String? countryCode;
  final String? motherTree;
  final String? linkedMember;
  final String? treeJoinStatus;
  final String? adminScope;
  final String? adminGrantedBy;
  final List<String>? fcmToken;
  final bool? isActive;
  final String? otp;
  final String? expiresAt;
  final bool? isVerified;
  final bool? isDeleted;
  final String? createdAt;
  final String? updatedAt;
  final int? version;

  const UserResponseModel({
    this.id,
    this.email,
    this.password,
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
    this.fcmToken,
    this.isActive,
    this.otp,
    this.expiresAt,
    this.isVerified,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  /// Safe string parser — handles null, int, double, bool coming as wrong type
  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    return value.toString();
  }

  /// Safe bool parser — handles null, "true"/"false" strings, 0/1 ints
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return null;
  }

  /// Safe int parser — handles null, string numbers, doubles
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Safe list parser — handles null, non-list types
  static List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    if (value is! List) return null;
    return value
        .where((e) => e != null)
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  factory UserResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserResponseModel();

    return UserResponseModel(
      id: _parseString(json['_id']),
      email: _parseString(json['email']),
      password: _parseString(json['password']),
      name: _parseString(json['name']),
      arabicName: _parseString(json['arabicName']),
      role: _parseString(json['role']),
      country: _parseString(json['country']),
      countryCode: _parseString(json['countryCode']),
      motherTree: _parseString(json['motherTree']),
      linkedMember: _parseString(json['linkedMember']),
      treeJoinStatus: _parseString(json['treeJoinStatus']),
      adminScope: _parseString(json['adminScope']),
      adminGrantedBy: _parseString(json['adminGrantedBy']),
      fcmToken: _parseStringList(json['fcmToken']),
      isActive: _parseBool(json['isActive']),
      otp: _parseString(json['otp']),
      expiresAt: _parseString(json['expiresAt']),
      isVerified: _parseBool(json['isVerified']),
      isDeleted: _parseBool(json['isDeleted']),
      createdAt: _parseString(json['createdAt']),
      updatedAt: _parseString(json['updatedAt']),
      version: _parseInt(json['__v']),
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) '_id': id,
    if (email != null) 'email': email,
    if (password != null) 'password': password,
    if (name != null) 'name': name,
    if (arabicName != null) 'arabicName': arabicName,
    if (role != null) 'role': role,
    if (country != null) 'country': country,
    if (countryCode != null) 'countryCode': countryCode,
    if (motherTree != null) 'motherTree': motherTree,
    if (linkedMember != null) 'linkedMember': linkedMember,
    if (treeJoinStatus != null) 'treeJoinStatus': treeJoinStatus,
    if (adminScope != null) 'adminScope': adminScope,
    if (adminGrantedBy != null) 'adminGrantedBy': adminGrantedBy,
    if (fcmToken != null) 'fcmToken': fcmToken,
    if (isActive != null) 'isActive': isActive,
    if (otp != null) 'otp': otp,
    if (expiresAt != null) 'expiresAt': expiresAt,
    if (isVerified != null) 'isVerified': isVerified,
    if (isDeleted != null) 'isDeleted': isDeleted,
    if (createdAt != null) 'createdAt': createdAt,
    if (updatedAt != null) 'updatedAt': updatedAt,
    if (version != null) '__v': version,
  };

  UserResponseModel copyWith({
    String? id,
    String? email,
    String? password,
    String? name,
    String? arabicName,
    String? role,
    String? country,
    String? countryCode,
    String? motherTree,
    String? linkedMember,
    String? treeJoinStatus,
    String? adminScope,
    String? adminGrantedBy,
    List<String>? fcmToken,
    bool? isActive,
    String? otp,
    String? expiresAt,
    bool? isVerified,
    bool? isDeleted,
    String? createdAt,
    String? updatedAt,
    int? version,
  }) {
    return UserResponseModel(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      arabicName: arabicName ?? this.arabicName,
      role: role ?? this.role,
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
      motherTree: motherTree ?? this.motherTree,
      linkedMember: linkedMember ?? this.linkedMember,
      treeJoinStatus: treeJoinStatus ?? this.treeJoinStatus,
      adminScope: adminScope ?? this.adminScope,
      adminGrantedBy: adminGrantedBy ?? this.adminGrantedBy,
      fcmToken: fcmToken ?? this.fcmToken,
      isActive: isActive ?? this.isActive,
      otp: otp ?? this.otp,
      expiresAt: expiresAt ?? this.expiresAt,
      isVerified: isVerified ?? this.isVerified,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }

  @override
  String toString() =>
      'UserResponseModel(id: $id, email: $email, name: $name, role: $role, isActive: $isActive, isVerified: $isVerified)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UserResponseModel &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              email == other.email;

  @override
  int get hashCode => Object.hash(id, email);
}