
class PollDetailsModel {
  final String? id;
  final String? title;
  final String? tagline;
  final String? answerType;
  final int? totalResponses;
  final List<PollOption>? options;
  final bool? answered;

  // selector type
  final MyAnswer? myAnswer;

  // write-in type
  final String? answer;

  final List<PollResponse>? responses;

  PollDetailsModel({
    this.id,
    this.title,
    this.tagline,
    this.answerType,
    this.totalResponses,
    this.options,
    this.answered,
    this.myAnswer,
    this.answer,
    this.responses,
  });

  factory PollDetailsModel.fromJson(Map<String, dynamic> json) {
    return PollDetailsModel(
      id: json['_id'],
      title: json['title'],
      tagline: json['tagline'],
      answerType: json['answerType'],
      totalResponses: json['totalResponses'],
      options: json['options'] != null
          ? List<PollOption>.from(
        json['options'].map((x) => PollOption.fromJson(x)),
      )
          : [],
      answered: json['answered'],
      myAnswer: json['myAnswer'] != null
          ? MyAnswer.fromJson(json['myAnswer'])
          : null,
      answer: json['answer'],
      responses: json['responses'] != null
          ? List<PollResponse>.from(
        json['responses'].map((x) => PollResponse.fromJson(x)),
      )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'tagline': tagline,
      'answerType': answerType,
      'totalResponses': totalResponses,
      'options': options?.map((e) => e.toJson()).toList(),
      'answered': answered,
      'myAnswer': myAnswer?.toJson(),
      'answer': answer,
      'responses': responses?.map((e) => e.toJson()).toList(),
    };
  }
}

class PollResponse {
  final PollUser? user;
  final String? optionId; // For selector type
  final String? answer;   // For write-in type
  final String? answeredAt;

  PollResponse({
    this.user,
    this.optionId,
    this.answer,
    this.answeredAt,
  });

  factory PollResponse.fromJson(Map<String, dynamic> json) {
    return PollResponse(
      user: json['user'] != null ? PollUser.fromJson(json['user']) : null,
      optionId: json['optionId'],
      answer: json['answer'],
      answeredAt: json['answeredAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user?.toJson(),
      'optionId': optionId,
      'answer': answer,
      'answeredAt': answeredAt,
    };
  }
}

class PollUser {
  final String? id;
  final String? name;
  final String? arabicName;
  final String? profileImage;

  PollUser({
    this.id,
    this.name,
    this.arabicName,
    this.profileImage,
  });

  factory PollUser.fromJson(Map<String, dynamic> json) {
    return PollUser(
      id: json['_id'],
      name: json['name'],
      arabicName: json['arabicName'],
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'arabicName': arabicName,
      'profileImage': profileImage,
    };
  }
}

class PollOption {
  final String? id;
  final String? text;
  final int? count;
  final num? percentage;

  PollOption({
    this.id,
    this.text,
    this.count,
    this.percentage,
  });

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: json['_id'],
      text: json['text'],
      count: json['count'],
      percentage: json['percentage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'text': text,
      'count': count,
      'percentage': percentage,
    };
  }
}

class MyAnswer {
  final String? optionId;

  MyAnswer({
    this.optionId,
  });

  factory MyAnswer.fromJson(Map<String, dynamic> json) {
    return MyAnswer(
      optionId: json['optionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'optionId': optionId,
    };
  }
}