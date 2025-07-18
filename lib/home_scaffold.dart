import 'package:flutter/material.dart';
import 'package:smart_calorie_flutter/screens/dashboard_screen.dart';
import 'package:smart_calorie_flutter/screens/log_screen.dart';
import 'package:smart_calorie_flutter/screens/strategy_screen.dart';
// Add other screen imports as needed

class HomeScaffold extends StatefulWidget {
  const HomeScaffold({super.key});

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  int _selectedIndex = 0;

  // The list of screens that the tabs will show.
  static const List<Widget> _screens = <Widget>[
    DashboardScreen(),
    LogScreen(),
    StrategyScreen(),
    // MoreScreen(), // Add this back when you have the file
    // CheckinScreen(), // Add this back when you have the file
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body displays the currently selected screen from the list.
      body: _screens.elementAt(_selectedIndex),
      // The BottomNavigationBar provides the main navigation tabs.
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Log',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_outlined),
            activeIcon: Icon(Icons.insights),
            label: 'Strategy',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}