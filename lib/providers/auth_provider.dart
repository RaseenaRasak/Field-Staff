import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;

  /// Check stored session on app start
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      _isLoggedIn = true;
      // Restore basic user info
      _user = UserModel(
        id: prefs.getInt('user_id') ?? 0,
        firstName: prefs.getString('first_name') ?? '',
        lastName: prefs.getString('last_name') ?? '',
        email: prefs.getString('email') ?? '',
        mobileNumber: prefs.getString('mobile_number') ?? '',
        token: token,
      );
    }
    notifyListeners();
  }

  Future<bool> login(String mobile, String password) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _api.post(ApiConstants.login, {
      'mobile_number': mobile,
      'password': password,
    });

    if (result['success']) {
      final data = result['data'];
      // Adjust key path based on actual API response shape
      final userData = data['data'] ?? data['user'] ?? data;
      _user = UserModel.fromJson(userData);

      final token = userData['token'] ?? data['token'] ?? '';
      await _saveSession(_user!, token);
      _isLoggedIn = true;
      _setLoading(false);
      return true;
    } else {
      _errorMessage = result['message'];
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> formData) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _api.post(ApiConstants.register, formData);

    if (result['success']) {
      _setLoading(false);
      return true;
    } else {
      _errorMessage = result['message'];
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> _saveSession(UserModel user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setInt('user_id', user.id);
    await prefs.setString('first_name', user.firstName);
    await prefs.setString('last_name', user.lastName);
    await prefs.setString('email', user.email);
    await prefs.setString('mobile_number', user.mobileNumber);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}