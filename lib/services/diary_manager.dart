// lib/services/diary_manager.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class DiaryManager with ChangeNotifier {
  Map<String, dynamic> _diaryEntries = {};

  Map<String, dynamic> get diaryEntries => _diaryEntries;

  DiaryManager() {
    _loadDiaryEntries();
  }

  Future<void> _loadDiaryEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final diaryEntriesString = prefs.getString('diary_entries');
    if (diaryEntriesString != null) {
      _diaryEntries = Map<String, dynamic>.from(json.decode(diaryEntriesString));
    }
    notifyListeners();
  }

  Future<void> _saveDiaryEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('diary_entries', json.encode(_diaryEntries));
  }

  void saveDiaryEntry(
    DateTime day,
    String status,
    List<String> frequentSymptoms, {
    String customSymptom = '',
    List<String> otherSymptoms = const [],
  }) {
    final dayString = DateFormat('yyyy-MM-dd').format(day);
    _diaryEntries[dayString] = {
      'status': status,
      'frequentSymptoms': frequentSymptoms, // 자주 나타나는 증상 (선택된 칩)
      'customSymptom': customSymptom, // 자세한 증상 (텍스트)
      'otherSymptoms': otherSymptoms, // 다른 증상 (입력된 칩)
    };
    notifyListeners();
    _saveDiaryEntries();
  }
}