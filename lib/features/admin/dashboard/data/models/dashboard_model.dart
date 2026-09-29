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

  List<BarChartModel> get genderChartData {
    final merged = <String, double>{};
    for (final e in gender ?? []) {
      final raw = (e.gender ?? '').trim();
      if (raw.isEmpty) continue;
      final key = _genderKey(raw);
      merged[key] =
          (merged[key] ?? 0) + (e.count ?? e.percentage ?? 0).toDouble();
    }

    return merged.entries
        .map(
          (e) => BarChartModel(
            label: e.key.toUpperCase(),
            value: e.value,
          ),
        )
        .toList();
  }

  static String _genderKey(String raw) {
    final lower = raw.toLowerCase();
    if (lower.startsWith('f')) return 'female';
    if (lower.startsWith('m')) return 'male';
    return lower;
  }

  List<BarChartModel> get commonNamesChartData => (commonNames ?? [])
      .map(
        (e) => BarChartModel(
      label: e.name ?? '',
      value: (e.percentage ?? 0).toDouble(),
    ),
  )
      .toList();

  List<BarChartModel> get employmentStatusChartData {
    final merged = <String, double>{};
    for (final e in employmentStatus ?? []) {
      final key = _employmentKey(e.status);
      if (key.isEmpty) continue;
      final count = e.count ?? 0;
      if (count <= 0) continue;
      merged[key] = (merged[key] ?? 0) + count.toDouble();
    }

    return merged.entries
        .map(
          (e) => BarChartModel(
            label: _employmentLabel(e.key),
            value: e.value,
          ),
        )
        .toList();
  }

  static String _employmentKey(String? raw) {
    final lower = (raw ?? '').trim().toLowerCase();
    if (lower.isEmpty) return '';
    if (lower == 'self-employed' || lower == 'self employed') {
      return 'self-employed';
    }
    if (lower == 'unemployed') return 'unemployed';
    if (lower == 'student') return 'student';
    if (lower == 'employed') return 'employed';
    return '';
  }

  static String _employmentLabel(String key) {
    switch (key) {
      case 'self-employed':
        return 'Self-employed';
      case 'unemployed':
        return 'Unemployed';
      case 'student':
        return 'Student';
      case 'employed':
        return 'Employed';
      default:
        if (key.isEmpty) return key;
        return key[0].toUpperCase() + key.substring(1);
    }
  }

  List<BarChartModel> get fieldOfWorkChartData => (fieldOfWork ?? [])
      .map(
        (e) => BarChartModel(
      label: e.field ?? '',
      value: (e.percentage ?? 0).toDouble(),
    ),
  )
      .toList();

  List<BarChartModel> get educationLevelChartData => (educationLevel ?? [])
      .where((e) => (e.count ?? 0) > 0 && (e.level ?? '').trim().isNotEmpty)
      .map(
        (e) => BarChartModel(
          label: e.level ?? '',
          value: (e.count ?? 0).toDouble(),
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
    count = _parseCount(json['count'] ?? json['value']);
    status = json['status'] ?? json['employmentStatus'];
    percentage = _parsePercentage(json['percentage']);
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
    count = _parseCount(json['count'] ?? json['value']);
    level = json['level'];
    percentage = _parsePercentage(json['percentage']);
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

int? _parseCount(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value.toString());
}

double? _parsePercentage(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}