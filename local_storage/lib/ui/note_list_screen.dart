import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_storage/providers/note_notifier.dart';

class NoteListScreen extends ConsumerStatefulWidget {
  const NoteListScreen({super.key});

  @override
  ConsumerState<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends ConsumerState<NoteListScreen> {
  Future<void> _showDeleteConfirmationDialog(int noteId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure you want to delete this note?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                // Call the delete method from the provider
                ref.read(noteProvider.notifier).deleteNote(noteId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(noteProvider);

    return GridView.count(
      crossAxisCount: 2,
      children: notes
          .map(
            (n) => Card(
              child: Column(
                children: [
                  Text(n.title),
                  Text(n.content),
                  IconButton(
                    onPressed: () {
                      _showDeleteConfirmationDialog(n.id);
                      // Khong show dialog
                      // ref.read(noteProvider.notifier).deleteNote(n.id);
                    },
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      // [
      //   Card(
      //     child: Column(
      //       children: [
      //         Text('Note 1'),
      //         Text('Content of note 1'),
      //         IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
      //       ],
      //     ),
      //   ),
      //   Card(
      //     child: Column(
      //       children: [
      //         Text('Note 1'),
      //         Text('Content of note 1'),
      //         IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
      //       ],
      //     ),
      //   ),
      //   Card(
      //     child: Column(
      //       children: [
      //         Text('Note 1'),
      //         Text('Content of note 1'),
      //         IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
      //       ],
      //     ),
      //   ),
      // ],
    );
  }
}
