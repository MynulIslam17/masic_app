class RequestLocalModel {
  final String title;
  final String description;
  final String type;

  RequestLocalModel({
    required this.title,
    required this.description,
    required this.type,

  });

 static final List<RequestLocalModel> requestDemoList = [
    RequestLocalModel(
      title: "Job application request",
      description:
      "Submit requests for jobs, volunteering opportunities, workshops",
      type: 'job',
    ),
    RequestLocalModel(
      title: "Volunteering request",
      description:
      "Apply for volunteering programs, community events, and activities",
      type: 'volunteering',
    ),
    RequestLocalModel(
      title: "Other request",
      description:
      "Send custom requests for support, workshops, or general inquiries",
      type: 'other',
    ),
  ];
}


