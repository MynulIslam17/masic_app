class CreatePollBody {
  final String title;
  final String tagline;
  final String answerType;
  final List<Option>? options;

  CreatePollBody({
    required this.title,
    required this.tagline,
    required this.answerType,
    this.options,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "title": title,
      "tagline": tagline,
      "answerType": answerType,
    };

    if (answerType == "selector" && options != null && options!.isNotEmpty) {
      data["options"] = options!.map((e) => e.toJson()).toList();
    }

    return data;
  }
}

class Option {
  final String text;

  Option({required this.text});

  Map<String, dynamic> toJson() {
    return {"text": text};
  }
}
