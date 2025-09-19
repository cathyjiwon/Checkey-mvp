// lib/widgets/medication_manager_drawer.dart

import 'package:flutter/material.dart';
import 'package:solusmvp/services/symptom_manager.dart';

class MedicationManagerDrawer extends StatelessWidget {
  const MedicationManagerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // build 메서드 내부에서 직접 `_buildAddMedicationSection`을 호출하도록 수정
    return _buildAddMedicationSection(context);
  }

  // 약물 추가 기능을 담당하는 섹션
  Widget _buildAddMedicationSection(BuildContext context) {
    final TextEditingController textEditingController = TextEditingController();
    final symptomManager = SymptomManager(); // SymptomManager 인스턴스 생성

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '약 추가',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textEditingController,
                  decoration: const InputDecoration(
                    hintText: '약 이름을 입력하세요',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (textEditingController.text.isNotEmpty) {
                    // Map<String, dynamic> 형태로 변환하여 전달
                    final newMedication = {'name': textEditingController.text};
                    symptomManager.addMedication(newMedication);
                    textEditingController.clear();
                  }
                },
                child: const Text('추가'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 약물 목록 표시
          ListView.builder(
            shrinkWrap: true,
            itemCount: symptomManager.medications.length,
            itemBuilder: (context, index) {
              final medication = symptomManager.medications[index];
              return ListTile(
                title: Text(medication['name']),
              );
            },
          ),
        ],
      ),
    );
  }
}