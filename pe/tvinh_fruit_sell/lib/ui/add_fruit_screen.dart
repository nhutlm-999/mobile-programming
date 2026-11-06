import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FruitFormScreen extends ConsumerStatefulWidget {
  const FruitFormScreen({super.key});

  @override
  ConsumerState<FruitFormScreen> createState() => _FruitFormScreenState();
}

class _FruitFormScreenState extends ConsumerState<FruitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _originCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _originCtrl.dispose();
    _priceCtrl.dispose();
    _expiryCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _expiryCtrl.text = DateTime.now().toIso8601String().split('T').first;
  }

  String _formatIsoDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
