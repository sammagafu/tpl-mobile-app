import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fantasy_team.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class FantasyTeamProvider with ChangeNotifier {
  List<FantasyTeam> _teams = [];
  bool _isLoading = false;
  String? _error;
  static const String _cacheKey = 'fantasy_teams_cache';
  static const String _cacheTimestampKey = 'fantasy_teams_cache_timestamp';
  static const int _cacheDurationHours = 24;

  List<FantasyTeam> get teams => _teams;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> fetchTeams(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token == null) {
        throw Exception('No authentication token available');
      }

      final cachedTeams = await _loadFromCache();
      if (cachedTeams != null) {
        _teams = cachedTeams;
        notifyListeners();
      }

      final teams = await ApiService().fetchFantasyTeams(
        token: authProvider.token!,
      );
      _teams = teams;
      await _saveToCache(teams);
    } catch (e) {
      final cachedTeams = await _loadFromCache();
      if (cachedTeams != null) {
        _teams = cachedTeams;
        _error =
            'Using cached data: ${e.toString().replaceFirst('Exception: ', '')}';
      } else {
        _error = e.toString().replaceFirst('Exception: ', '');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<FantasyTeam>?> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = prefs.getString(_cacheKey);
    final cacheTimestamp = prefs.getString(_cacheTimestampKey);

    if (cacheData != null && cacheTimestamp != null) {
      final timestamp = DateTime.parse(cacheTimestamp);
      if (DateTime.now().difference(timestamp).inHours < _cacheDurationHours) {
        final List<dynamic> jsonData = jsonDecode(cacheData);
        return jsonData.map((json) => FantasyTeam.fromJson(json)).toList();
      } else {
        await prefs.remove(_cacheKey);
        await prefs.remove(_cacheTimestampKey);
      }
    }
    return null;
  }

  Future<void> _saveToCache(List<FantasyTeam> teams) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(
      teams
          .map(
            (t) => {
              'id': t.id,
              'user': t.userId,
              'name': t.name,
              'budget': t.budget.toString(),
              'total_points': t.totalPoints,
              'created_at': t.createdAt.toIso8601String(),
              'players': t.players.map((p) => p.id).toList(),
            },
          )
          .toList(),
    );
    await prefs.setString(_cacheKey, jsonData);
    await prefs.setString(_cacheTimestampKey, DateTime.now().toIso8601String());
  }
}
