class QuestionModel {
  final String title;
  final String description;
  final List<OptionModel> options;

  const QuestionModel({
    required this.title,
    required this.description,
    required this.options,
  });

  static final QuestionModel question = QuestionModel(
    title: "Rate your overall event experience.",
    description: "Poll create by organizer, Anthony Ciobanu. Poll create by organizer, Anthony Ciobanu",
    options: [
      OptionModel(label: "Very good", pct: 100),
      OptionModel(label: "Good", pct: 20),
      OptionModel(label: "Bad", pct: 15),
    ],
  );
}


class OptionModel {
  final String label;
  final int pct;

  const OptionModel({
    required this.label,
    required this.pct,
  });
}

