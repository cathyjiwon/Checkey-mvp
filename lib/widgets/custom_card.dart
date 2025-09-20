import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final double elevation;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const CustomCard({
    super.key,
    required this.child,
    this.elevation = 2.0, // 토스 앱처럼 은은한 그림자를 위해 elevation을 2.0으로 높임
    this.padding = const EdgeInsets.all(20.0), // 내부 여백을 넓혀 깔끔한 느낌 강조
    this.margin = const EdgeInsets.symmetric(vertical: 10.0), // 위아래 간격을 넓게 설정
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      margin: margin,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // 더 부드러운 모서리를 위해 값을 20.0으로 변경
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}