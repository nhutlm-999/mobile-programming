import 'package:flutter/material.dart';
import 'package:s5_reactive_counter_app/service/counter_stream_service.dart';

class HomeScreen extends StatelessWidget {
  final CounterStreamService service;
  const HomeScreen({super.key, required this.service});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reactive Counter')),
      body: Center(
        child: StreamBuilder<int>(
          stream: service.counterStream,
          builder: (context, snapshot) {
            print('UI rebuild');
            if (!snapshot.hasData) {
              return Text('Waiting...');
            }
            return Text(
              snapshot.data.toString(),
              style: TextStyle(fontSize: 40),
            );
          },
        ),
      ),
    );
  }
}
