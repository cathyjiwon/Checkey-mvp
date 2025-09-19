import 'dart:async';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:solusmvp/services/symptom_manager.dart';
import '../widgets/custom_card.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, Map<String, dynamic>> _events = {};
  final TextEditingController _diaryController = TextEditingController();
  Timer? _debounce;
  bool _showEntrySection = false;
  String _symptom = '';

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  @override
  void dispose() {
    _diaryController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

Future<void> _loadEvents() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    _events.clear();
    for (final key in allKeys) {
      if (key.startsWith('diary_')) {
        final dateString = key.replaceFirst('diary_', '');
        final date = DateTime.tryParse(dateString);
        if (date != null) {
          final normalizedDate = DateTime.utc(date.year, date.month, date.day);
          final entryJson = prefs.getString(key);
          if (entryJson != null) {
            try {
              // 새로운 JSON 형식 데이터 파싱 시도
              final entry = jsonDecode(entryJson);
              _events[normalizedDate] = {
                'type': entry['type'],
                'text': entry['text'],
                'symptom': entry['symptom'],
              };
            } catch (e) {
              // JSON 파싱 실패 시, 이전의 문자열 형식 데이터로 처리
              // 이전 '이상 없음' 텍스트 데이터의 경우 'good' 타입으로 간주
              _events[normalizedDate] = {
                'type': entryJson == '이상 없음' ? 'good' : 'bad',
                'text': '',
                'symptom': '',
              };
            }
          }
        }
      }
    }
    setState(() {});
  }

  Future<void> _saveDiary(String type) async {
    if (_selectedDay == null) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final normalizedDay = DateTime.utc(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final key = 'diary_$normalizedDay';
    
    final entry = {
      'type': type,
      'text': _diaryController.text,
      'symptom': _symptom,
    };
    await prefs.setString(key, jsonEncode(entry));
    
    _events[normalizedDay] = entry;
    setState(() {});
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _showEntrySection = false;
        _diaryController.clear();
        _symptom = '';
      });
      _loadDiaryForSelectedDay();
    }
  }

  Future<void> _loadDiaryForSelectedDay() async {
    if (_selectedDay == null) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final normalizedDay = DateTime.utc(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final key = 'diary_$normalizedDay';
    final entryJson = prefs.getString(key);

    if (entryJson != null) {
      final entry = jsonDecode(entryJson);
      setState(() {
        _showEntrySection = entry['type'] == 'bad';
        _diaryController.text = entry['text'] ?? '';
        _symptom = entry['symptom'] ?? '';
      });
    } else {
      setState(() {
        _showEntrySection = false;
        _diaryController.clear();
        _symptom = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final symptomManager = Provider.of<SymptomManager>(context, listen: false);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            CustomCard(
              padding: const EdgeInsets.all(8),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: _onDaySelected,
                calendarFormat: _calendarFormat,
                headerStyle: const HeaderStyle(formatButtonVisible: false),
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                eventLoader: (day) {
                  final normalizedDay = DateTime.utc(day.year, day.month, day.day);
                  final eventType = _events[normalizedDay]?['type'];
                  if (eventType != null) {
                    return [eventType];
                  }
                  return [];
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      final isGoodDay = events.first == 'good';
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 8.0,
                          height: 8.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isGoodDay ? Colors.green[700] : Colors.red,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showEmojiPopup(context);
                        _saveDiary('good');
                        setState(() {
                          _showEntrySection = false;
                          _diaryController.clear();
                          _symptom = '';
                        });
                      },
                      icon: const Icon(Icons.sentiment_very_satisfied),
                      label: const Text('이상 없음'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8F5E9),
                        foregroundColor: Colors.green[800],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showEntrySection = true;
                          _loadDiaryForSelectedDay();
                        });
                      },
                      icon: const Icon(Icons.sentiment_very_dissatisfied),
                      label: const Text('이상 있음'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEBEE),
                        foregroundColor: Colors.red[800],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _showEntrySection
                  ? CustomCard(
                      key: const ValueKey('textInputCard'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            '증상',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: symptomManager.frequentSymptoms.map((symptom) {
                              return ChoiceChip(
                                label: Text(symptom),
                                selected: _symptom == symptom,
                                onSelected: (bool selected) {
                                  setState(() {
                                    _symptom = selected ? symptom : '';
                                    _saveDiary('bad');
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _diaryController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              hintText: '오늘의 건강 상태를 자세히 기록하세요.',
                            ),
                            maxLines: 5,
                            onChanged: (text) {
                              if (_debounce?.isActive ?? false) {
                                _debounce!.cancel();
                              }
                              _debounce = Timer(const Duration(milliseconds: 500), () {
                                _saveDiary('bad');
                              });
                            },
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmojiPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('이상 없음 😊'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}