import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('증상 및 약물', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('자주 겪는 증상과 복용 중인 약물을 미리 저장하고 관리하세요.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final TabController? tabController = DefaultTabController.of(context);
                      if (tabController != null) {
                        tabController.animateTo(1);
                      }
                    },
                    child: const Text('바로가기'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('건강 일기', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('오늘의 건강 상태를 기록하고 이모지로 표현해 보세요.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final TabController? tabController = DefaultTabController.of(context);
                      if (tabController != null) {
                        tabController.animateTo(2);
                      }
                    },
                    child: const Text('바로가기'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('통계', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('나의 건강 기록을 한눈에 그래프로 확인하고 분석하세요.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final TabController? tabController = DefaultTabController.of(context);
                      if (tabController != null) {
                        tabController.animateTo(3);
                      }
                    },
                    child: const Text('바로가기'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('솔루션', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('기록을 기반으로 맞춤형 건강 솔루션을 확인하세요.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final TabController? tabController = DefaultTabController.of(context);
                      if (tabController != null) {
                        tabController.animateTo(4);
                      }
                    },
                    child: const Text('바로가기'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}