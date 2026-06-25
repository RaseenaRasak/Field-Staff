class AttendanceModel {
  final String? markInTime;
  final String? markOutTime;
  final String? status; // 'marked_in', 'marked_out', 'not_marked'
  final double? markInLat;
  final double? markInLng;
  final double? markOutLat;
  final double? markOutLng;

  AttendanceModel({
    this.markInTime,
    this.markOutTime,
    this.status,
    this.markInLat,
    this.markInLng,
    this.markOutLat,
    this.markOutLng,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      markInTime: json['mark_in_time'],
      markOutTime: json['mark_out_time'],
      status: json['status'],
      markInLat: double.tryParse(json['mark_in_lat']?.toString() ?? ''),
      markInLng: double.tryParse(json['mark_in_lng']?.toString() ?? ''),
      markOutLat: double.tryParse(json['mark_out_lat']?.toString() ?? ''),
      markOutLng: double.tryParse(json['mark_out_lng']?.toString() ?? ''),
    );
  }

  bool get isMarkedIn => status == 'marked_in';
  bool get isMarkedOut => status == 'marked_out';
  bool get notMarked => status == null || status == 'not_marked';
}