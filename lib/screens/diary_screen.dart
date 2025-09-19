// lib/screens/diary_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solusmvp/services/symptom_manager.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_card.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  String _selectedState = '이상 없음';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDiaryEntryForSelectedDay();
    });
  }

  void _loadDiaryEntryForSelectedDay() {
    final symptomManager = Provider.of<SymptomManager>(context, listen: false);
    final selectedDateString = DateFormat('yyyy-MM-dd').format(_selectedDay);
    final entry = symptomManager.diaryEntries[selectedDateString];
    setState(() {
      _selectedState = entry != null ? entry['status'] : '이상 없음';
    });
  }

  List<String> _getEventsForDay(DateTime day) {
    final symptomManager = Provider.of<SymptomManager>(context, listen: false);
    final dayString = DateFormat('yyyy-MM-dd').format(day);
    if (symptomManager.diaryEntries.containsKey(dayString)) {
      return [symptomManager.diaryEntries[dayString]['status']];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final symptomManager = Provider.of<SymptomManager>(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomCard(
              child: TableCalendar(
                locale: 'ko_KR',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _loadDiaryEntryForSelectedDay();
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.lightGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                eventLoader: (day) => _getEventsForDay(day),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        right: 1,
                        bottom: 1,
                        child: Container(
                          width: 16.0,
                          height: 16.0,
                          decoration: BoxDecoration(
                            color: events.first == '이상 없음' ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            CustomCard(
              child: Column(
                children: [
                  Text(
                    DateFormat('yyyy년 M월 d일').format(_selectedDay),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '오늘 나의 건강 상태는?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStateButton('이상 없음', context),
                      const SizedBox(width: 20),
                      _buildStateButton('이상 있음', context),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (symptomManager.diaryEntries[DateFormat('yyyy-MM-dd').format(_selectedDay)]?['status'] == '이상 있음')
                    Column(
                      children: [
                        const Text(
                          '기록된 증상:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            ...symptomManager.diaryEntries[DateFormat('yyyy-MM-dd').format(_selectedDay)]?['symptoms']
                                .map<Widget>((symptom) => Chip(label: Text(symptom)))
                                .toList() ?? [],
                          ],
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

  Widget _buildStateButton(String state, BuildContext context) {
    final buttonColor = state == '이상 없음' ? Colors.green : Colors.red;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      onPressed: () {
        final symptomManager = Provider.of<SymptomManager>(context, listen: false);
        if (state == '이상 있음') {
          _showSymptomInputModal(context, symptomManager);
        } else {
          symptomManager.saveDiaryEntry(_selectedDay, '이상 없음', []);
          _loadDiaryEntryForSelectedDay(); // 상태 업데이트
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('건강 일기가 저장되었습니다.')),
          );
        }
      },
      child: Text(state),
    );
  }

  void _showSymptomInputModal(BuildContext context, SymptomManager symptomManager) {
    final TextEditingController symptomController = TextEditingController();
    List<String> selectedSymptoms = symptomManager.diaryEntries[DateFormat('yyyy-MM-dd').format(_selectedDay)]?['symptoms']
        .cast<String>()
        .toList() ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(bc).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter modalSetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '오늘 느낀 증상을 기록하세요.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text('자주 나타나는 증상', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: symptomManager.frequentSymptoms.map((symptom) {
                      final isSelected = selectedSymptoms.contains(symptom);
                      return ChoiceChip(
                        label: Text(symptom),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          modalSetState(() {
                            if (selected) {
                              selectedSymptoms.add(symptom);
                            } else {
                              selectedSymptoms.remove(symptom);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: symptomController,
                    decoration: const InputDecoration(
                      labelText: '다른 증상이 있다면 입력하세요.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (symptomController.text.isNotEmpty) {
                        selectedSymptoms.add(symptomController.text);
                      }
                      
                      symptomManager.saveDiaryEntry(_selectedDay, _selectedState, selectedSymptoms);
                          
                      Navigator.pop(context);
                      _loadDiaryEntryForSelectedDay();
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('건강 일기가 저장되었습니다.')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('기록하기', style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}