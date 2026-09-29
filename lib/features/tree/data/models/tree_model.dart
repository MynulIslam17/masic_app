import 'dart:ui';

String? _readTreeId(Map<String, dynamic> json) {
  final raw = json['_id'] ?? json['id'];
  if (raw == null) return null;
  final id = raw.toString().trim();
  return id.isEmpty ? null : id;
}

Map<String, dynamic>? _asStringKeyedMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return null;
}

LinkedUser? _parseLinkedUser(dynamic value) {
  final map = _asStringKeyedMap(value);
  if (map == null) return null;
  return LinkedUser.fromJson(map);
}

Children? _parseTreeChild(dynamic value) {
  final map = _asStringKeyedMap(value);
  if (map == null) return null;
  return Children.fromJson(map);
}

List<Children> _parseTreeChildren(dynamic value) {
  if (value is! List) return const [];
  return value.map(_parseTreeChild).whereType<Children>().toList();
}

/// Spouse nodes are often stored beside `children`, not inside it.
List<Children> mergeSpouseAndChildren({
  Children? spouse,
  List<Children>? children,
}) {
  final result = <Children>[];
  final seen = <String>{};

  void add(Children? node) {
    if (node == null) return;
    final id = node.nodeId;
    if (id.isNotEmpty && !seen.add(id)) return;
    result.add(node);
  }

  add(spouse);
  for (final child in children ?? const <Children>[]) {
    add(child);
  }
  return result;
}

class TreeModel {
  TreeInfo? treeInfo;
  Root? root;

  TreeModel({this.treeInfo, this.root});

  TreeModel.fromJson(Map<String, dynamic> json) {
    final info = _asStringKeyedMap(json['treeInfo']);
    treeInfo = info != null ? TreeInfo.fromJson(info) : null;
    final rootJson = _asStringKeyedMap(json['root'] ?? json['viewRoot']);
    root = rootJson != null ? Root.fromJson(rootJson) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (treeInfo != null) {
      data['treeInfo'] = treeInfo!.toJson();
    }
    if (root != null) {
      data['root'] = root!.toJson();
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
    sId = json['_id']?.toString() ?? json['id']?.toString();
    name = json['name'];
    totalMembers = json['totalMembers'];
    isDefault = json['isDefault'];
    createdBy = json['createdBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['totalMembers'] = totalMembers;
    data['isDefault'] = isDefault;
    data['createdBy'] = createdBy;
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
  Children? spouse;

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

  String get nodeId =>
      sId ?? linkedUser?.sId ?? (label?.trim().isNotEmpty == true ? label!.trim() : 'root');

  List<Children> get layoutChildren => mergeSpouseAndChildren(
        spouse: spouse,
        children: children,
      );

  Root.fromJson(Map<String, dynamic> json) {
    sId = _readTreeId(json);
    parent = json['parent'];
    linkedUser = _parseLinkedUser(json['linkedUser'] ?? json['user']);
    label = json['label']?.toString();
    level = json['level'] is int ? json['level'] as int : int.tryParse('${json['level'] ?? ''}');
    spouseOf = json['spouseOf'];
    relationType = json['relationType']?.toString();
    final parsedChildren = _parseTreeChildren(json['children'] ?? json['nodes']);
    children = parsedChildren.isEmpty ? null : parsedChildren;
    spouse = _parseTreeChild(json['spouse']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['parent'] = parent;
    if (linkedUser != null) {
      data['linkedUser'] = linkedUser!.toJson();
    }
    data['label'] = label;
    data['level'] = level;
    data['spouseOf'] = spouseOf;
    data['relationType'] = relationType;
    if (children != null) {
      data['children'] = children!.map((v) => v.toJson()).toList();
    }
    if (spouse != null) {
      data['spouse'] = spouse!.toJson();
    }
    return data;
  }
}

class LinkedUser {
  String? sId;
  String? email;
  String? name;
  String? arabicName;
  String? role;
  String? profileImage;

  LinkedUser({this.sId, this.email, this.name, this.arabicName, this.role, this.profileImage});

  LinkedUser.fromJson(Map<String, dynamic> json) {
    sId = _readTreeId(json);
    email = json['email']?.toString();
    name = json['name']?.toString();
    arabicName = (json['arabicName'] ?? json['arabic_name'] ?? json['nameAr'])
        ?.toString();
    role = json['role']?.toString();
    profileImage = json['profileImage']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['email'] = email;
    data['name'] = name;
    data['arabicName'] = arabicName;
    data['role'] = role;
    data['profileImage'] = profileImage;
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
  Children? spouse;

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

  String get nodeId => sId ?? linkedUser?.sId ?? '';

  List<Children> get layoutChildren => mergeSpouseAndChildren(
        spouse: spouse,
        children: children,
      );

  Children.fromJson(Map<String, dynamic> json) {
    sId = _readTreeId(json);
    parent = json['parent']?.toString();
    linkedUser = _parseLinkedUser(json['linkedUser'] ?? json['user']);
    label = json['label']?.toString();
    level = json['level'] is int ? json['level'] as int : int.tryParse('${json['level'] ?? ''}');
    spouseOf = json['spouseOf'];
    relationType = json['relationType']?.toString();
    final parsedChildren = _parseTreeChildren(json['children'] ?? json['nodes']);
    children = parsedChildren.isEmpty ? null : parsedChildren;
    spouse = _parseTreeChild(json['spouse']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['parent'] = parent;
    if (linkedUser != null) {
      data['linkedUser'] = linkedUser!.toJson();
    }
    data['label'] = label;
    data['level'] = level;
    data['spouseOf'] = spouseOf;
    data['relationType'] = relationType;
    if (children != null) {
      data['children'] = children!.map((v) => v.toJson()).toList();
    }
    if (spouse != null) {
      data['spouse'] = spouse!.toJson();
    }
    return data;
  }
}

class Meta {
  final String id;
  final String memberId;
  final String label;
  final String? name;
  final String? arabicName;
  final bool isRoot;
  final bool hasChildren;
  final VoidCallback? onDelete;

  const Meta({
    required this.id,
    required this.memberId,
    required this.label,
    this.name,
    this.arabicName,
    this.isRoot = false,
    this.hasChildren = false,
    this.onDelete,
  });
}

