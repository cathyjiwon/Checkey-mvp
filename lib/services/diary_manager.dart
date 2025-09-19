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

  void saveDiaryEntry(DateTime date, String status, List<String> symptoms) {
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    _diaryEntries[dateString] = {
      'status': status,
      'symptoms': symptoms,
    };
    _saveDiaryEntries();
    notifyListeners();
  }
}