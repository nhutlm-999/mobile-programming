import 'package:flutter/material.dart';
import 'package:lab4_15oct/core/theme/app_theme.dart';
import 'package:lab4_15oct/presentation/screens/add_bill_screen.dart';
import 'package:lab4_15oct/presentation/screens/home_screen.dart';
import 'package:lab4_15oct/presentation/screens/update_bill_Screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: BillsApp()));
}

class BillsApp extends StatelessWidget {
  const BillsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manage Recurring Bills',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Builder(
        builder: (context) {
          return HomeScreen(
            onAddBill: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddBillScreen()),
              );
            },
            onBillTap: (bill) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateBillScreen(bill: bill),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
