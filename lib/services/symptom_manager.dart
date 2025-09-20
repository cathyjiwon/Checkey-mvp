// lib/services/symptom_manager.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SymptomManager with ChangeNotifier {
  List<dynamic> _frequentSymptoms = [];

  List<dynamic> get frequentSymptoms => _frequentSymptoms;

  SymptomManager() {
    _loadFrequentSymptoms();
  }

  Future<void> _loadFrequentSymptoms() async {
    final prefs = await SharedPreferences.getInstance();
    final frequentSymptomsList = prefs.getStringList('frequent_symptoms');
    if (frequentSymptomsList != null) {
      _frequentSymptoms = frequentSymptomsList;
    }
    notifyListeners();
  }

  Future<void> _saveFrequentSymptoms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('frequent_symptoms', List<String>.from(_frequentSymptoms));
  }

  void addFrequentSymptom(String symptom) {
    if (!_frequentSymptoms.contains(symptom)) {
      _frequentSymptoms.add(symptom);
      _saveFrequentSymptoms();
      notifyListeners();
    }
  }
  
  void removeFrequentSymptom(String symptom) {
    _frequentSymptoms.remove(symptom);
    _saveFrequentSymptoms();
    notifyListeners();
  }
}