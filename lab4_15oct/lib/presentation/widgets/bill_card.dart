import 'package:flutter/material.dart';
import 'package:lab4_15oct/data/models/bill.dart';

class BillCard extends StatelessWidget {
  final Bill bill;
  final VoidCallback? onTap;

  const BillCard({super.key, required this.bill, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPaid = bill.status == 'Paid';

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: isPaid ? Colors.green.shade100 : Colors.red,
          child: Icon(isPaid ? Icons.check : Icons.close, color: Colors.white),
        ),
        title: Text(
          bill.billName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bill.category),
              const SizedBox(height: 4),
              Text('Due: ${bill.dueDate}'),
              const SizedBox(height: 4),
              Text(
                '${bill.amount.toStringAsFixed(0)} VND',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPaid ? Icons.check_circle : Icons.pending_actions,
              color: isPaid ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 4),
            Text(
              bill.status,
              style: TextStyle(
                color: isPaid ? Colors.green : Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
