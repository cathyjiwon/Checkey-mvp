import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/symptom_manager.dart';
import '../widgets/custom_card.dart';

class MedicationScreen extends StatelessWidget {
  const MedicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final symptomManager = Provider.of<SymptomManager>(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '복용 중인 약물',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      ...symptomManager.medications.map((medication) {
                        return Chip(
                          label: Text(medication),
                          onDeleted: () {
                            symptomManager.removeMedication(medication);
                          },
                        );
                      }).toList(),
                      ActionChip(
                        avatar: const Icon(Icons.add),
                        label: const Text('새로운 약물 추가'),
                        onPressed: () => _addMedication(context, symptomManager),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addMedication(BuildContext context, SymptomManager manager) {
    _showAddDialog(context, '약물 추가', (text) => manager.addMedication(text));
  }

  void _showAddDialog(BuildContext context, String title, Function(String) onSave) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "$title을 입력하세요"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  onSave(controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }
}