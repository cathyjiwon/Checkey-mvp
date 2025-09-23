import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solusmvp/services/symptom_manager.dart';
import 'package:solusmvp/services/diary_manager.dart';
import 'package:intl/intl.dart';

class SymptomInputModal extends StatefulWidget {
  final DateTime selectedDay;
  final String status;

  const SymptomInputModal({
    super.key,
    required this.selectedDay,
    required this.status,
  });

  @override
  State<SymptomInputModal> createState() => _SymptomInputModalState();
}

class _SymptomInputModalState extends State<SymptomInputModal> {
  final TextEditingController symptomController = TextEditingController();
  List<String> selectedSymptoms = [];
  late DateTime _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = DateTime.now();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = DateTime(
          _selectedTime.year,
          _selectedTime.month,
          _selectedTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final symptomManager = Provider.of<SymptomManager>(context);
    final diaryManager = Provider.of<DiaryManager>(context, listen: false);
    bool hasSelectedChip = selectedSymptoms.isNotEmpty;
    String labelText = hasSelectedChip ? '자세한 증상을 입력하세요.' : '다른 증상이 있다면 입력하세요.';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '오늘 느낀 증상을 기록하세요.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              TextButton(
                onPressed: () => _selectTime(context),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('a h:mm', 'ko_KR').format(_selectedTime),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '자주 나타나는 증상',
            style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: symptomManager.frequentSymptoms.map((symptom) {
              final isSelected = selectedSymptoms.contains(symptom);
              return ChoiceChip(
                label: Text(symptom),
                selected: isSelected,
                selectedColor: Colors.blue.shade50,
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      selectedSymptoms.add(symptom);
                    } else {
                      selectedSymptoms.remove(symptom);
                    }
                  });
                },
                labelStyle: TextStyle(
                  color: isSelected ? Colors.blue.shade800 : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(
                    color: isSelected ? Colors.blue.shade200 : Colors.grey.shade300,
                  ),
                ),
                backgroundColor: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: symptomController,
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: TextStyle(
                color: Colors.grey.shade600,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue.shade600, width: 2.0),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (text) {
              setState(() {});
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final customInput = symptomController.text.trim();
              bool hasSelectedChip = selectedSymptoms.isNotEmpty;
              final String customSymptomValue = hasSelectedChip ? (customInput.isNotEmpty ? customInput : '') : '';


              diaryManager.saveDiaryEntry(
                widget.selectedDay,
                widget.status,
                selectedSymptoms,
                otherSymptoms: hasSelectedChip ? [] : (customInput.isNotEmpty ? [customInput] : []),
                customSymptom: customSymptomValue,
                timestamp: _selectedTime.toIso8601String(),
              );

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('건강 일기가 저장되었습니다.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 4,
            ),
            child: const Text('기록하기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ],
      ),
    );
  }
}