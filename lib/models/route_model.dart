class RouteModel {
  final int id;
  final String date;
  final String markInTime;
  final String markOutTime;
  final double markInLat;
  final double markInLng;
  final double markOutLat;
  final double markOutLng;
  final double? distanceKm;

  RouteModel({
    required this.id,
    required this.date,
    required this.markInTime,
    required this.markOutTime,
    required this.markInLat,
    required this.markInLng,
    required this.markOutLat,
    required this.markOutLng,
    this.distanceKm,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      markInTime: json['mark_in_time'] ?? '',
      markOutTime: json['mark_out_time'] ?? '',
      markInLat: double.tryParse(json['mark_in_lat']?.toString() ?? '0') ?? 0,
      markInLng: double.tryParse(json['mark_in_lng']?.toString() ?? '0') ?? 0,
      markOutLat: double.tryParse(json['mark_out_lat']?.toString() ?? '0') ?? 0,
      markOutLng: double.tryParse(json['mark_out_lng']?.toString() ?? '0') ?? 0,
      distanceKm: double.tryParse(json['distance_km']?.toString() ?? ''),
    );
  }
}