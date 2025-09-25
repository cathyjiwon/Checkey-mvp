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

    // 현재 월의 '이상 있음' 기록 데이터 추출
    Map<int, int> hasSymptomData = _getMonthlySymptomData(diaryManager, _focusedMonth);

    // X축(날짜)과 Y축(빈도) 값 생성
    List<FlSpot> spots = [];
    int maxDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;

    for (int i = 1; i <= maxDay; i++) {
      spots.add(FlSpot(i.toDouble(), hasSymptomData[i]?.toDouble() ?? 0));
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
                            maxY: 1.2,
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
                                  getTitlesWidget: (value, meta) {
                                    if (value == 0) return const Text('정상');
                                    if (value == 1) return const Text('이상');
                                    return const Text('');
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
                                isCurved: false, // 꺾은선으로 표현
                                color: Colors.red.shade400,
                                barWidth: 2,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) {
                                    if (spot.y == 1) {
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

  // 월별 '이상 있음' 기록 데이터 집계 함수
  Map<int, int> _getMonthlySymptomData(DiaryManager diaryManager, DateTime month) {
    Map<int, int> dailySymptomCount = {};
    
    // 해당 월의 모든 날짜에 대해 초기화
    int maxDay = DateTime(month.year, month.month + 1, 0).day;
    for (int i = 1; i <= maxDay; i++) {
      dailySymptomCount[i] = 0;
    }

    diaryManager.diaryEntries.forEach((dateString, entries) {
      DateTime date = DateTime.parse(dateString);
      if (date.year == month.year && date.month == month.month) {
        // 해당 날짜에 '이상 있음' 기록이 하나라도 있으면 1로 설정
        bool hasSymptom = entries.any((entry) => entry['status'] == '이상 있음');
        if (hasSymptom) {
          dailySymptomCount[date.day] = 1;
        }
      }
    });

    return dailySymptomCount;
  }
}