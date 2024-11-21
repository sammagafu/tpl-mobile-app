// lib/providers/auth_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const baseurl = "http://localhost:8000/api/v1/";

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _refreshToken;
  DateTime? _expiryDate;

  String? get token => _token;

  bool get isAuthenticated {
    return _token != null && _expiryDate != null && _expiryDate!.isAfter(DateTime.now());
  }

  Future<void> login(String email, String password) async {
    final url = Uri.parse('${baseurl}auth/jwt/create/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _token = responseData['access'];
        _refreshToken = responseData['refresh'];
        _expiryDate = _parseJwtExpiry(_token!);

        // Store token data in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('refreshToken', _refreshToken!);
        await prefs.setString('expiryDate', _expiryDate!.toIso8601String());

        notifyListeners();
      } else {
        throw Exception('Failed to login: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Failed to login: ${error.toString()}');
    }
  }

  Future<void> logout() async {
    _token = null;
    _refreshToken = null;
    _expiryDate = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('refreshToken');
    await prefs.remove('expiryDate');
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) {
      return;
    }
    final storedToken = prefs.getString('token');
    final storedRefreshToken = prefs.getString('refreshToken');
    final expiryDateStr = prefs.getString('expiryDate');
    if (expiryDateStr == null) return;
    final expiryDate = DateTime.parse(expiryDateStr);

    if (expiryDate.isBefore(DateTime.now())) {
      // Token is expired, try to refresh it
      final success = await _refreshTokenFunction(storedRefreshToken!);
      if (!success) {
        await logout();
        return;
      }
    } else {
      _token = storedToken;
      _refreshToken = storedRefreshToken;
      _expiryDate = expiryDate;
      notifyListeners();
    }
  }

  Future<bool> _refreshTokenFunction(String refreshToken) async {
    final url = Uri.parse('${baseurl}auth/jwt/refresh/');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _token = responseData['access'];
        _expiryDate = _parseJwtExpiry(_token!);

        // Update stored token and expiry date
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('expiryDate', _expiryDate!.toIso8601String());

        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }

  Future<http.Response> authenticatedRequest(
      Uri url, {
        String method = 'GET',
        Map<String, String>? headers,
        dynamic body,
      }) async {
    if (_token == null) {
      throw Exception('Not authenticated');
    }

    // Refresh token if it's about to expire
    if (_expiryDate != null && _expiryDate!.isBefore(DateTime.now().add(Duration(minutes: 5)))) {
      await _refreshTokenFunction(_refreshToken!);
    }

    // Include the token in the headers
    final requestHeaders = {
      'Authorization': 'Bearer $_token',
      'Content-Type': 'application/json',
      ...?headers,
    };

    http.Response response;
    switch (method.toUpperCase()) {
      case 'POST':
        response = await http.post(url, headers: requestHeaders, body: json.encode(body));
        break;
      case 'PUT':
        response = await http.put(url, headers: requestHeaders, body: json.encode(body));
        break;
      case 'DELETE':
        response = await http.delete(url, headers: requestHeaders);
        break;
      default:
        response = await http.get(url, headers: requestHeaders);
    }

    if (response.statusCode == 401) {
      // Unauthorized, token might be expired
      final refreshSuccess = await _refreshTokenFunction(_refreshToken!);
      if (refreshSuccess) {
        // Retry the request
        return authenticatedRequest(url, method: method, headers: headers, body: body);
      } else {
        throw Exception('Authentication failed');
      }
    }

    return response;
  }

  DateTime _parseJwtExpiry(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT token');
    }
    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final payloadMap = json.decode(payload);
    if (!payloadMap.containsKey('exp')) {
      throw Exception('Token does not contain expiry information');
    }
    final expiry = DateTime.fromMillisecondsSinceEpoch(payloadMap['exp'] * 1000);
    return expiry;
  }
}
