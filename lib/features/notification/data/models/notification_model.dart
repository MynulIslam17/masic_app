class NotificationModel {
  String? sId;
  String? userId;
  String? type;
  String? title;
  String? message;
  bool? isRead;
  String? referenceId;
  NotificationData? data;
  String? createdAt;
  String? updatedAt;

  NotificationModel({
    this.sId,
    this.userId,
    this.type,
    this.title,
    this.message,
    this.isRead,
    this.referenceId,
    this.data,
    this.createdAt,
    this.updatedAt,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    type = json['type'];
    title = json['title'];
    message = json['message'];
    isRead = json['isRead'];
    referenceId = json['referenceId'];
    data = json['data'] != null
        ? NotificationData.fromJson(json['data'])
        : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['userId'] = userId;
    data['type'] = type;
    data['title'] = title;
    data['message'] = message;
    data['isRead'] = isRead;
    data['referenceId'] = referenceId;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class NotificationData {
  String? referenceType;
  String? status;
  String? name;
  String? profileImage;

  NotificationData({
    this.referenceType,
    this.status,
    this.name,
    this.profileImage,
  });

  NotificationData.fromJson(Map<String, dynamic> json) {
    referenceType = json['referenceType'];
    status = json['status'];
    name = json['name'];
    profileImage = json['profileImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['referenceType'] = referenceType;
    data['status'] = status;
    data['name'] = name;
    data['profileImage'] = profileImage;
    return data;
  }
}
