
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