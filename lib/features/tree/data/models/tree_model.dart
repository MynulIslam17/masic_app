import 'dart:ui';

class TreeModel {
  TreeInfo? treeInfo;
  Root? root;

  TreeModel({this.treeInfo, this.root});

  TreeModel.fromJson(Map<String, dynamic> json) {
    treeInfo = json['treeInfo'] != null
        ? new TreeInfo.fromJson(json['treeInfo'])
        : null;
    root = json['root'] != null ? new Root.fromJson(json['root']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.treeInfo != null) {
      data['treeInfo'] = this.treeInfo!.toJson();
    }
    if (this.root != null) {
      data['root'] = this.root!.toJson();
    }
    return data;
  }
}

class TreeInfo {
  String? sId;
  String? name;
  int? totalMembers;
  bool? isDefault;
  String? createdBy;

  TreeInfo({
    this.sId,
    this.name,
    this.totalMembers,
    this.isDefault,
    this.createdBy,
  });

  TreeInfo.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    totalMembers = json['totalMembers'];
    isDefault = json['isDefault'];
    createdBy = json['createdBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['totalMembers'] = this.totalMembers;
    data['isDefault'] = this.isDefault;
    data['createdBy'] = this.createdBy;
    return data;
  }
}

class Root {
  String? sId;
  dynamic parent;
  LinkedUser? linkedUser;
  String? label;
  int? level;
  dynamic spouseOf;
  String? relationType;
  List<Children>? children;
  dynamic spouse;

  Root({
    this.sId,
    this.parent,
    this.linkedUser,
    this.label,
    this.level,
    this.spouseOf,
    this.relationType,
    this.children,
    this.spouse,
  });

  Root.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    parent = json['parent'];
    linkedUser = json['linkedUser'] != null
        ? new LinkedUser.fromJson(json['linkedUser'])
        : null;
    label = json['label'];
    level = json['level'];
    spouseOf = json['spouseOf'];
    relationType = json['relationType'];
    if (json['children'] != null) {
      children = <Children>[];
      json['children'].forEach((v) {
        children!.add(new Children.fromJson(v));
      });
    }
    spouse = json['spouse'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['parent'] = this.parent;
    if (this.linkedUser != null) {
      data['linkedUser'] = this.linkedUser!.toJson();
    }
    data['label'] = this.label;
    data['level'] = this.level;
    data['spouseOf'] = this.spouseOf;
    data['relationType'] = this.relationType;
    if (this.children != null) {
      data['children'] = this.children!.map((v) => v.toJson()).toList();
    }
    data['spouse'] = this.spouse;
    return data;
  }
}

class LinkedUser {
  String? sId;
  String? email;
  String? name;
  String? role;
  String? profileImage;

  LinkedUser({this.sId, this.email, this.name, this.role, this.profileImage});

  LinkedUser.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    email = json['email'];
    name = json['name'];
    role = json['role'];
    profileImage = json['profileImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['email'] = this.email;
    data['name'] = this.name;
    data['role'] = this.role;
    data['profileImage'] = this.profileImage;
    return data;
  }
}

class Children {
  String? sId;
  String? parent;
  LinkedUser? linkedUser;
  String? label;
  int? level;
  dynamic spouseOf;
  String? relationType;
  List<Children>? children;
  dynamic spouse;

  Children({
    this.sId,
    this.parent,
    this.linkedUser,
    this.label,
    this.level,
    this.spouseOf,
    this.relationType,
    this.children,
    this.spouse,
  });

  Children.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    parent = json['parent'];
    linkedUser = json['linkedUser'] != null
        ? new LinkedUser.fromJson(json['linkedUser'])
        : null;
    label = json['label'];
    level = json['level'];
    spouseOf = json['spouseOf'];
    relationType = json['relationType'];
    if (json['children'] != null) {
      children = <Children>[];
      json['children'].forEach((v) {
        children!.add(new Children.fromJson(v));
      });
    }
    spouse = json['spouse'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['parent'] = this.parent;
    if (this.linkedUser != null) {
      data['linkedUser'] = this.linkedUser!.toJson();
    }
    data['label'] = this.label;
    data['level'] = this.level;
    data['spouseOf'] = this.spouseOf;
    data['relationType'] = this.relationType;
    if (this.children != null) {
      data['children'] = this.children!.map((v) => v.toJson()).toList();
    }
    data['spouse'] = this.spouse;
    return data;
  }
}

class Meta {
  final String id;
  final String memberId;
  final String label;
  final bool isRoot;
  final bool hasChildren;
  final VoidCallback? onDelete;

  const Meta({
    required this.id,
    required this.memberId,
    required this.label,
    this.isRoot = false,
    this.hasChildren = false,
    this.onDelete,
  });
}
