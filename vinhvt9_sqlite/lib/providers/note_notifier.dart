import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vinhvt9_sqlite/db/database_helper.dart';
import 'package:vinhvt9_sqlite/models/note.dart';

part 'note_notifier.g.dart';

@riverpod
class NoteNotifier extends _$NoteNotifier {
  // Quy trình khởi tạo app (init noteProvider -> gọi build() để init state ban đầu)
  // Đọc vào SharedPreferences -> JSON (StringList) thành List<Note> -> return về build
  @override
  Future<List<Note>> build() async {
    return DatabaseHelper.instance.getNotes();
  }
  // Future<void> updateNote(Note note) async {
  //   await DatabaseHelper.instance.updateNote(note);
  //   state = [...state.where((n) => n.id != note.id), note];
  // }

  Future<void> addNote(Note note) async {
    await DatabaseHelper.instance.insertNote(note);
    // state = [...state, note];
    ref.invalidateSelf(); // Báo hiệu build() cần chạy lại
    await future;
  }
}
