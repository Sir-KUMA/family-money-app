import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/app_state.dart';
import 'screens/home_screen.dart';
import 'screens/jobs_screen.dart';
import 'screens/money_screen.dart';
import 'screens/bucket_list_screen.dart';
import 'screens/parent_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  await appState.load();

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
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
      home: const AppShell(),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final tabCount = state.children.length + 1;

    return DefaultTabController(
      key: ValueKey(tabCount),
      length: tabCount,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          title: const Text('おこづかいアプリ'),
          bottom: TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              ...state.children.map((c) => Tab(
                    icon: const Icon(Icons.child_care, size: 18),
                    text: c.name,
                  )),
              const Tab(
                icon: Icon(Icons.manage_accounts, size: 18),
                text: '親',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ...state.children.map((c) => ChildShell(childId: c.id)),
            const ParentScreen(),
          ],
        ),
      ),
    );
  }
}

class ChildShell extends StatefulWidget {
  final String childId;
  const ChildShell({super.key, required this.childId});

  @override
  State<ChildShell> createState() => _ChildShellState();
}

class _ChildShellState extends State<ChildShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(childId: widget.childId),
      JobsScreen(childId: widget.childId),
      MoneyScreen(childId: widget.childId),
      BucketListScreen(childId: widget.childId),
    ];

    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(
              icon: Icon(Icons.work_outline), label: 'お仕事'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              label: 'お金'),
          BottomNavigationBarItem(
              icon: Icon(Icons.star_outline), label: 'ほしいもの'),
        ],
      ),
    );
  }
}
