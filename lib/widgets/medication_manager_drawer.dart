// lib/widgets/medication_manager_drawer.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solusmvp/services/symptom_manager.dart';

class MedicationManagerDrawer extends StatelessWidget {
  const MedicationManagerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final symptomManager = Provider.of<SymptomManager>(context);

    return Drawer(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 뒤로 가기 버튼과 제목
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '복용 중인 약 관리',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // 약물 목록 및 추가 버튼 카드
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '복용 중인 약',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          ...symptomManager.medications.asMap().entries.map((entry) {
                            final index = entry.key;
                            final medication = entry.value;
                            return Chip(
                              label: Text(medication['name']),
                              onDeleted: () {
                                symptomManager.removeMedication(index);
                              },
                            );
                          }).toList(),
                          ActionChip(
                            avatar: const Icon(Icons.add),
                            label: const Text('새로운 약 추가'),
                            onPressed: () {
                              _showAddMedicationDialog(context, symptomManager);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 새로운 약을 추가하는 다이얼로그
  void _showAddMedicationDialog(BuildContext context, SymptomManager symptomManager) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('새로운 약 추가'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '약 이름을 입력하세요'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  symptomManager.addMedication({'name': controller.text});
                  Navigator.of(context).pop();
                }
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }
}