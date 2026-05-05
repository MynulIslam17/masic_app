class CreateRequestModel {
  final String title;
  final String dec;
  final List<String>? users;

  CreateRequestModel({
    required this.title,
    required this.dec,
    this.users,
  });

  factory CreateRequestModel.fromJson(Map<String, dynamic> json) {
    return CreateRequestModel(
      title: json['title'] ?? '',
      dec: json['dec'] ?? '',
      users: json['users'] != null
          ? List<String>.from(json['users'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'dec': dec,
    };

    if (users != null) {
      data['users'] = users;
    }

    return data;
  }
}
