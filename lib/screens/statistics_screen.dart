import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_card.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<FlSpot> _goodSpots = [];
  List<FlSpot> _badSpots = [];
  double _minX = 0;
  double _maxX = 6;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

Future<void> _loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    final Map<DateTime, String> diaryEntries = {};

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
              diaryEntries[normalizedDate] = entry['type'];
            } catch (e) {
              // JSON 파싱 실패 시, 이전의 문자열 형식 데이터로 처리
              // 이전 '이상 없음' 텍스트 데이터의 경우 'good' 타입으로 간주
              diaryEntries[normalizedDate] = entryJson == '이상 없음' ? 'good' : 'bad';
            }
          }
        }
      }
    }

    final now = DateTime.now();
    final List<DateTime> last7Days = List.generate(7, (index) {
      return DateTime.utc(now.year, now.month, now.day).subtract(Duration(days: 6 - index));
    });

    final List<FlSpot> goodSpots = [];
    final List<FlSpot> badSpots = [];

    for (int i = 0; i < last7Days.length; i++) {
      final day = last7Days[i];
      final entryType = diaryEntries[day];

      if (entryType == 'good') {
        goodSpots.add(FlSpot(i.toDouble(), 1));
        badSpots.add(FlSpot(i.toDouble(), 0));
      } else if (entryType == 'bad') {
        goodSpots.add(FlSpot(i.toDouble(), 0));
        badSpots.add(FlSpot(i.toDouble(), 1));
      } else {
        goodSpots.add(FlSpot(i.toDouble(), 0));
        badSpots.add(FlSpot(i.toDouble(), 0));
      }
    }

    setState(() {
      _goodSpots = goodSpots;
      _badSpots = badSpots;
      _minX = 0;
      _maxX = 6;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '최근 7일 간의 건강 상태',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                final now = DateTime.now();
                                final day = now.subtract(Duration(days: 6 - value.toInt()));
                                final formattedDay = '${day.month}/${day.day}';
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(formattedDay, style: const TextStyle(fontSize: 10)),
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: _leftTitles,
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineTouchData: const LineTouchData(enabled: false), // 이 부분을 수정했습니다.
                        minX: _minX,
                        maxX: _maxX,
                        minY: 0,
                        maxY: 1.5,
                        lineBarsData: [
                          LineChartBarData(
                            spots: _goodSpots,
                            isCurved: true,
                            color: Colors.green,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(show: false),
                          ),
                          LineChartBarData(
                            spots: _badSpots,
                            isCurved: true,
                            color: Colors.red,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIndicator(Colors.green, '이상 없음'),
                      const SizedBox(width: 20),
                      _buildIndicator(Colors.red, '이상 있음'),
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

  static Widget _leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0';
        break;
      case 1:
        text = '1';
        break;
      default:
        return Container();
    }
    return Text(text, style: style, textAlign: TextAlign.center);
  }

  Widget _buildIndicator(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}