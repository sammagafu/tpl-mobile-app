import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gameweek.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class GameWeekProvider with ChangeNotifier {
  List<GameWeek> _gameWeeks = [];
  bool _isLoading = false;
  String? _error;
  static const String _cacheKey = 'game_weeks_cache';
  static const String _cacheTimestampKey = 'game_weeks_cache_timestamp';
  static const int _cacheDurationHours = 24;

  List<GameWeek> get gameWeeks => _gameWeeks;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> fetchGameWeeks(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token == null) {
        throw Exception('No authentication token available');
      }

      // Try to load from cache first
      final cachedGameWeeks = await _loadFromCache();
      if (cachedGameWeeks != null) {
        _gameWeeks = cachedGameWeeks;
        notifyListeners();
      }

      // Fetch from API
      final gameWeeks = await ApiService().fetchGameWeeks(
        token: authProvider.token!,
      );
      _gameWeeks = gameWeeks;

      // Save to cache
      await _saveToCache(gameWeeks);
    } catch (e) {
      // If API fails, try to use cached data
      final cachedGameWeeks = await _loadFromCache();
      if (cachedGameWeeks != null) {
        _gameWeeks = cachedGameWeeks;
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

  Future<List<GameWeek>?> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = prefs.getString(_cacheKey);
    final cacheTimestamp = prefs.getString(_cacheTimestampKey);

    if (cacheData != null && cacheTimestamp != null) {
      final timestamp = DateTime.parse(cacheTimestamp);
      if (DateTime.now().difference(timestamp).inHours < _cacheDurationHours) {
        final List<dynamic> jsonData = jsonDecode(cacheData);
        return jsonData.map((json) => GameWeek.fromJson(json)).toList();
      } else {
        // Cache expired, clear it
        await prefs.remove(_cacheKey);
        await prefs.remove(_cacheTimestampKey);
      }
    }
    return null;
  }

  Future<void> _saveToCache(List<GameWeek> gameWeeks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(
      gameWeeks
          .map(
            (gw) => {
              'id': gw.id,
              'week_number': gw.weekNumber,
              'season': {'id': gw.seasonId},
              'start_date': gw.startDate.toIso8601String(),
              'end_date': gw.endDate.toIso8601String(),
              'fixtures': gw.fixtures
                  .map(
                    (f) => {
                      'id': f.id,
                      'home_team': {
                        'id': f.homeTeam.id,
                        'name': f.homeTeam.name,
                        'short_name': f.homeTeam.shortName,
                        'logo': f.homeTeam.logo,
                      },
                      'away_team': {
                        'id': f.awayTeam.id,
                        'name': f.awayTeam.name,
                        'short_name': f.awayTeam.shortName,
                        'logo': f.awayTeam.logo,
                      },
                      'start_time': f.startTime.toIso8601String(),
                      'stadium': f.stadium,
                      'home_team_score': f.homeTeamScore,
                      'away_team_score': f.awayTeamScore,
                      'gameweek': f.gameweekId,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
    );
    await prefs.setString(_cacheKey, jsonData);
    await prefs.setString(_cacheTimestampKey, DateTime.now().toIso8601String());
  }
}
