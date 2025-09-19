import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SymptomManager extends ChangeNotifier {
  final List<String> _frequentSymptoms = ['두통', '복통', '피로', '어지러움'];
  final List<String> _medications = ['타이레놀', '게보린', '소화제'];
  final Map<String, Map<String, bool>> _medicationHistory = {};

  SymptomManager() {
    _loadMedications();
  }

  // 자주 발생하는 증상
  List<String> get frequentSymptoms => _frequentSymptoms;

  void addFrequentSymptom(String symptom) {
    if (!_frequentSymptoms.contains(symptom)) {
      _frequentSymptoms.add(symptom);
      notifyListeners();
    }
  }

  void removeFrequentSymptom(String symptom) {
    _frequentSymptoms.remove(symptom);
    notifyListeners();
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

  // 데이터 저장 및 불러오기
  Future<void> _loadMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final medsJson = prefs.getString('medications');
    if (medsJson != null) {
      _medications.clear();
      final List<dynamic> list = jsonDecode(medsJson);
      _medications.addAll(list.cast<String>());
    }

    final historyJson = prefs.getString('medication_history');
    if (historyJson != null) {
      final Map<String, dynamic> historyMap = jsonDecode(historyJson);
      _medicationHistory.clear();
      historyMap.forEach((key, value) {
        _medicationHistory[key] = Map<String, bool>.from(value);
      });
    }
    notifyListeners();
  }

  Future<void> _saveMedications() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('medications', jsonEncode(_medications));
  }
  
  Future<void> _saveMedicationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('medication_history', jsonEncode(_medicationHistory));
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }
}