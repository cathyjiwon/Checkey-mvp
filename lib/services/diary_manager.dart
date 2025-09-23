import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class DiaryManager with ChangeNotifier {
  // Map의 value를 List로 변경하여 하루에 여러 기록을 저장
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
            // value가 List인 경우, List<Map<String, dynamic>>으로 변환
            final List<Map<String, dynamic>> entries =
                value.cast<Map<String, dynamic>>();
            return MapEntry(key, entries);
          } else if (value is Map) {
            // 기존에 단일 Map으로 저장된 경우, 리스트로 변환하여 처리
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

    // 기존 기록이 있는지 확인하고 리스트에 추가하거나 새로 생성
    if (_diaryEntries.containsKey(dayString)) {
      _diaryEntries[dayString]!.add(newEntry);
    } else {
      _diaryEntries[dayString] = [newEntry];
    }

    notifyListeners();
    _saveToPrefs();
  }
}