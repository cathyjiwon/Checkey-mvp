// lib/services/symptom_manager.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SymptomManager extends ChangeNotifier {
  List<String> _frequentSymptoms = [];
  List<String> _medications = [];
  Map<String, Map<String, bool>> _medicationHistory = {};
  Map<String, dynamic> _diaryEntries = {};

  SymptomManager() {
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await _loadFrequentSymptoms();
    await _loadMedications();
    await _loadMedicationHistory();
    await _loadDiaryEntries();
    notifyListeners();
  }

  // 자주 발생하는 증상
  List<String> get frequentSymptoms => _frequentSymptoms;

  void addFrequentSymptom(String symptom) {
    if (!_frequentSymptoms.contains(symptom)) {
      _frequentSymptoms.add(symptom);
      notifyListeners();
      _saveFrequentSymptoms();
    }
  }

  void removeFrequentSymptom(String symptom) {
    _frequentSymptoms.remove(symptom);
    notifyListeners();
    _saveFrequentSymptoms();
  }

  // 복용 중인 약물
  List<String> get medications => _medications;

  void addMedication(String medication) {
    if (!_medications.contains(medication)) {
      _medications.add(medication);
      notifyListeners();
      _saveMedications();
    }
  }

  void removeMedication(String medication) {
    _medications.remove(medication);
    notifyListeners();
    _saveMedications();
  }

  // 약물 복용 기록
  bool isMedicationTaken(DateTime date, String medication) {
    final key = _formatDate(date);
    return _medicationHistory[key]?[medication] ?? false;
  }

  void setMedicationTaken(DateTime date, String medication, bool isTaken) {
    final key = _formatDate(date);
    if (_medicationHistory[key] == null) {
      _medicationHistory[key] = {};
    }
    _medicationHistory[key]![medication] = isTaken;
    notifyListeners();
    _saveMedicationHistory();
  }

  // 건강 일기 기록
  Map<String, dynamic> get diaryEntries => _diaryEntries;

  void saveDiaryEntry(DateTime date, String status, List<String> symptoms) {
    final key = _formatDate(date);
    _diaryEntries[key] = {
      'status': status,
      'symptoms': symptoms,
    };
    notifyListeners();
    _saveDiaryEntries();
  }

  // 데이터 저장 및 불러오기
  Future<void> _loadFrequentSymptoms() async {
    final prefs = await SharedPreferences.getInstance();
    final symptomsJson = prefs.getString('frequent_symptoms');
    if (symptomsJson != null) {
      try {
        final List<dynamic> list = jsonDecode(symptomsJson);
        _frequentSymptoms = list.cast<String>().toList();
      } catch (e) {
        if (kDebugMode) {
          print('Failed to load frequent symptoms: $e');
        }
      }
    }
  }

  Future<void> _saveFrequentSymptoms() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('frequent_symptoms', jsonEncode(_frequentSymptoms));
  }
  
  Future<void> _loadMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final medsJson = prefs.getString('medications');
    if (medsJson != null) {
      try {
        final List<dynamic> list = jsonDecode(medsJson);
        _medications = list.cast<String>().toList();
      } catch (e) {
        if (kDebugMode) {
          print('Failed to load medications: $e');
        }
      }
    }
  }

  Future<void> _saveMedications() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('medications', jsonEncode(_medications));
  }
  
  Future<void> _loadMedicationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('medication_history');
    if (historyJson != null) {
      try {
        final Map<String, dynamic> historyMap = jsonDecode(historyJson);
        _medicationHistory.clear();
        historyMap.forEach((key, value) {
          if (value is Map) {
            _medicationHistory[key] = Map<String, bool>.from(value.cast<String, bool>());
          }
        });
      } catch (e) {
        if (kDebugMode) {
          print('Failed to load medication history: $e');
        }
        _medicationHistory = {};
      }
    }
  }

  Future<void> _saveMedicationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('medication_history', jsonEncode(_medicationHistory));
  }
  
  Future<void> _loadDiaryEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final diaryJson = prefs.getString('diary_entries');
    if (diaryJson != null) {
      try {
        final Map<String, dynamic> diaryMap = jsonDecode(diaryJson);
        _diaryEntries = Map<String, dynamic>.from(diaryMap);
      } catch (e) {
        if (kDebugMode) {
          print('Failed to load diary entries: $e');
        }
        _diaryEntries = {};
      }
    }
  }

  Future<void> _saveDiaryEntries() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('diary_entries', jsonEncode(_diaryEntries));
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }
}