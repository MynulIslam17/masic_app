class BarChartModel {
  final String label;
  final double value;

   const BarChartModel({
    required this.label,
    required this.value,
  });


  static final List<BarChartModel> ageData = [
    BarChartModel(label: '10-20',  value: 12.0),
    BarChartModel(label: '21-40',  value: 23.0),
    BarChartModel(label: '41-60',  value: 67.0),
    BarChartModel(label: '61-80',  value: 54.0),
    BarChartModel(label: '81-100', value: 11.0),
  ];


  static final List<BarChartModel> nameData = [
    BarChartModel(label: 'Rayhan',  value: 12.0),
    BarChartModel(label: 'Tanvir',  value: 23.0),
    BarChartModel(label: 'Hridoy',  value: 67.0),
    BarChartModel(label: 'Sowrov',  value: 54.0),
    BarChartModel(label: 'Hasib', value: 11.0),
  ];

  static final List<BarChartModel> workData = [
    BarChartModel(label: 'Doctor',  value: 12.0),
    BarChartModel(label: 'Engineer',  value: 23.0),
    BarChartModel(label: 'Student',  value: 67.0),
    BarChartModel(label: 'Teacher',  value: 54.0),
    BarChartModel(label: 'Business', value: 11.0),
  ];


  static final List<BarChartModel> locationData = [
    BarChartModel(label: 'Savar',  value: 12.0),
    BarChartModel(label: 'Dhaka',  value: 23.0),
    BarChartModel(label: 'Kolma',  value: 67.0),
    BarChartModel(label: 'Zinzira',  value: 54.0),
    BarChartModel(label: 'Mohakhali', value: 11.0),
  ];



  static final List<BarChartModel> gender = [
    BarChartModel(label: 'Male',  value: 23),
    BarChartModel(label: 'Female',  value: 10),
  ];

  static final List<BarChartModel> employmentStatusData = [
    BarChartModel(label: 'Employed',  value: 44),
    BarChartModel(label: 'Un employed',  value: 100),
  ];


  static final List<BarChartModel> studentData = [
    BarChartModel(label: 'University',  value: 100),
    BarChartModel(label: 'School',  value: 30),
  ];
}