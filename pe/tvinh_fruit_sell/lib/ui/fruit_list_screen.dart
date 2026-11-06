import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tvinh_fruit_sell/provider/fruit_notifier.dart';

class FruitListScreen extends ConsumerWidget {
  const FruitListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fruitListAsyncValue = ref.watch(fruitNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fruit Shop',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Fresh fruits & expiry tracking',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          // Task 5: Nút mở màn hình Expiry Warning Screen
          IconButton(
            tooltip: 'Expiry Warnings',
            icon: const Icon(Icons.event_busy),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (_) => const ExpiryWarningScreen()),
              // );
            },
          ),
        ],
      ),

      body: fruitListAsyncValue.when(
        data: (fruits) => fruits.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.green.shade50,
                        child: Icon(
                          Icons.eco,
                          size: 36,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No fruits yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap the + button to add your first fruit\n and start tracking expiry dates.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                itemCount: fruits.length,
                itemBuilder: (context, index) {
                  final fruit = fruits[index];
                  return ListTile(
                    title: Text(fruit.name),
                    subtitle: Text(
                      'Origin: ${fruit.origin}, Price: \$${fruit.price.toStringAsFixed(2)}, Expired: ${fruit.expiredDate}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await ref
                            .read(fruitNotifierProvider.notifier)
                            .deleteFruit(fruit.id);
                      },
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
