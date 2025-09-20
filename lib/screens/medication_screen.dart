// lib/screens/medication_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solusmvp/services/symptom_manager.dart';
import 'package:solusmvp/services/medication_manager.dart';
import 'package:solusmvp/widgets/medication_manager_drawer.dart';
import 'package:intl/intl.dart';

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
        final formattedDate = DateFormat('yyyy년 M월 d일').format(_selectedDate);
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const MedicationManagerDrawer()),
                        );
                      },
                      icon: const Icon(Icons.medical_services_outlined, color: Colors.green),
                      label: const Text('약 관리', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                          });
                        },
                      ),
                      TextButton(
                        onPressed: () => _selectDate(context),
                        child: Text(
                          formattedDate,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _selectedDate = _selectedDate.add(const Duration(days: 1));
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  '✨ 복용 여부 체크',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                if (medicationManager.medications.isEmpty)
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      '💊 추가된 약이 없어요.',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                  ),
                ...medicationManager.medications.asMap().entries.map((entry) {
                  final medication = entry.value;
                  final medicationName = medication['name'] as String;
                  return MedicationCard(
                    medicationName: medicationName,
                    isTaken: medicationManager.isMedicationTaken(_selectedDate, medicationName),
                    onChanged: (bool? value) {
                      if (value != null) {
                        medicationManager.setMedicationTaken(_selectedDate, medicationName, value);
                      }
                    },
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
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.green,
            colorScheme: const ColorScheme.light(primary: Colors.green),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}

class MedicationCard extends StatelessWidget {
  final String medicationName;
  final bool isTaken;
  final ValueChanged<bool?> onChanged;

  const MedicationCard({
    required this.medicationName,
    required this.isTaken,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: isTaken ? Colors.lightBlue.shade50 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isTaken ? Colors.lightBlue.shade200 : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isTaken ? Icons.check : Icons.medication_outlined,
                color: isTaken ? Colors.lightBlue.shade800 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                medicationName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isTaken ? Colors.lightBlue.shade900 : Colors.black87,
                  decoration: isTaken ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              ),
            ),
            Checkbox(
              value: isTaken,
              onChanged: onChanged,
              activeColor: Colors.lightBlue,
              checkColor: Colors.white,
              fillColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.lightBlue.shade700;
                  }
                  return Colors.grey.shade400;
                },
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}