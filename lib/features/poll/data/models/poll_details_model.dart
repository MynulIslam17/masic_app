class PollDetailsModel {
  String? sId;
  String? title;
  String? tagline;
  String? createdBy;
  String? answerType;
  int? totalResponses;
  List<Options>? options;
  String? myAnswer;

  PollDetailsModel({
    this.sId,
    this.title,
    this.tagline,
    this.createdBy,
    this.answerType,
    this.totalResponses,
    this.options,
    this.myAnswer,
  });

  PollDetailsModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    tagline = json['tagline'];
    createdBy = json['createdBy'];
    answerType = json['answerType'];
    totalResponses = json['totalResponses'];
    if (json['options'] != null) {
      options = <Options>[];
      json['options'].forEach((v) {
        options!.add(Options.fromJson(v));
      });
    }
    myAnswer = json['myAnswer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['title'] = title;
    data['tagline'] = tagline;
    data['createdBy'] = createdBy;
    data['answerType'] = answerType;
    data['totalResponses'] = totalResponses;
    if (options != null) {
      data['options'] = options!.map((v) => v.toJson()).toList();
    }
    data['myAnswer'] = myAnswer;
    return data;
  }
}

class Options {
  String? sId;
  String? text;
  int? count;
  int? percentage;

  Options({this.sId, this.text, this.count, this.percentage});

  Options.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    text = json['text'];
    count = json['count'];
    percentage = json['percentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['text'] = text;
    data['count'] = count;
    data['percentage'] = percentage;
    return data;
  }
}
