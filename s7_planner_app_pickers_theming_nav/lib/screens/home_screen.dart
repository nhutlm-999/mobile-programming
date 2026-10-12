import 'package:flutter/material.dart';
import 'package:s7_planner_app_pickers_theming_nav/model/plan.dart';

import '../widgets/primary_button.dart';
import 'create_plan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Plan> _plans = [];
  Future<void> _goToCreatePlan(BuildContext context) async {
    // 1) push sang màn hình tạo plan
    final result = await Navigator.push<Plan>(
      context,
      MaterialPageRoute(builder: (_) => const CreatePlanScreen()),
    );
    // 2) result có thể null nếu người dùng bấm back hoặc cancel
    if (result == null) return;
    // 3) có data -> cập nhật UI
    setState(() {
      _plans.insert(0, result);
    });
  }

  String _formatDate(DateTime date) {
    // format đơn giản: YYYY-MM-DD
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return "$y-$m-$d";
  }

  String _formatTime(TimeOfDay time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return "$hh:$mm";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Planner')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PrimaryButton(
              text: 'Create Plan',
              onPressed: () => _goToCreatePlan(context),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _plans.isEmpty
                  ? const Center(
                      child: Text(
                        'No plans yet.\nTap "Create Plan" to add one.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      itemCount: _plans.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final plan = _plans[index];
                        return Card(
                          child: ListTile(
                            title: Text(plan.title),
                            subtitle: Text(
                              '${_formatDate(plan.date)} • ${_formatTime(plan.time)}',
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
