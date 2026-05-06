class PollModel {
  String? sId;
  CreatedBy? createdBy;
  String? title;
  String? tagline;
  String? answerType;
  List<Options>? options;
  int? totalResponses;
  String? createdAt;
  String? updatedAt;

  PollModel(
      {this.sId,
        this.createdBy,
        this.title,
        this.tagline,
        this.answerType,
        this.options,
        this.totalResponses,
        this.createdAt,
        this.updatedAt});

  PollModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    createdBy = json['createdBy'] != null
        ? CreatedBy.fromJson(json['createdBy'])
        : null;
    title = json['title'];
    tagline = json['tagline'];
    answerType = json['answerType'];
    if (json['options'] != null) {
      options = <Options>[];
      json['options'].forEach((v) {
        options!.add(Options.fromJson(v));
      });
    }
    totalResponses = json['totalResponses'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (createdBy != null) {
      data['createdBy'] = createdBy!.toJson();
    }
    data['title'] = title;
    data['tagline'] = tagline;
    data['answerType'] = answerType;
    if (options != null) {
      data['options'] = options!.map((v) => v.toJson()).toList();
    }
    data['totalResponses'] = totalResponses;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class CreatedBy {
  String? profileImage;
  String? sId;

  CreatedBy({this.profileImage, this.sId});

  CreatedBy.fromJson(Map<String, dynamic> json) {
    profileImage = json['profileImage'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['profileImage'] = profileImage;
    data['_id'] = sId;
    return data;
  }
}

class Options {
  String? text;
  int? count;
  String? sId;

  Options({this.text, this.count, this.sId});

  Options.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    count = json['count'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['count'] = count;
    data['_id'] = sId;
    return data;
  }
}
