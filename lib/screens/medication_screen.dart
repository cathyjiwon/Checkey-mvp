// lib/screens/medication_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solusmvp/services/symptom_manager.dart';
import 'package:solusmvp/services/medication_manager.dart';
import 'package:solusmvp/widgets/medication_manager_drawer.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Consumer2<SymptomManager, MedicationManager>(
      builder: (context, symptomManager, medicationManager, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // '약 관리' 바로가기 버튼 섹션
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const MedicationManagerDrawer()),
                        );
                      },
                      child: const Text('약 관리', textAlign: TextAlign.center),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 날짜 선택 섹션
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                        });
                      },
                    ),
                    TextButton(
                      onPressed: () => _selectDate(context),
                      child: Text(
                        '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.add(const Duration(days: 1));
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 약 복용 체크 리스트 섹션
                const Text(
                  '복용 여부 체크',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...medicationManager.medications.asMap().entries.map((entry) {
                  final index = entry.key;
                  final medication = entry.value;
                  final medicationName = medication['name'] as String;
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: CheckboxListTile(
                      title: Text(medicationName),
                      value: medicationManager.isMedicationTaken(_selectedDate, medicationName),
                      onChanged: (bool? value) {
                        if (value != null) {
                          medicationManager.setMedicationTaken(_selectedDate, medicationName, value);
                        }
                      },
                      secondary: const Icon(Icons.medication),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023, 1, 1),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}