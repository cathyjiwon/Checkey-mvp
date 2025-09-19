import 'package:flutter/foundation.dart';

class SymptomManager extends ChangeNotifier {
  final List<String> _frequentSymptoms = ['두통', '복통', '피로', '어지러움'];
  final List<String> _medications = ['타이레놀', '게보린', '소화제'];

  List<String> get frequentSymptoms => _frequentSymptoms;
  List<String> get medications => _medications;

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

  void addMedication(String medication) {
    if (!_medications.contains(medication)) {
      _medications.add(medication);
      notifyListeners();
    }
  }

  void removeMedication(String medication) {
    _medications.remove(medication);
    notifyListeners();
  }
}