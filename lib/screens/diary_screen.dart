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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const FrequentSymptomDrawer()),
                      );
                    },
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text(
                      '증상 추가',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      elevation: 1,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 캘린더 카드
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      titleTextStyle: const TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      headerPadding: const EdgeInsets.symmetric(vertical: 10.0),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Colors.grey[600],
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Colors.grey[600],
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: TextStyle(color: Colors.grey[600]),
                      defaultTextStyle: const TextStyle(color: Colors.black87),
                      todayDecoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      markerDecoration: const BoxDecoration(
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
                            markerColor = Colors.green.shade600;
                          } else if (status == '이상 있음') {
                            markerColor = Colors.red.shade600;
                          }

                          return Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              width: 6.0,
                              height: 6.0,
                              decoration: BoxDecoration(
                                color: markerColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                      dowBuilder: (context, day) {
                        final text = DateFormat.E('ko_KR').format(day);
                        final textColor = (day.weekday == DateTime.sunday) ? Colors.red : (day.weekday == DateTime.saturday) ? Colors.blue : Colors.black87;
                        return Center(
                          child: Text(
                            text,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 건강 상태 기록 카드
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('yyyy년 M월 d일').format(_selectedDay),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '오늘 나의 건강 상태는?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStateButton('이상 없음', context),
                          const SizedBox(width: 16),
                          _buildStateButton('이상 있음', context),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_selectedState != null)
                        _buildHealthStatusDisplay(diaryManager),
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

  Widget _buildStateButton(String state, BuildContext context) {
  final isSelected = _selectedState == state;
  final bool hasAnySelection = _selectedState != null;

  Color startColor;
  Color endColor;
  Color textColor;
  IconData icon;

  if (state == '이상 없음') {
    startColor = Colors.green.shade400;
    endColor = Colors.green.shade600;
    icon = Icons.check_circle_outline;
  } else {
    startColor = Colors.red.shade400;
    endColor = Colors.red.shade600;
    icon = Icons.error_outline;
  }

  // 색상 로직 수정
  if (isSelected) {
    textColor = Colors.white;
  } else if (hasAnySelection) {
    startColor = Colors.grey.shade200;
    endColor = Colors.grey.shade200;
    textColor = Colors.black54;
  } else {
    // 아무것도 선택되지 않았을 때
    textColor = Colors.white;
  }

  return Expanded(
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        gradient: (isSelected || !hasAnySelection)
            ? LinearGradient(
                colors: [startColor, endColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: (isSelected || !hasAnySelection) ? null : Colors.grey.shade200,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor),
              const SizedBox(height: 8),
              Text(
                state,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildHealthStatusDisplay(DiaryManager diaryManager) {
    final entry = diaryManager.diaryEntries[DateFormat('yyyy-MM-dd').format(_selectedDay)];
    if (entry == null) return const SizedBox.shrink();

    final status = entry['status'];
    final symptoms = entry['symptoms'] as List<dynamic>?;
    final hasSymptoms = symptoms != null && symptoms.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '오늘의 건강 상태: ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: status == '이상 없음' ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: status == '이상 없음' ? Colors.green.shade800 : Colors.red.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        if (status == '이상 있음' && hasSymptoms) ...[
          const SizedBox(height: 16),
          const Text(
            '기록된 증상:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: symptoms.map<Widget>((symptom) => Chip(
              label: Text(symptom),
              backgroundColor: Colors.grey.shade200,
              labelStyle: const TextStyle(fontWeight: FontWeight.w500),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }

  void _showSymptomInputModal(BuildContext context, String status) {
    // ... (기존 _showSymptomInputModal 코드는 유지하되, UI 스타일만 개선)
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(bc).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter modalSetState) {
              final symptomManager = Provider.of<SymptomManager>(context);
              final diaryManager = Provider.of<DiaryManager>(context, listen: false);

              String labelText = selectedSymptoms.isNotEmpty || symptomController.text.isNotEmpty
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
                  const SizedBox(height: 24),
                  const Text(
                    '오늘 느낀 증상을 기록하세요.',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
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
                          modalSetState(() {
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
                      modalSetState(() {});
                    },
                  ),
                  const SizedBox(height: 24),
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
              );
            },
          ),
        );
      },
    );
  }
}