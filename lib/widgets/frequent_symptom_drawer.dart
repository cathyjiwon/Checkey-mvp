import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/symptom_manager.dart';
import '../widgets/custom_card.dart';

class FrequentSymptomDrawer extends StatelessWidget {
  const FrequentSymptomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final symptomManager = Provider.of<SymptomManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('자주 발생하는 증상 관리'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '자주 발생하는 증상',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    ...symptomManager.frequentSymptoms.map((symptom) {
                      return Chip(
                        label: Text(symptom),
                        onDeleted: () {
                          symptomManager.removeFrequentSymptom(symptom);
                        },
                      );
                    }).toList(),
                    ActionChip(
                      avatar: const Icon(Icons.add),
                      label: const Text('새로운 증상 추가'),
                      onPressed: () => _addSymptom(context, symptomManager),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addSymptom(BuildContext context, SymptomManager manager) {
    _showAddDialog(context, '증상 추가', (text) => manager.addFrequentSymptom(text));
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