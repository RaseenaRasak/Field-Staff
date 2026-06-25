class LeaveModel {
  final int id;
  final String leaveMode;   // half_day or full_day
  final String leaveType;
  final String startDate;
  final String endDate;
  final String reason;
  final String status;      // pending, approved, rejected
  final String createdAt;

  LeaveModel({
    required this.id,
    required this.leaveMode,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      id: json['id'] ?? 0,
      leaveMode: json['leave_mode'] ?? '',
      leaveType: json['leave_type'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? '',
    );
  }
}