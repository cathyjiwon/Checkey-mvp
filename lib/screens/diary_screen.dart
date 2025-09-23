// lib/screens/diary_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solusmvp/services/diary_manager.dart';
import 'package:solusmvp/widgets/symptom_input_modal.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
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
    final entries = diaryManager.diaryEntries[selectedDateString];
    setState(() {
      // 가장 최근 기록의 상태를 불러옵니다.
      _selectedState = entries != null && entries.isNotEmpty ? entries.last['status'] : null;
    });
  }

  List<String> _getEventsForDay(DateTime day) {
    final diaryManager = Provider.of<DiaryManager>(context, listen: false);
    final dayString = DateFormat('yyyy-MM-dd').format(day);
    if (diaryManager.diaryEntries.containsKey(dayString) &&
        diaryManager.diaryEntries[dayString]!.isNotEmpty) {
      // 기록이 하나라도 있으면 이벤트를 표시합니다.
      return ['event'];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
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
                    icon: const Icon(
                      Icons.healing,
                      size: 20,
                      color: Colors.green,
                    ),
                    label: const Text(
                      '증상 관리',
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
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                color: Colors.white,
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
                    headerStyle: const HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      titleTextStyle: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      headerPadding: EdgeInsets.symmetric(vertical: 10.0),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Colors.black54,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Colors.black54,
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: TextStyle(color: Colors.grey[600]),
                      defaultTextStyle: const TextStyle(color: Colors.black87),
                      todayDecoration: BoxDecoration(
                        color: Colors.green.withAlpha(50),
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
                        final diaryManager = Provider.of<DiaryManager>(context, listen: false);
                        final dayString = DateFormat('yyyy-MM-dd').format(date);
                        final entries = diaryManager.diaryEntries[dayString];
                        if (entries != null && entries.isNotEmpty) {
                          // 가장 최근 기록의 상태를 기반으로 마커 색상을 결정
                          final latestEntry = entries.last;
                          final status = latestEntry['status'];
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
                        final textColor = (day.weekday == DateTime.sunday)
                            ? Colors.red
                            : (day.weekday == DateTime.saturday)
                                ? Colors.blue
                                : Colors.black87;
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
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📅 ${DateFormat('yyyy년 M월 d일').format(_selectedDay)}',
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
                      if (diaryManager.diaryEntries.containsKey(DateFormat('yyyy-MM-dd').format(_selectedDay)))
                        _buildAllHealthStatusDisplays(diaryManager),
                      if (!diaryManager.diaryEntries.containsKey(DateFormat('yyyy-MM-dd').format(_selectedDay)))
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              '아직 기록된 건강 일기가 없습니다.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
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

  Widget _buildStateButton(String state, BuildContext context) {
    final isSelected = _selectedState == state;
    final bool hasAnySelection = _selectedState != null;
    Color startColor;
    Color endColor;
    Color textColor;
    String emoji;
    if (state == '이상 없음') {
      startColor = Colors.green.shade400;
      endColor = Colors.green.shade600;
      emoji = '😊';
    } else {
      startColor = Colors.red.shade400;
      endColor = Colors.red.shade600;
      emoji = '🤒';
    }
    if (isSelected) {
      textColor = Colors.white;
    } else if (hasAnySelection) {
      startColor = Colors.grey.shade200;
      endColor = Colors.grey.shade200;
      textColor = Colors.black54;
    } else {
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
              final now = DateTime.now();
              diaryManager.saveDiaryEntry(
                _selectedDay,
                '이상 없음',
                [],
                timestamp: now.toIso8601String(),
              );
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
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 30),
                ),
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

  void _showSymptomInputModal(BuildContext context, String status) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return SymptomInputModal(selectedDay: _selectedDay, status: status);
      },
    );
    _loadDiaryEntryForSelectedDay();
  }

  Widget _buildAllHealthStatusDisplays(DiaryManager diaryManager) {
    final entries = diaryManager.diaryEntries[DateFormat('yyyy-MM-dd').format(_selectedDay)];
    if (entries == null || entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: entries.reversed.map((entry) { // 최근 기록부터 표시하기 위해 reversed 사용
        return _buildSingleHealthStatusDisplay(entry);
      }).toList(),
    );
  }

  Widget _buildSingleHealthStatusDisplay(Map<String, dynamic> entry) {
    final status = entry['status'];
    final frequentSymptoms = entry['frequentSymptoms'] as List<dynamic>?;
    final otherSymptoms = entry['otherSymptoms'] as List<dynamic>?;
    final customSymptom = entry['customSymptom'] as String?;
    final timestamp = entry['timestamp'] as String?;

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  status == '이상 없음' ? '✅' : '🚨',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('MM월 d일').format(_selectedDay)} 기록',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700]),
                ),
                if (timestamp != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '(${DateFormat('a h:mm', 'ko_KR').format(DateTime.parse(timestamp))})',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
            const Divider(height: 24),
            if (status == '이상 있음') ...[
              if (frequentSymptoms != null && frequentSymptoms.isNotEmpty) ...[
                const Text(
                  '자주 나타나는 증상:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: frequentSymptoms
                      .map<Widget>((symptom) => Chip(
                            label: Text(symptom),
                            backgroundColor: Colors.grey.shade200,
                            labelStyle: const TextStyle(fontWeight: FontWeight.w500),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],
              if (otherSymptoms != null && otherSymptoms.isNotEmpty) ...[
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
                  children: otherSymptoms
                      .map<Widget>((symptom) => Chip(
                            label: Text(symptom),
                            backgroundColor: Colors.grey.shade200,
                            labelStyle: const TextStyle(fontWeight: FontWeight.w500),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],
              if (customSymptom != null && customSymptom.isNotEmpty) ...[
                const Text(
                  '자세한 증상:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '✍️ $customSymptom',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ] else if (status == '이상 없음') ...[
              const Text(
                '👍 오늘 건강 상태에 이상이 없었습니다.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}