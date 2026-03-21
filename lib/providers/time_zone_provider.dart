import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimeZoneProvider with ChangeNotifier {
  static const String _keySelectedTimeZones = 'selected_time_zones';
  static const String _keyHasConfigured = 'has_configured';

  List<String> _selectedTimeZones = [
    'Asia/Kolkata',
    'America/Toronto',
    'Europe/London',
    'UTC',
  ];

  bool _hasConfigured = false;

  TimeZoneProvider() {
    _loadFromPrefs();
  }

  List<String> get selectedTimeZones => _selectedTimeZones;
  bool get hasConfigured => _hasConfigured;

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedTimeZones = prefs.getStringList(_keySelectedTimeZones) ?? _selectedTimeZones;
    _hasConfigured = prefs.getBool(_keyHasConfigured) ?? false;
    notifyListeners();
  }

  Future<void> addTimeZone(String timeZone) async {
    if (!_selectedTimeZones.contains(timeZone)) {
      _selectedTimeZones.add(timeZone);
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> removeTimeZone(String timeZone) async {
    _selectedTimeZones.remove(timeZone);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> reorderTimeZones(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final String item = _selectedTimeZones.removeAt(oldIndex);
    _selectedTimeZones.insert(newIndex, item);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> setConfigured(bool value) async {
    _hasConfigured = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasConfigured, value);
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keySelectedTimeZones, _selectedTimeZones);
  }
}
