import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/bill.dart';
import '../providers/bill_providers.dart';
import '../widgets/bill_card.dart';

class HomeScreen extends ConsumerWidget {
  final VoidCallback onAddBill;
  final ValueChanged<Bill> onBillTap;

  const HomeScreen({
    super.key,
    required this.onAddBill,
    required this.onBillTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(billsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recurring Bills',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onAddBill,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Banner
          // Bill list
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.teal, Colors.tealAccent],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Your Bills',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Keep track of your recurring payments.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),

          Expanded(
            child: billsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error loading bills: $error',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(billsProvider.notifier).reload();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (bills) {
                if (bills.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long, size: 56, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No bills yet'),
                        Text('Tap + to add your first bill.'),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: bills.length,
                  itemBuilder: (context, index) {
                    return BillCard(
                      bill: bills[index],
                      onTap: () => onBillTap(bills[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
