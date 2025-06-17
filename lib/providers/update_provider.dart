import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/update.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class UpdateProvider with ChangeNotifier {
  List<Update> _updates = [];
  bool _isLoading = false;
  String? _error;
  static const String _cacheKey = 'updates_cache';
  static const String _cacheTimestampKey = 'updates_cache_timestamp';
  static const int _cacheDurationHours = 24;

  List<Update> get updates => _updates;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> fetchUpdates(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token == null) {
        throw Exception('No authentication token available');
      }

      // Try to load from cache first
      final cachedUpdates = await _loadFromCache();
      if (cachedUpdates != null) {
        _updates = cachedUpdates;
        notifyListeners();
      }

      // Fetch from API
      final updates = await ApiService().fetchUpdates(
        token: authProvider.token!,
      );
      _updates = updates;

      // Save to cache
      await _saveToCache(updates);
    } catch (e) {
      // If API fails, try to use cached data
      final cachedUpdates = await _loadFromCache();
      if (cachedUpdates != null) {
        _updates = cachedUpdates;
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

  Future<List<Update>?> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = prefs.getString(_cacheKey);
    final cacheTimestamp = prefs.getString(_cacheTimestampKey);

    if (cacheData != null && cacheTimestamp != null) {
      final timestamp = DateTime.parse(cacheTimestamp);
      if (DateTime.now().difference(timestamp).inHours < _cacheDurationHours) {
        final List<dynamic> jsonData = jsonDecode(cacheData);
        return jsonData.map((json) => Update.fromJson(json)).toList();
      } else {
        // Cache expired, clear it
        await prefs.remove(_cacheKey);
        await prefs.remove(_cacheTimestampKey);
      }
    }
    return null;
  }

  Future<void> _saveToCache(List<Update> updates) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(
      updates
          .map(
            (u) => {
              'id': u.id,
              'cover': u.cover,
              'title': u.title,
              'slug': u.slug,
              'update': u.update,
              'timestamp': u.timestamp.toIso8601String(),
              'category': {
                'id': u.category.id,
                'name': u.category.name,
                'slug': u.category.slug,
              },
            },
          )
          .toList(),
    );
    await prefs.setString(_cacheKey, jsonData);
    await prefs.setString(_cacheTimestampKey, DateTime.now().toIso8601String());
  }
}
