class DashboardModel {
  List<AgeRange>? ageRange;
  List<Gender>? gender;
  List<CommonNames>? commonNames;
  List<EmploymentStatus>? employmentStatus;
  List<FieldOfWork>? fieldOfWork;
  List<EducationLevel>? educationLevel;
  List<Location>? location;

  DashboardModel({
    this.ageRange,
    this.gender,
    this.commonNames,
    this.employmentStatus,
    this.fieldOfWork,
    this.educationLevel,
    this.location,
  });

  DashboardModel.fromJson(Map<String, dynamic> json) {
    if (json['ageRange'] != null) {
      ageRange = <AgeRange>[];
      json['ageRange'].forEach((v) {
        ageRange!.add(AgeRange.fromJson(v));
      });
    }
    if (json['gender'] != null) {
      gender = <Gender>[];
      json['gender'].forEach((v) {
        gender!.add(Gender.fromJson(v));
      });
    }
    if (json['commonNames'] != null) {
      commonNames = <CommonNames>[];
      json['commonNames'].forEach((v) {
        commonNames!.add(CommonNames.fromJson(v));
      });
    }
    if (json['employmentStatus'] != null) {
      employmentStatus = <EmploymentStatus>[];
      json['employmentStatus'].forEach((v) {
        employmentStatus!.add(EmploymentStatus.fromJson(v));
      });
    }
    if (json['fieldOfWork'] != null) {
      fieldOfWork = <FieldOfWork>[];
      json['fieldOfWork'].forEach((v) {
        fieldOfWork!.add(FieldOfWork.fromJson(v));
      });
    }
    if (json['educationLevel'] != null) {
      educationLevel = <EducationLevel>[];
      json['educationLevel'].forEach((v) {
        educationLevel!.add(EducationLevel.fromJson(v));
      });
    }
    if (json['location'] != null) {
      location = <Location>[];
      json['location'].forEach((v) {
        location!.add(Location.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (ageRange != null) {
      data['ageRange'] = ageRange!.map((v) => v.toJson()).toList();
    }
    if (gender != null) {
      data['gender'] = gender!.map((v) => v.toJson()).toList();
    }
    if (commonNames != null) {
      data['commonNames'] = commonNames!.map((v) => v.toJson()).toList();
    }
    if (employmentStatus != null) {
      data['employmentStatus'] = employmentStatus!
          .map((v) => v.toJson())
          .toList();
    }
    if (fieldOfWork != null) {
      data['fieldOfWork'] = fieldOfWork!.map((v) => v.toJson()).toList();
    }
    if (educationLevel != null) {
      data['educationLevel'] = educationLevel!.map((v) => v.toJson()).toList();
    }
    if (location != null) {
      data['location'] = location!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  List<BarChartModel> get ageRangeChartData => (ageRange ?? [])
      .map(
        (e) => BarChartModel(
      label: e.range ?? '',
      value: (e.percentage ?? 0).toDouble(),
    ),
  )
      .toList();

  List<BarChartModel> get genderChartData => (gender ?? [])
      .map(
        (e) => BarChartModel(
      label: e.gender ?? '',
      value: (e.percentage ?? 0).toDouble(),
    ),
  )
      .toList();

  List<BarChartModel> get commonNamesChartData => (commonNames ?? [])
      .map(
        (e) => BarChartModel(
      label: e.name ?? '',
      value: (e.percentage ?? 0).toDouble(),
    ),
  )
      .toList();

  List<BarChartModel> get employmentStatusChartData => (employmentStatus ?? [])
      .map(
        (e) => BarChartModel(
      label: e.status ?? '',
      value: (e.percentage ?? 0).toDouble(),
    ),
  )
      .toList();

  List<BarChartModel> get fieldOfWorkChartData => (fieldOfWork ?? [])
      .map(
        (e) => BarChartModel(
      label: e.field ?? '',
      value: (e.percentage ?? 0).toDouble(),
    ),
  )
      .toList();

  List<BarChartModel> get educationLevelChartData => (educationLevel ?? [])
      .map(
        (e) => BarChartModel(
      label: e.level ?? '',
      value: (e.percentage ?? 0).toDouble(),
    ),
  )
      .toList();

  List<BarChartModel> get locationChartData => (location ?? [])
      .map(
        (e) => BarChartModel(
      label: e.location ?? '',
      value: (e.percentage ?? 0).toDouble(),
    ),
  )
      .toList();
}

class AgeRange {
  int? count;
  String? range;
  double? percentage;

  AgeRange({this.count, this.range, this.percentage});

  AgeRange.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    range = json['range'];
    percentage = (json['percentage'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    data['range'] = range;
    data['percentage'] = percentage;
    return data;
  }
}

class Gender {
  int? count;
  String? gender;
  double? percentage;

  Gender({this.count, this.gender, this.percentage});

  Gender.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    gender = json['gender'];
    percentage = (json['percentage'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    data['gender'] = gender;
    data['percentage'] = percentage;
    return data;
  }
}

class CommonNames {
  int? count;
  String? name;
  double? percentage;

  CommonNames({this.count, this.name, this.percentage});

  CommonNames.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    name = json['name'];
    percentage = (json['percentage'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    data['name'] = name;
    data['percentage'] = percentage;
    return data;
  }
}

class EmploymentStatus {
  int? count;
  String? status;
  double? percentage;

  EmploymentStatus({this.count, this.status, this.percentage});

  EmploymentStatus.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    status = json['status'];
    percentage = (json['percentage'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    data['status'] = status;
    data['percentage'] = percentage;
    return data;
  }
}

class FieldOfWork {
  int? count;
  String? field;
  double? percentage;

  FieldOfWork({this.count, this.field, this.percentage});

  FieldOfWork.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    field = json['field'];
    percentage = (json['percentage'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    data['field'] = field;
    data['percentage'] = percentage;
    return data;
  }
}

class EducationLevel {
  int? count;
  String? level;
  double? percentage;

  EducationLevel({this.count, this.level, this.percentage});

  EducationLevel.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    level = json['level'];
    percentage = (json['percentage'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    data['level'] = level;
    data['percentage'] = percentage;
    return data;
  }
}

class Location {
  int? count;
  String? location;
  double? percentage;

  Location({this.count, this.location, this.percentage});

  Location.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    location = json['location'];
    percentage = (json['percentage'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    data['location'] = location;
    data['percentage'] = percentage;
    return data;
  }
}

class BarChartModel {
  final String label;
  final double value;

  BarChartModel({required this.label, required this.value});
}