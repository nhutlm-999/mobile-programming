import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vinhvt9_sqlite/models/note.dart';

part 'note_notifier.g.dart';

@riverpod
class NoteNotifier extends _$NoteNotifier {
  // Khai báo 1 key để lưu data vào shared preferences
  static const String _noteKey = 'notes';

  // Quy trình khởi tạo app (init noteProvider -> gọi build() để init state ban đầu)
  // Đọc vào SharedPreferences -> JSON (StringList) thành List<Note> -> return về build
  @override
  List<Note> build() {
    return _loadNotes();
  }

  List<Note> _loadNotes() {
    // Implementation for loading notes from SharedPreferences
    return [];
  }
}
