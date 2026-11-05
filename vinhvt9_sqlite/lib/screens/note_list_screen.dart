import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vinhvt9_sqlite/models/note.dart';
import 'package:vinhvt9_sqlite/providers/note_notifier.dart';

class NoteListScreen extends ConsumerStatefulWidget {
  const NoteListScreen({super.key});

  @override
  ConsumerState<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends ConsumerState<NoteListScreen> {
  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(noteProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Note List')),
      body: notes.when(
        data: (notes) => notes.isEmpty
            ? Text("no data")
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                ),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return Card(
                    child: Column(
                      children: [Text(note.title), Text(note.content)],
                    ),
                  );
                },
              ),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ref
              .read(noteProvider.notifier)
              .addNote(new Note(title: "a", content: "b"));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
