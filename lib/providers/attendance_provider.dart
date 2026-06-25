import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../core/services/location_service.dart';
import '../models/attendance_model.dart';

class AttendanceProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final LocationService _locationService = LocationService();

  AttendanceModel? _attendance;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  AttendanceModel? get attendance => _attendance;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> fetchAttendanceStatus() async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _api.getAuth(ApiConstants.attendanceStatus);
    if (result['success']) {
      final data = result['data']['data'] ?? result['data'];
      _attendance = AttendanceModel.fromJson(data);
    } else {
      _errorMessage = result['message'];
    }
    _setLoading(false);
  }

  Future<bool> markAttendance(String status) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    // Get GPS location
    final position = await _locationService.getCurrentLocation();
    if (position == null) {
      _errorMessage = 'Unable to get location. Please enable GPS.';
      _setLoading(false);
      return false;
    }

    final result = await _api.postAuth(ApiConstants.attendanceMark, {
      'attendance_status': status, // 'mark_in' or 'mark_out'
      'latitude': position.latitude,
      'longitude': position.longitude,
    });

    if (result['success']) {
      _successMessage = status == 'mark_in' ? 'Marked In successfully!' : 'Marked Out successfully!';
      await fetchAttendanceStatus(); // Refresh status
      _setLoading(false);
      return true;
    } else {
      _errorMessage = result['message'];
      _setLoading(false);
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}