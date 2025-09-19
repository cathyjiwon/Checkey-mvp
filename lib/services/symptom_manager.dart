// lib/services/symptom_manager.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class SymptomManager with ChangeNotifier {
  List<dynamic> _frequentSymptoms = [];
  List<dynamic> _medications = [];
  Map<String, dynamic> _medicationHistory = {};

  List<dynamic> get frequentSymptoms => _frequentSymptoms;
  List<dynamic> get medications => _medications;
  Map<String, dynamic> get medicationHistory => _medicationHistory;

  SymptomManager() {
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final frequentSymptomsList = prefs.getStringList('frequent_symptoms');
    if (frequentSymptomsList != null) {
      _frequentSymptoms = frequentSymptomsList;
    }

    final medicationsString = prefs.getString('medications');
    if (medicationsString != null) {
      _medications = json.decode(medicationsString);
    }
    
    final historyString = prefs.getString('medication_history');
    if (historyString != null) {
      final decodedHistory = json.decode(historyString);
      if (decodedHistory is Map) {
        _medicationHistory = decodedHistory.map((key, value) {
          final historyMap = Map<String, bool>.from(value);
          return MapEntry(key, historyMap);
        });
      }
    }

    notifyListeners();
  }

  Future<void> _saveAllData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setStringList('frequent_symptoms', List<String>.from(_frequentSymptoms));
    await prefs.setString('medications', json.encode(_medications));
    await prefs.setString('medication_history', json.encode(_medicationHistory));
  }

  void addFrequentSymptom(String symptom) {
    if (!_frequentSymptoms.contains(symptom)) {
      _frequentSymptoms.add(symptom);
      _saveAllData();
      notifyListeners();
    }
  }
  
  void removeFrequentSymptom(String symptom) {
    _frequentSymptoms.remove(symptom);
    _saveAllData();
    notifyListeners();
  }

  void addMedication(Map<String, dynamic> medication) {
    _medications.add(medication);
    _saveAllData();
    notifyListeners();
  }
  
  void removeMedication(int index) {
    _medications.removeAt(index);
    _saveAllData();
    notifyListeners();
  }

  bool isMedicationTaken(DateTime date, String medicationName) {
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    final dayHistory = _medicationHistory[dateString];
    if (dayHistory == null) return false;
    return dayHistory[medicationName] ?? false;
  }

  void setMedicationTaken(DateTime date, String medicationName, bool isTaken) {
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    if (!_medicationHistory.containsKey(dateString)) {
      _medicationHistory[dateString] = {};
    }
    _medicationHistory[dateString][medicationName] = isTaken;
    _saveAllData();
    notifyListeners();
  }
}