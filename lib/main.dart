import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/app_state.dart';
import 'screens/home_screen.dart';
import 'screens/jobs_screen.dart';
import 'screens/money_screen.dart';
import 'screens/bucket_list_screen.dart';
import 'screens/parent_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'おこづかいアプリ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
        useMaterial3: true,
        textTheme: GoogleFonts.notoSansJpTextTheme(),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    JobsScreen(),
    MoneyScreen(),
    BucketListScreen(),
    ParentScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'お仕事'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: 'お金'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'ほしいもの'),
          BottomNavigationBarItem(icon: Icon(Icons.supervisor_account), label: '親'),
        ],
      ),
    );
  }
}
