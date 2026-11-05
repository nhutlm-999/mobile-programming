import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lab4/model/bill.dart';
import 'package:lab4/provider/bill_notifier.dart';

class BillFormScreen extends ConsumerStatefulWidget {
  final Bill? existingBill;
  const BillFormScreen({super.key, this.existingBill});

  @override
  ConsumerState<BillFormScreen> createState() => _BillFormScreenState();
}

class _BillFormScreenState extends ConsumerState<BillFormScreen> {
  static const List<String> _categories = [
    'Utilities',
    'Subscription',
    'Rent',
    'Finance',
    'Health',
  ];
  static const List<String> _statuses = ['Unpaid', 'Paid'];

  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _dueDateCtrl;

  String _selectedCategory = 'Utilities';
  String _selectedStatus = 'Unpaid';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _dueDateCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final bill = widget.existingBill;
    _nameCtrl = TextEditingController(text: bill?.billName ?? '');
    // _amountCtrl = TextEditingController(text: bill?.amount.toString() ?? '');
    _amountCtrl = TextEditingController(
      text: bill != null ? bill.amount.toStringAsFixed(0) : '',
    );
    _dueDateCtrl = TextEditingController(text: bill?.dueDate ?? '');

    if (bill != null && _categories.contains(bill.category)) {
      _selectedCategory = bill.category;
    }

    if (bill != null && _statuses.contains(bill.status)) {
      _selectedStatus = bill.status;
    }
  }

  // Mở DatePicker và điền ngày theo chuẩn ISO 'YYYY-MM-DD'
  Future<void> _pickDueDate() async {
    final initial =
        DateTime.tryParse(_dueDateCtrl.text.trim()) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final y = picked.year.toString().padLeft(4, '0');
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      setState(() {
        _dueDateCtrl.text = '$y-$m-$d';
      });
    }
  }

  // Hiển thị AlertDialog thông báo (Figure 2)
  Future<void> _showMessageDialog(String title, String message) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSaveOrUpdate() async {
    final name = _nameCtrl.text.trim();
    final amountText = _amountCtrl.text.trim();
    final dueDate = _dueDateCtrl.text.trim();

    // 1. Validate Bill Name (Chuẩn Figure 2: "Please enter bill name")
    if (name.isEmpty) {
      await _showMessageDialog('Validation', 'Please enter bill name');
      return;
    }
    // 2. Validate Amount
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      await _showMessageDialog(
        'Validation',
        'Please enter a valid amount (> 0)',
      );
      return;
    }
    // 3. Validate Due Date (YYYY-MM-DD)
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (dueDate.isEmpty ||
        !dateRegex.hasMatch(dueDate) ||
        DateTime.tryParse(dueDate) == null) {
      await _showMessageDialog(
        'Validation',
        'Please enter a valid due date in YYYY-MM-DD format',
      );
      return;
    }

    final bill = Bill(
      id: widget.existingBill?.id,
      billName: name,
      category: _selectedCategory,
      amount: amount,
      status: _selectedStatus,
      dueDate: dueDate,
    );

    final isUpdating = widget.existingBill != null;
    if (!isUpdating) {
      await ref.read(billNotifierProvider.notifier).addObject(bill);
      if (!mounted) return;
      await _showMessageDialog('Success', 'Bill added successfully');
      if (mounted) Navigator.pop(context);
    } else {
      await ref.read(billNotifierProvider.notifier).updateObject(bill);
      if (!mounted) return;
      await _showMessageDialog('Success', 'Bill updated successfully');
      if (mounted) Navigator.pop(context);
    }
  }

  // Xử lý khi bấm nút Delete trên màn hình Update (Figure 2 & Figure 4)
  Future<void> _handleDelete() async {
    final bill = widget.existingBill;
    if (bill == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this bill?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(billNotifierProvider.notifier).deleteObject(bill.id!);
      if (!mounted) return;
      await _showMessageDialog('Success', 'Bill deleted');
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isUpdating = widget.existingBill != null;
    return Scaffold(
      appBar: AppBar(title: Text(isUpdating ? "Update Bill" : "Add Bill")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Bill Name
            const Text(
              'Bill Name *',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. Electricity - September',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),

            // 2. Category
            const Text(
              'Category *',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _categories
                  .map(
                    (cate) => DropdownMenuItem(value: cate, child: Text(cate)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),

            // 3. Amount (VND)
            const Text(
              'Amount (VND) *',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'e.g. 850000',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            // 4. Due Date (YYYY-MM-DD)
            const Text(
              'Due Date (YYYY-MM-DD) *',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _dueDateCtrl,
              decoration: InputDecoration(
                hintText: 'e.g. 2025-10-30',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: _pickDueDate,
                ),
              ),
              onTap: _pickDueDate,
            ),
            const SizedBox(height: 14),
            // 5. Status ('Unpaid' / 'Paid')
            const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _statuses
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedStatus = val);
              },
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      _handleSaveOrUpdate();
                    },
                    icon: Icon(
                      isUpdating ? Icons.edit_note : Icons.check_circle,
                      size: 18,
                    ),
                    label: Text(isUpdating ? "Update" : "Add"),
                  ),
                ),
                const SizedBox(width: 12),

                if (isUpdating) const SizedBox(width: 8),
                ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      // onPressed: _handleDelete,
                      onPressed: () {
                        _handleDelete();
                      },
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete'),
                    ),
                  ),
                ],

                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                    label: Text("Cancel"),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
