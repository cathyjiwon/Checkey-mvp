// lib/screens/medication_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solusmvp/services/symptom_manager.dart';
import 'package:solusmvp/services/medication_manager.dart'; // MedicationManager 임포트
import 'package:solusmvp/widgets/frequent_symptom_drawer.dart';
import 'package:solusmvp/widgets/medication_manager_drawer.dart';

class MedicationScreen extends StatelessWidget {
  const MedicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<SymptomManager, MedicationManager>( // Consumer2로 두 개의 Manager 사용
        builder: (context, symptomManager, medicationManager, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '자주 겪는 증상',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      ...symptomManager.frequentSymptoms.map((symptom) => Chip(label: Text(symptom))),
                      ActionChip(
                        label: const Text('+ 증상 추가'),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const FrequentSymptomDrawer()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '복용 중인 약',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      ...medicationManager.medications.map((med) => Chip(label: Text(med['name']))),
                      ActionChip(
                        label: const Text('+ 약 추가'),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const MedicationManagerDrawer()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}