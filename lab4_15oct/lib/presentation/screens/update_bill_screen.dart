import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lab4_15oct/data/models/bill.dart';
import 'package:lab4_15oct/presentation/providers/bill_providers.dart';

class UpdateBillScreen extends ConsumerStatefulWidget {
  final Bill bill;

  const UpdateBillScreen({super.key, required this.bill});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _UpdateBillScreen();
  }
}

class _UpdateBillScreen extends ConsumerState<UpdateBillScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _billNameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _amountController;

  late DateTime _dueDate;
  late String _status;

  String get _formattedDate {
    final year = _dueDate.year.toString().padLeft(4, '0');
    final month = _dueDate.month.toString().padLeft(2, '0');
    final day = _dueDate.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
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

  @override
  void initState() {
    super.initState();
    _billNameController = TextEditingController(text: widget.bill.billName);
    _categoryController = TextEditingController(text: widget.bill.category);
    _amountController = TextEditingController(
      text: widget.bill.amount.toStringAsFixed(0),
    );

    _dueDate = DateTime.parse(widget.bill.dueDate);
    _status = widget.bill.status;
  }

  @override
  void dispose() {
    _billNameController.dispose();
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _updateBill() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedBill = widget.bill.copyWith(
      billName: _billNameController.text.trim(),
      category: _categoryController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      status: _status,
      dueDate: _formattedDate,
    );

    try {
      await ref.read(billsProvider.notifier).updateBill(updatedBill);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill updated successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update bill: $e')));
    }
  }

  Future<void> _deleteBill() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Bill'),
        content: Text(
          'Are you sure you want to delete '
          '"${widget.bill.billName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final id = widget.bill.id;
    if (id == null) return;

    try {
      await ref.read(billsProvider.notifier).deleteBill(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill deleted successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to delete bill: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Bill'),
        actions: [
          IconButton(
            onPressed: _deleteBill,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete Bill',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _billNameController,
                decoration: const InputDecoration(
                  labelText: 'Bill Name',
                  prefixIcon: Icon(Icons.receipt_long),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter bill name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount (VND)',
                  prefixIcon: Icon(Icons.payments),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter amount';
                  }

                  final amount = double.tryParse(value.trim());

                  if (amount == null || amount <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.check_circle_outline),
                ),
                items: const [
                  DropdownMenuItem(value: 'Unpaid', child: Text('Unpaid')),
                  DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _status = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    prefixIcon: Icon(Icons.calendar_month),
                  ),
                  child: Text(_formattedDate),
                ),
              ),
              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: _updateBill,
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
