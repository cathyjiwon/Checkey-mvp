// lib/services/diary_manager.dart

// 필요한 import를 추가합니다.
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiaryManager with ChangeNotifier {
  Map<String, Map<String, dynamic>> _diaryEntries = {};
  Map<String, Map<String, dynamic>> get diaryEntries => _diaryEntries;

  // 데이터 로딩 메서드 (아마도 여기에 오류가 있을 것입니다)
  Future<void> loadDiaryEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? diaryJson = prefs.getString('diaryEntries');
    if (diaryJson != null) {
      try {
        final Map<String, dynamic> decodedData = json.decode(diaryJson);
        _diaryEntries = decodedData.map((key, value) {
          return MapEntry(key, Map<String, dynamic>.from(value));
        });
      } catch (e) {
        print('Error decoding diary data: $e');
        _diaryEntries = {};
      }
    }
    notifyListeners();
  }

  // 데이터 저장 메서드
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = json.encode(_diaryEntries);
    await prefs.setString('diaryEntries', jsonString);
  }
  
  // 나머지 메서드들은 그대로 유지
  void saveDiaryEntry(
    DateTime day,
    String status,
    List<String> frequentSymptoms, {
    String customSymptom = '',
    List<String> otherSymptoms = const [],
    String? timestamp,
  }) {
    final dayString = DateFormat('yyyy-MM-dd').format(day);
    _diaryEntries[dayString] = {
      'status': status,
      'frequentSymptoms': frequentSymptoms,
      'customSymptom': customSymptom,
      'otherSymptoms': otherSymptoms,
      'timestamp': timestamp,
    };
    notifyListeners();
    _saveToPrefs();
  }
}