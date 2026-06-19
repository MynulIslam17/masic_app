import 'package:masic_generation/features/poll/data/models/poll_details_model.dart';

class PollResultModel {
  String? sId;
  String? title;
  String? tagline;
  String? answerType;
  int? totalResponses;
  List<Answers>? answers;
  List<PollOption>? options;
  String? createdAt;

  PollResultModel({
    this.sId,
    this.title,
    this.tagline,
    this.answerType,
    this.totalResponses,
    this.answers,
    this.options,
    this.createdAt,
  });

  PollResultModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id']?.toString();
    title = json['title']?.toString();
    tagline = json['tagline']?.toString();
    answerType = json['answerType']?.toString();
    totalResponses = _parseInt(json['totalResponses']);
    createdAt = json['createdAt']?.toString();

    if (json['answers'] is List) {
      answers = (json['answers'] as List)
          .whereType<Map>()
          .map((v) => Answers.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    }

    if (json['options'] is List) {
      options = (json['options'] as List)
          .whereType<Map>()
          .map((v) => PollOption.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    }
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['_id'] = sId;
    data['title'] = title;
    data['tagline'] = tagline;
    data['answerType'] = answerType;
    data['totalResponses'] = totalResponses;

    if (answers != null) {
      data['answers'] = answers!.map((v) => v.toJson()).toList();
    }

    if (options != null) {
      data['options'] = options!.map((v) => v.toJson()).toList();
    }

    data['createdAt'] = createdAt;

    return data;
  }
}

class Answers {
  String? answer;
  User? user;
  String? submittedAt;

  Answers({
    this.answer,
    this.user,
    this.submittedAt,
  });

  Answers.fromJson(Map<String, dynamic> json) {
    answer = json['answer'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    submittedAt = json['submittedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['answer'] = answer;

    if (user != null) {
      data['user'] = user!.toJson();
    }

    data['submittedAt'] = submittedAt;

    return data;
  }
}

class Options {
  String? sId;
  String? text;
  int? count;
  int? percentage;
  List<User>? users;

  Options({
    this.sId,
    this.text,
    this.count,
    this.percentage,
    this.users,
  });

  Options.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    text = json['text'];
    count = json['count'];
    percentage = json['percentage'];

    if (json['users'] != null) {
      users = <User>[];
      json['users'].forEach((v) {
        users!.add(User.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['_id'] = sId;
    data['text'] = text;
    data['count'] = count;
    data['percentage'] = percentage;

    if (users != null) {
      data['users'] = users!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class User {
  String? sId;
  String? email;
  String? name;
  String? profileImage;

  User({
    this.sId,
    this.email,
    this.name,
    this.profileImage,
  });

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