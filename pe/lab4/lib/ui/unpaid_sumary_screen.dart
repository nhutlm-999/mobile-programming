import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lab4/provider/bill_notifier.dart';
import 'package:lab4/ui/bill_list_screen.dart';

class UnpaidSummaryScreen extends ConsumerStatefulWidget {
  const UnpaidSummaryScreen({super.key});

  @override
  ConsumerState<UnpaidSummaryScreen> createState() =>
      _UnpaidSummaryScreenState();
}

class _UnpaidSummaryScreenState extends ConsumerState<UnpaidSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    final billAsync = ref.watch(billNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: billAsync.when(
        data: (allBills) {
          final unpaidBills = allBills
              .where((bill) => bill.status == 'Unpaid')
              .toList();

          // Tính tổng số tiền chưa thanh toán (sum of all unpaid bills)
          // final double totalOutstanding = unpaidBills.fold<double>(
          //   0.0,
          //   (sum, bill) => sum + bill.amount,
          // );

          double sum = 0;
          for (var bill in unpaidBills) {
            sum += bill.amount;
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.amber.shade100,
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.orange,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Unpaid Bills",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${unpaidBills.length} bills unpaid",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  const SizedBox(height: 16),
                  // Danh sách các hóa đơn Unpaid
                  if (unpaidBills.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'All bills are paid! No outstanding bills.',
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: unpaidBills.length,
                      itemBuilder: (context, index) {
                        final bill = unpaidBills[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange.shade100,
                              child: Text("${index + 1}"),
                            ),
                            title: Text(
                              bill.billName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              bill.category,
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Text(
                              BillListScreen.formatVnd(bill.amount),
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 16),
                  // Tổng số tiền chưa thanh toán
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.receipt,
                              size: 18,
                              color: Colors.black87,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Outstanding Summary',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Number of unpaid bills:',
                              style: TextStyle(color: Colors.black54),
                            ),
                            Text(
                              '${unpaidBills.length}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total outstanding amount:',
                              style: TextStyle(color: Colors.black54),
                            ),
                            Text(
                              BillListScreen.formatVnd(sum),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
    );
  }
}
