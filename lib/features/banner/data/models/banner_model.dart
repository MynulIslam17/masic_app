
class BannerModel {
  String? sId;
  String? uploadedBy;
  String? imageUrl;
  String? activateAt;
  bool? isActive;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;
  int? iV;

  BannerModel(
      {this.sId,
        this.uploadedBy,
        this.imageUrl,
        this.activateAt,
        this.isActive,
        this.isDeleted,
        this.createdAt,
        this.updatedAt,
        this.iV});

  BannerModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    uploadedBy = json['uploadedBy'];
    imageUrl = json['imageUrl'];
    activateAt = json['activateAt'];
    isActive = json['isActive'];
    isDeleted = json['isDeleted'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['uploadedBy'] = this.uploadedBy;
    data['imageUrl'] = this.imageUrl;
    data['activateAt'] = this.activateAt;
    data['isActive'] = this.isActive;
    data['isDeleted'] = this.isDeleted;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
