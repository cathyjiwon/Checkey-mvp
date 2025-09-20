// lib/screens/diary_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solusmvp/services/symptom_manager.dart';
import 'package:solusmvp/services/diary_manager.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:solusmvp/widgets/custom_card.dart';
import 'package:solusmvp/widgets/frequent_symptom_drawer.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  String? _selectedState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDiaryEntryForSelectedDay();
    });
  }

  void _loadDiaryEntryForSelectedDay() {
    final diaryManager = Provider.of<DiaryManager>(context, listen: false);
    final selectedDateString = DateFormat('yyyy-MM-dd').format(_selectedDay);
    final entry = diaryManager.diaryEntries[selectedDateString];
    setState(() {
      _selectedState = entry?['status'];
    });
  }

  List<String> _getEventsForDay(DateTime day) {
    final diaryManager = Provider.of<DiaryManager>(context, listen: false);
    final dayString = DateFormat('yyyy-MM-dd').format(day);
    if (diaryManager.diaryEntries.containsKey(dayString)) {
      return [diaryManager.diaryEntries[dayString]['status']];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final symptomManager = Provider.of<SymptomManager>(context);
    final diaryManager = Provider.of<DiaryManager>(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const FrequentSymptomDrawer()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text('증상 추가', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),

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
                eventLoader: (day) => _getEventsForDay(day),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      final status = events.first;
                      Color markerColor = Colors.grey;

                      if (status == '이상 없음') {
                        markerColor = Colors.green;
                      } else if (status == '이상 있음') {
                        markerColor = Colors.red;
                      }

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 8.0,
                            height: 8.0,
                            decoration: BoxDecoration(
                              color: markerColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
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
                  if (_selectedState != null)
                    Text(
                      '오늘의 건강 상태: ${_selectedState!}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 10),
                  if (_selectedState == '이상 있음')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            ...diaryManager.diaryEntries[DateFormat('yyyy-MM-dd').format(_selectedDay)]?['symptoms']
                                .map<Widget>((symptom) => Chip(
                                  label: Text(symptom),
                                  backgroundColor: Colors.grey.shade200,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                ))
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
    final isSelected = _selectedState == state;
    final bool isNotSelected = _selectedState != null && !isSelected;

    Color buttonColor;
    Color textColor;

    if (_selectedState == null) {
        // 아무것도 선택되지 않았을 때
        buttonColor = (state == '이상 없음' ? Colors.green.shade600 : Colors.red.shade600);
        textColor = Colors.white;
    } else {
        // 선택된 상태
        if (isSelected) {
            buttonColor = (state == '이상 없음' ? Colors.green.shade600 : Colors.red.shade600);
            textColor = Colors.white;
        } else {
            buttonColor = Colors.grey.shade200;
            textColor = Colors.black87;
        }
    }

    return Expanded(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Material(
                color: buttonColor,
                borderRadius: BorderRadius.circular(12.0),
                child: InkWell(
                    borderRadius: BorderRadius.circular(12.0),
                    onTap: () {
                        setState(() {
                            _selectedState = state;
                        });
                        if (state == '이상 있음') {
                            _showSymptomInputModal(context, '이상 있음');
                        } else {
                            final diaryManager = Provider.of<DiaryManager>(context, listen: false);
                            diaryManager.saveDiaryEntry(_selectedDay, '이상 없음', []);
                            _loadDiaryEntryForSelectedDay();
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('건강 일기가 저장되었습니다.')),
                            );
                        }
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        child: Text(
                            state,
                            style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                            ),
                        ),
                    ),
                ),
            ),
        ),
    );
}

  void _showSymptomInputModal(BuildContext context, String status) {
    final TextEditingController symptomController = TextEditingController();
    List<String> selectedSymptoms = [];
    final ValueNotifier<bool> hasSelectedFrequentSymptom = ValueNotifier<bool>(false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(bc).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter modalSetState) {
              final symptomManager = Provider.of<SymptomManager>(context);
              final diaryManager = Provider.of<DiaryManager>(context, listen: false);

              String labelText = hasSelectedFrequentSymptom.value || symptomController.text.isNotEmpty
                  ? '자세한 증상을 입력하세요.'
                  : '다른 증상이 있다면 입력하세요.';

              return Column(
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
                  const SizedBox(height: 20),
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
                        selectedColor: Colors.green.shade100,
                        onSelected: (bool selected) {
                          modalSetState(() {
                            if (selected) {
                              selectedSymptoms.add(symptom);
                            } else {
                              selectedSymptoms.remove(symptom);
                            }
                            hasSelectedFrequentSymptom.value = selectedSymptoms.isNotEmpty;
                          });
                        },
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.green.shade800 : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          side: BorderSide(
                            color: isSelected ? Colors.green.shade400 : Colors.grey.shade300,
                          ),
                        ),
                        backgroundColor: Colors.grey.shade100,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: symptomController,
                    decoration: InputDecoration(
                      labelText: labelText,
                      labelStyle: TextStyle(
                        color: hasSelectedFrequentSymptom.value || symptomController.text.isNotEmpty
                            ? Colors.grey.shade600
                            : Colors.grey.shade600,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 2.0),
                      ),
                    ),
                    onChanged: (text) {
                      modalSetState(() {
                        hasSelectedFrequentSymptom.value = text.isNotEmpty || selectedSymptoms.isNotEmpty;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      List<String> symptomsToSave = [...selectedSymptoms];
                      if (symptomController.text.isNotEmpty) {
                        symptomsToSave.add(symptomController.text);
                      }
                      
                      diaryManager.saveDiaryEntry(_selectedDay, status, symptomsToSave);
                      
                      Navigator.pop(context);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('건강 일기가 저장되었습니다.')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('기록하기', style: TextStyle(fontWeight: FontWeight.bold)),
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