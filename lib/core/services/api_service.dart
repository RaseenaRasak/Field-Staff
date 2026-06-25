import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Retrieve stored auth token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Build headers with optional auth token
  Future<Map<String, String>> _headers({bool requiresAuth = false}) async {
    final headers = {'Content-Type': 'application/json', 'Accept': 'application/json'};
    if (requiresAuth) {
      final token = await _getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// POST request (no auth)
  Future<Map<String, dynamic>> post(String url, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await _headers(),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// POST request (with auth token)
  Future<Map<String, dynamic>> postAuth(String url, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await _headers(requiresAuth: true),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// GET request (with auth token)
  Future<Map<String, dynamic>> getAuth(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await _headers(requiresAuth: true),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {'success': true, 'data': body};
    } else {
      return {
        'success': false,
        'message': body['message'] ?? 'Something went wrong',
      };
    }
  }
}