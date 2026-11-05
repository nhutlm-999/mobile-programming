import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lab3/ui/brand_list_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _switchToStoreTab() {
    setState(() {
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [const BrandListScreen()];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Store'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Add Computer',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Brands'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Featured'),
        ],
      ),
    );
  }
}
