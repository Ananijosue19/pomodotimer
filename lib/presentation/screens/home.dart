import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:pomotime/presentation/screens/onePage.dart';
import 'package:remixicon/remixicon.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = 0;
  final List<Widget> pages = [Onepage(), Twopage(), ThreePage()];
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
            label: 'Timer',
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
