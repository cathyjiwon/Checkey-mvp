import 'package:flutter/material.dart';

class NotificationManager with ChangeNotifier {
  // 여기에 알림 관련 로직을 추가하세요.
  // 이 클래스가 변경되면 notifyListeners()를 호출해야 합니다.

  void someFunction() {
    // ...
    notifyListeners();
  }
}