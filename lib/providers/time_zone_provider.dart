import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimeZoneItem {
  final List<String> timeZoneNames;
  
  TimeZoneItem({required this.timeZoneNames});
  
  bool get isMerged => timeZoneNames.length > 1;
  
  Map<String, dynamic> toJson() => {
    'timeZoneNames': timeZoneNames,
  };
  
  factory TimeZoneItem.fromJson(Map<String, dynamic> json) {
    return TimeZoneItem(
      timeZoneNames: List<String>.from(json['timeZoneNames']),
    );
  }
}

class TimeZoneProvider with ChangeNotifier {
  static const String _keySelectedItems = 'selected_items_v2';
  static const String _keyHasConfigured = 'has_configured';

  List<TimeZoneItem> _selectedItems = [
    TimeZoneItem(timeZoneNames: ['Asia/Kolkata']),
    TimeZoneItem(timeZoneNames: ['America/Toronto']),
    TimeZoneItem(timeZoneNames: ['Europe/London']),
    TimeZoneItem(timeZoneNames: ['UTC']),
  ];

  bool _hasConfigured = false;

  TimeZoneProvider() {
    _loadFromPrefs();
  }

  List<TimeZoneItem> get selectedItems => _selectedItems;
  bool get hasConfigured => _hasConfigured;

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? itemsJson = prefs.getString(_keySelectedItems);
    if (itemsJson != null) {
      final List<dynamic> decoded = jsonDecode(itemsJson);
      _selectedItems = decoded.map((item) => TimeZoneItem.fromJson(item)).toList();
    }
    _hasConfigured = prefs.getBool(_keyHasConfigured) ?? false;
    notifyListeners();
  }

  Future<void> addTimeZone(String timeZone) async {
    // Check if timezone already exists in any item
    bool alreadyExists = _selectedItems.any((item) => item.timeZoneNames.contains(timeZone));
    if (!alreadyExists) {
      _selectedItems.add(TimeZoneItem(timeZoneNames: [timeZone]));
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> removeTimeZone(TimeZoneItem item) async {
    _selectedItems.remove(item);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> mergeItems(int index) async {
    if (index >= 0 && index < _selectedItems.length - 1) {
      final item1 = _selectedItems[index];
      final item2 = _selectedItems[index + 1];
      
      // We only support merging two single items currently, or appending
      final List<String> merged = [...item1.timeZoneNames, ...item2.timeZoneNames];
      
      // Limit to 2 for now as per user request "two different timezones"
      if (merged.length <= 2) {
        _selectedItems.removeAt(index); // Remove item2 first to maintain correct index
        _selectedItems.removeAt(index); // Remove item1
        _selectedItems.insert(index, TimeZoneItem(timeZoneNames: merged));
        await _saveToPrefs();
        notifyListeners();
      }
    }
  }

  Future<void> unmergeItem(int index) async {
    if (index >= 0 && index < _selectedItems.length) {
      final item = _selectedItems[index];
      if (item.isMerged) {
        _selectedItems.removeAt(index);
        for (int i = 0; i < item.timeZoneNames.length; i++) {
          _selectedItems.insert(index + i, TimeZoneItem(timeZoneNames: [item.timeZoneNames[i]]));
        }
        await _saveToPrefs();
        notifyListeners();
      }
    }
  }

  Future<void> reorderTimeZones(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final TimeZoneItem item = _selectedItems.removeAt(oldIndex);
    _selectedItems.insert(newIndex, item);
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
    final String itemsJson = jsonEncode(_selectedItems.map((item) => item.toJson()).toList());
    await prefs.setString(_keySelectedItems, itemsJson);
  }
}
