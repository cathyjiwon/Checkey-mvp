import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:solusmvp/services/diary_manager.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime _focusedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final diaryManager = Provider.of<DiaryManager>(context);

    // 현재 월의 '이상 있음' 기록 빈도 데이터 추출
    Map<int, int> dailySymptomCount = _getDailySymptomCount(diaryManager, _focusedMonth);
    Map<int, List<DateTime>> dailySymptomTimestamps = _getDailySymptomTimestamps(diaryManager, _focusedMonth);

    // 증상별 빈도 및 발생 날짜/시간 정보 계산
    Map<String, List<DateTime>> symptomOccurrences = _getSymptomOccurrences(diaryManager);

    // X축(날짜)과 Y축(빈도) 값 생성
    List<FlSpot> spots = [];
    int maxDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    int maxSymptomCount = 0;

    for (int i = 1; i <= maxDay; i++) {
      int count = dailySymptomCount[i] ?? 0;
      spots.add(FlSpot(i.toDouble(), count.toDouble()));
      if (count > maxSymptomCount) {
        maxSymptomCount = count;
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '건강 일기 통계',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildMonthSelector(),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 250,
                        child: LineChart(
                          LineChartData(
                            minX: 1,
                            maxX: maxDay.toDouble(),
                            minY: 0,
                            maxY: maxSymptomCount.toDouble() + 1,
                            lineTouchData: LineTouchData(
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipItems: (List<FlSpot> touchedSpots) {
                                  return touchedSpots.map((FlSpot touchedSpot) {
                                    final day = touchedSpot.x.toInt();
                                    final count = touchedSpot.y.toInt();
                                    final timestamps = dailySymptomTimestamps[day] ?? [];
                                    
                                    if (count == 0) {
                                      return null;
                                    }

                                    final dateString = DateFormat('yyyy.MM.dd').format(DateTime(_focusedMonth.year, _focusedMonth.month, day));
                                    final timeStrings = timestamps.map((ts) => DateFormat('a h:mm', 'ko_KR').format(ts)).join('\n');
                                    
                                    return LineTooltipItem(
                                      '$dateString\n$timeStrings',
                                      const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    );
                                  }).toList();
                                },
                                
                              ),
                              handleBuiltInTouches: true,
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    if (value % 5 == 0) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          '${value.toInt()}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1, // ✨ 추가된 부분
                                  getTitlesWidget: (value, meta) {
                                    if (value == 0) return const Text('0회');
                                    return Text('${value.toInt()}회');
                                  },
                                  reservedSize: 40,
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawHorizontalLine: true,
                              drawVerticalLine: true,
                              verticalInterval: 5,
                              horizontalInterval: 1,
                              getDrawingHorizontalLine: (value) {
                                return const FlLine(color: Colors.grey, strokeWidth: 0.5);
                              },
                              getDrawingVerticalLine: (value) {
                                return const FlLine(color: Colors.grey, strokeWidth: 0.5);
                              },
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: false,
                                color: Colors.red.shade400,
                                barWidth: 2,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) {
                                    if (spot.y > 0) {
                                      return FlDotCirclePainter(
                                        radius: 4,
                                        color: Colors.red.shade600,
                                        strokeWidth: 2,
                                        strokeColor: Colors.white,
                                      );
                                    }
                                    return FlDotCirclePainter(
                                      radius: 0,
                                      color: Colors.transparent,
                                      strokeWidth: 0,
                                      strokeColor: Colors.transparent,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 증상별 빈도 및 날짜/시간 표
              _buildSymptomFrequencyTable(symptomOccurrences),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_left, size: 30),
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
            });
          },
        ),
        Text(
          DateFormat('yyyy년 M월', 'ko_KR').format(_focusedMonth),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_right, size: 30),
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
            });
          },
        ),
      ],
    );
  }

  Map<int, int> _getDailySymptomCount(DiaryManager diaryManager, DateTime month) {
    Map<int, int> dailySymptomCount = {};
    
    diaryManager.diaryEntries.forEach((dateString, entries) {
      DateTime date = DateTime.parse(dateString);
      if (date.year == month.year && date.month == month.month) {
        int count = entries.where((entry) => entry['status'] == '이상 있음').length;
        if (count > 0) {
          dailySymptomCount[date.day] = count;
        }
      }
    });
    return dailySymptomCount;
  }

  Map<int, List<DateTime>> _getDailySymptomTimestamps(DiaryManager diaryManager, DateTime month) {
    Map<int, List<DateTime>> timestamps = {};
    diaryManager.diaryEntries.forEach((dateString, entries) {
      DateTime date = DateTime.parse(dateString);
      if (date.year == month.year && date.month == month.month) {
        List<DateTime> dailyTimestamps = [];
        for (var entry in entries) {
          if (entry['status'] == '이상 있음' && entry.containsKey('timestamp')) {
            dailyTimestamps.add(DateTime.parse(entry['timestamp']));
          }
        }
        if (dailyTimestamps.isNotEmpty) {
          timestamps[date.day] = dailyTimestamps;
        }
      }
    });
    return timestamps;
  }
  
  Map<String, List<DateTime>> _getSymptomOccurrences(DiaryManager diaryManager) {
    Map<String, List<DateTime>> occurrences = {};
    diaryManager.diaryEntries.forEach((dateString, entries) {
      for (var entry in entries) {
        if (entry['status'] == '이상 있음') {
          List<String> allSymptoms = [];
          if (entry.containsKey('frequentSymptoms') && entry['frequentSymptoms'] != null) {
            allSymptoms.addAll(List<String>.from(entry['frequentSymptoms']));
          }
          if (entry.containsKey('otherSymptoms') && entry['otherSymptoms'] != null) {
            allSymptoms.addAll(List<String>.from(entry['otherSymptoms']));
          }
          if (entry.containsKey('customSymptom') && entry['customSymptom'] != null && entry['customSymptom'].isNotEmpty) {
            allSymptoms.add(entry['customSymptom']);
          }

          DateTime? timestamp = entry.containsKey('timestamp') ? DateTime.tryParse(entry['timestamp']) : null;
          if (timestamp != null) {
            for (String symptom in allSymptoms) {
              if (!occurrences.containsKey(symptom)) {
                occurrences[symptom] = [];
              }
              occurrences[symptom]!.add(timestamp);
            }
          }
        }
      }
    });
    return occurrences;
  }

  Widget _buildSymptomFrequencyTable(Map<String, List<DateTime>> occurrences) {
    if (occurrences.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedSymptoms = occurrences.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '증상별 빈도 및 발생 시점',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                columns: const [
                  DataColumn(
                    label: Text(
                      '증상',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      '횟수',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      '발생 시점',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: sortedSymptoms.map((entry) {
                  final dates = entry.value.map((dt) {
                    return DateFormat('yyyy.MM.dd HH:mm').format(dt);
                  }).join('\n');
                  return DataRow(
                    cells: [
                      DataCell(Text(entry.key)),
                      DataCell(Text('${entry.value.length}회')),
                      DataCell(
                        SizedBox(
                          width: 150,
                          child: Text(
                            dates,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}