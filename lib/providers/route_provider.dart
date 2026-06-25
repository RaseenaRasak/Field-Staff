import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/route_model.dart';

class RouteProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<RouteModel> _routes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RouteModel> get routes => _routes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRoutes() async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _api.getAuth(ApiConstants.routeList);
    if (result['success']) {
      final list = result['data']['data'] ?? result['data'];
      _routes = (list as List).map((e) => RouteModel.fromJson(e)).toList();
    } else {
      _errorMessage = result['message'];
    }
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}