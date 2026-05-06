class CreateRequestModel {
  final String title;
  final String description;
  final List<String>? targetUsers;

  CreateRequestModel({
    required this.title,
    required this.description,
    this.targetUsers,
  });

  factory CreateRequestModel.fromJson(Map<String, dynamic> json) {
    return CreateRequestModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      targetUsers: json['targetUsers'] != null
          ? List<String>.from(json['targetUsers'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final isAll = targetUsers == null || targetUsers!.isEmpty;

    return {
      'title': title,
      'description': description,
      'targetType': isAll ? 'all' : 'group',
      'targetUsers': isAll ? [] : targetUsers,
    };
  }
}