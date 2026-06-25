import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/leave_model.dart';

class LeaveProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<LeaveModel> _leaves = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  List<LeaveModel> get leaves => _leaves;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> fetchLeaves({
    required int employeeId,
    String leaveType = 'all',
    String? month,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _api.postAuth(ApiConstants.leaves, {
      'employee_id': employeeId,
      'leave_type': leaveType,
      if (month != null) 'month': month,
    });

    if (result['success']) {
      final list = result['data']['data'] ?? result['data'];
      _leaves = (list as List).map((e) => LeaveModel.fromJson(e)).toList();
    } else {
      _errorMessage = result['message'];
    }
    _setLoading(false);
  }

  Future<bool> applyLeave(Map<String, dynamic> leaveData) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    final result = await _api.postAuth(ApiConstants.applyLeave, leaveData);

    if (result['success']) {
      _successMessage = 'Leave applied successfully!';
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