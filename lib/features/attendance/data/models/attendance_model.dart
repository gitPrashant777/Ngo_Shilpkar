class AttendanceLocation {
  final String? district;
  final String? village;

  AttendanceLocation({this.district, this.village});

  factory AttendanceLocation.fromJson(Map<String, dynamic> json) {
    return AttendanceLocation(
      district: json['district'],
      village: json['village'],
    );
  }

  Map<String, dynamic> toJson() => {
    'district': district,
    'village': village,
  };
}

class AttendanceModel {
  final String? id;
  final String? employeeName;
  final String date;
  final String? punchIn;
  final String? punchOut;
  final String status;
  final double? totalHours;
  final AttendanceLocation? location;

  AttendanceModel({
    this.id,
    this.employeeName,
    required this.date,
    this.punchIn,
    this.punchOut,
    required this.status,
    this.totalHours,
    this.location,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['attendanceId']?.toString() ?? json['_id']?.toString(),
      employeeName: json['employeeName']?.toString(),
      date: json['date']?.toString() ?? '',
      punchIn: json['punchIn']?.toString(),
      punchOut: json['punchOut']?.toString(),
      status: json['status']?.toString() ?? 'ABSENT',
      totalHours: (json['totalHours'] as num?)?.toDouble(),
      location: json['location'] != null
          ? AttendanceLocation.fromJson(json['location'])
          : null,
    );
  }
}
