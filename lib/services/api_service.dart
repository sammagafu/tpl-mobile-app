import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fantasy_team.dart';
import '../models/gameweek.dart';
import '../models/update.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1/';

  /// Returns headers with Content-Type and optional Authorization token
  Map<String, String> _getHeaders({String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Logs in a user and returns access and refresh tokens
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${baseUrl}auth/jwt/create/'),
      headers: _getHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  /// Registers a new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await http.post(
      Uri.parse('${baseUrl}auth/users/'),
      headers: _getHeaders(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'password': password,
        're_password': confirmPassword,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        jsonDecode(response.body)['message'] ?? 'Registration failed',
      );
    }
  }

  /// Refreshes the access token using the refresh token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('${baseUrl}auth/jwt/refresh/'),
      headers: _getHeaders(),
      body: jsonEncode({'refresh': refreshToken}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Token refresh failed: ${response.body}');
    }
  }

  /// Makes an authenticated HTTP request
  Future<http.Response> authenticatedRequest({
    required Uri url,
    required String method,
    required String token,
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final requestHeaders = _getHeaders(token: token)..addAll(headers ?? {});
    switch (method.toUpperCase()) {
      case 'POST':
        return await http.post(
          url,
          headers: requestHeaders,
          body: jsonEncode(body),
        );
      case 'PUT':
        return await http.put(
          url,
          headers: requestHeaders,
          body: jsonEncode(body),
        );
      case 'DELETE':
        return await http.delete(url, headers: requestHeaders);
      default:
        return await http.get(url, headers: requestHeaders);
    }
  }

  /// Fetches list of fantasy teams
  Future<List<FantasyTeam>> fetchFantasyTeams({required String token}) async {
    final response = await authenticatedRequest(
      url: Uri.parse('${baseUrl}teams/'),
      method: 'GET',
      token: token,
    );
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => FantasyTeam.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load fantasy teams: ${response.body}');
    }
  }

  /// Fetches list of game weeks
  Future<List<GameWeek>> fetchGameWeeks({required String token}) async {
    final response = await authenticatedRequest(
      url: Uri.parse('${baseUrl}gameweek/'),
      method: 'GET',
      token: token,
    );
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => GameWeek.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load game weeks: ${response.body}');
    }
  }

  /// Fetches list of updates
  Future<List<Update>> fetchUpdates({required String token}) async {
    final response = await authenticatedRequest(
      url: Uri.parse('${baseUrl}update/'),
      method: 'GET',
      token: token,
    );
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => Update.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load updates: ${response.body}');
    }
  }
}
