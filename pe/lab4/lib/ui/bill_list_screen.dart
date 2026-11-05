import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lab4/provider/bill_notifier.dart';
import 'package:lab4/ui/bill_form_screen.dart';

class BillListScreen extends ConsumerWidget {
  const BillListScreen({super.key});

  // Hàm định dạng số tiền sang kiểu VND: 850000 -> "850.000 ₫"
  static String formatVnd(double amount) {
    final intVal = amount.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < intVal.length; i++) {
      if (i > 0 && (intVal.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(intVal[i]);
    }
    return '${buffer.toString()} ₫';
  }

  // Chọn icon phù hợp cho từng Category giống Figure 1
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Utilities':
        return Icons.bolt;
      case 'Rent':
        return Icons.home_work_outlined;
      case 'Subscription':
        return Icons.wifi;
      case 'Finance':
        return Icons.account_balance_wallet_outlined;
      case 'Health':
        return Icons.favorite_border;
      default:
        return Icons.receipt_long;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billAsync = ref.watch(billNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/bill.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blueGrey.shade800,
                            Colors.indigo.shade600,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'RECURRING BILLS MANAGER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.black54,
                  child: const Text(
                    "Recurring Bills",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight(600),
                    ),
                  ),
                ),
              ],
            ),

            Expanded(
              child: billAsync.when(
                data: (bills) => bills.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No bills yet!\nPress "+" button to add your recurring bills',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: bills.length,
                        itemBuilder: (context, index) {
                          final bill = bills[index];
                          final bool isPaid = bill.status == 'Paid';
                          return Card(
                            margin: EdgeInsets.all(8),
                            elevation: 1.5,
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        BillFormScreen(existingBill: bill),
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                child: Icon(
                                  getCategoryIcon(bill.category),
                                  color: Colors.purple,
                                ),
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  226,
                                  219,
                                  219,
                                ),
                              ),
                              title: Text(
                                bill.billName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${bill.category}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 13,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Due: ${bill.dueDate}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    formatVnd(bill.amount),
                                    style: TextStyle(
                                      color: Colors.purple,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isPaid
                                          ? Colors.green
                                          : Colors.orange,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      isPaid ? 'Paid' : 'Unpaid',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                error: (error, stackTrace) {
                  debugPrint("Lỗi SQLite/Provider: $error");
                  debugPrint("StackTrace: $stackTrace");
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Lỗi: $error",
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        onPressed: () {
          // Mở màn hình Add New Bill (Task 2)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BillFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
