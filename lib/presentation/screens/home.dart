import 'package:flutter/material.dart';
import 'package:pomotime/presentation/screens/timer_page.dart';
import 'package:pomotime/presentation/screens/settings_page.dart';
import 'package:pomotime/presentation/screens/stats_page.dart';
import 'package:remixicon/remixicon.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = 0;
  final List<Widget> pages = [
    const TimerPage(),
    const SettingsPage(),
    const StatsPage(),
  ];
  void _onItemTapped(int index) {
    setState(() => selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Remix.timer_2_line),
            label: 'Minuteur',
          ),
          BottomNavigationBarItem(
            icon: Icon(Remix.settings_3_line),
            label: 'Paramètres',
          ),
          BottomNavigationBarItem(
            icon: Icon(Remix.bar_chart_2_line),
            label: 'Stats',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.redAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}
