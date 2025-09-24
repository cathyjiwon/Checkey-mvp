import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solusmvp/services/symptom_manager.dart';
import 'package:solusmvp/screens/diary_screen.dart';
import 'package:solusmvp/screens/home_screen.dart';
import 'package:solusmvp/screens/statistics_screen.dart';
// SolutionScreen import 제거
import 'package:solusmvp/screens/medication_screen.dart';
import 'package:solusmvp/widgets/frequent_symptom_drawer.dart';
import 'package:solusmvp/widgets/medication_manager_drawer.dart';
import 'package:solusmvp/services/diary_manager.dart';
import 'package:solusmvp/services/medication_manager.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SymptomManager()),
        ChangeNotifierProvider(create: (context) => DiaryManager()),
        ChangeNotifierProvider(create: (context) => MedicationManager()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 'Solus MVP'를 'Checkey'로 변경
      title: 'Checkey',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[50],
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          toolbarTextStyle: const TextStyle(color: Colors.black),
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    MedicationScreen(),
    DiaryScreen(),
    StatisticsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _widgetOptions.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 'Solus MVP'를 'Checkey'로 변경
        title: const Text('Checkey'),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text(
                '메뉴',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('홈'),
              selected: _tabController.index == 0,
              onTap: () {
                _tabController.animateTo(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.medication),
              title: const Text('약 복용'),
              selected: _tabController.index == 1,
              onTap: () {
                _tabController.animateTo(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('건강 일기'),
              selected: _tabController.index == 2,
              onTap: () {
                _tabController.animateTo(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('통계'),
              selected: _tabController.index == 3,
              onTap: () {
                _tabController.animateTo(3);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.medication),
              title: const Text('복용 중인 약 관리'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MedicationManagerDrawer()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.sick_outlined),
              title: const Text('자주 발생하는 증상 관리'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FrequentSymptomDrawer()),
                );
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: '약 복용',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '일기',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '통계',
          ),
        ],
        currentIndex: _tabController.index,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          _tabController.animateTo(index);
        },
      ),
    );
  }
}