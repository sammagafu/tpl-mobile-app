import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Add this import
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _refreshToken;
  DateTime? _expiryDate;

  String? get token => _token;

  bool get isAuthenticated {
    return _token != null &&
        _expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now());
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await ApiService().login(email, password);
      _token = response['access'];
      _refreshToken = response['refresh'];
      _expiryDate = _parseJwtExpiry(_token!);

      // Store token data in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('refreshToken', _refreshToken!);
      await prefs.setString('expiryDate', _expiryDate!.toIso8601String());

      notifyListeners();
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
    try {
      final response = await ApiService().refreshToken(refreshToken);
      _token = response['access'];
      _expiryDate = _parseJwtExpiry(_token!);

      // Update stored token and expiry date
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('expiryDate', _expiryDate!.toIso8601String());

      notifyListeners();
      return true;
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
    if (_expiryDate != null &&
        _expiryDate!.isBefore(DateTime.now().add(const Duration(minutes: 5)))) {
      final success = await _refreshTokenFunction(_refreshToken!);
      if (!success) {
        throw Exception('Token refresh failed');
      }
    }

    final response = await ApiService().authenticatedRequest(
      url: url,
      method: method,
      token: _token!,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 401) {
      // Unauthorized, try refreshing token
      final refreshSuccess = await _refreshTokenFunction(_refreshToken!);
      if (refreshSuccess) {
        // Retry the request
        return ApiService().authenticatedRequest(
          url: url,
          method: method,
          token: _token!,
          headers: headers,
          body: body,
        );
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
    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final payloadMap = json.decode(payload);
    if (!payloadMap.containsKey('exp')) {
      throw Exception('Token does not contain expiry information');
    }
    final expiry = DateTime.fromMillisecondsSinceEpoch(
      payloadMap['exp'] * 1000,
    );
    return expiry;
  }
}
