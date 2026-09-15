class SearchModel {
  final String? title, subtitle, image;
  final dynamic model;

  /// When set, search UI uses [LocalizedNameText] (Arabic name or translated English).
  final String? personName;
  final String? personArabicName;

  SearchModel({
    this.model,
    this.title,
    this.subtitle,
    this.image,
    this.personName,
    this.personArabicName,
  });
}
