import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lab4_15oct/data/models/bill.dart';
import 'package:lab4_15oct/presentation/providers/bill_providers.dart';

class AddBillScreen extends ConsumerStatefulWidget {
  const AddBillScreen({super.key});

  @override
  ConsumerState<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends ConsumerState<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();

  final _billNameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _dueDate = DateTime.now();

  String get _formattedDate {
    final year = _dueDate.year.toString().padLeft(4, '0');
    final month = _dueDate.month.toString().padLeft(2, '0');
    final day = _dueDate.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  @override
  void dispose() {
    _billNameController.dispose();
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _dueDate = selectedDate;
      });
    }
  }

  Future<void> _saveBill() async {
    // Dừng lại nếu form không hợp lệ.
    if (!_formKey.currentState!.validate()) return;

    final bill = Bill(
      billName: _billNameController.text.trim(),
      category: _categoryController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      status: 'Unpaid',
      dueDate: _formattedDate,
    );

    try {
      await ref.read(billsProvider.notifier).addBill(bill);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bill added successfully')));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to add bill: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Bill')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _billNameController,
                decoration: const InputDecoration(
                  labelText: "Bill name",
                  hintText: "e.g. Internet ...",
                  prefixIcon: Icon(Icons.receipt_long),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a bill name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: "Category",
                  hintText: "e.g. Utilities ...",
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  hintText: "e.g. 100.00 ...",
                  prefixIcon: Icon(Icons.monetization_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value.trim());

                  if (amount == null || amount <= 0) {
                    return 'Amount must be a number greater than 0';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Due Date",
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(_formattedDate),
                ),
              ),
              const SizedBox(height: 32),

              FilledButton.icon(
                onPressed: _saveBill,
                icon: const Icon(Icons.save),
                label: const Text('Save Bill'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
