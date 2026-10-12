import 'package:flutter/material.dart';
import 'package:s7_planner_app_pickers_theming_nav/screens/home_screen.dart';
import 'package:s7_planner_app_pickers_theming_nav/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
