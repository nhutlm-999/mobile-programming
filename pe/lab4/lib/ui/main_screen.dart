import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lab4/ui/bill_list_screen.dart';
import 'package:lab4/ui/unpaid_sumary_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = const [BillListScreen(), UnpaidSummaryScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Bills'),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Unpaid Summary',
          ),
        ],
      ),
    );
  }
}
