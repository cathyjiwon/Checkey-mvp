// lib/services/diary_manager.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class DiaryManager with ChangeNotifier {
  Map<String, List<Map<String, dynamic>>> _diaryEntries = {};

  Map<String, List<Map<String, dynamic>>> get diaryEntries => _diaryEntries;

  DiaryManager() {
    loadDiaryEntries();
  }

  Future<void> loadDiaryEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? diaryJson = prefs.getString('diaryEntries');
    if (diaryJson != null) {
      try {
        final Map<String, dynamic> decodedData = json.decode(diaryJson);
        _diaryEntries = decodedData.map((key, value) {
          if (value is List) {
            final List<Map<String, dynamic>> entries =
                value.cast<Map<String, dynamic>>();
            return MapEntry(key, entries);
          } else if (value is Map) {
            return MapEntry(key, [value.cast<String, dynamic>()]);
          }
          return MapEntry(key, []);
        });
      } catch (e) {
        print('Error decoding diary data: $e');
        _diaryEntries = {};
      }
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = json.encode(_diaryEntries);
    await prefs.setString('diaryEntries', jsonString);
  }

  void saveDiaryEntry(
    DateTime day,
    String status,
    List<String> frequentSymptoms, {
    String? customSymptom,
    List<String>? otherSymptoms,
    String? timestamp,
  }) {
    final dayString = DateFormat('yyyy-MM-dd').format(day);

    final newEntry = {
      'status': status,
      'frequentSymptoms': frequentSymptoms,
      'customSymptom': customSymptom,
      'otherSymptoms': otherSymptoms,
      'timestamp': timestamp,
    };

    if (_diaryEntries.containsKey(dayString)) {
      _diaryEntries[dayString]!.add(newEntry);
    } else {
      _diaryEntries[dayString] = [newEntry];
    }

    notifyListeners();
    _saveToPrefs();
  }

  // 일기 기록을 삭제하는 새로운 메서드 추가
  void deleteDiaryEntry(String date, String timestamp) {
    if (_diaryEntries.containsKey(date)) {
      _diaryEntries[date]!.removeWhere((entry) => entry['timestamp'] == timestamp);
      if (_diaryEntries[date]!.isEmpty) {
        _diaryEntries.remove(date);
      }
      _saveToPrefs();
      notifyListeners();
    }
  }

  void updateDiaryEntryTimestamp(
      DateTime day, String oldTimestamp, String newTimestamp) {
    final dayString = DateFormat('yyyy-MM-dd').format(day);

    if (_diaryEntries.containsKey(dayString)) {
      final entries = _diaryEntries[dayString]!;
      for (var entry in entries) {
        if (entry['timestamp'] == oldTimestamp) {
          entry['timestamp'] = newTimestamp;
          break;
        }
      }
      notifyListeners();
      _saveToPrefs();
    }
  }
}