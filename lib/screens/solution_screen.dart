import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';

class SolutionScreen extends StatelessWidget {
  const SolutionScreen({super.key});

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
                children: const [
                  Text(
                    '맞춤형 솔루션',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text('건강 기록을 기반으로 한 맞춤형 솔루션이 여기에 표시됩니다. '
                       '더 많은 데이터를 기록할수록 더 정확한 정보를 얻을 수 있습니다.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}