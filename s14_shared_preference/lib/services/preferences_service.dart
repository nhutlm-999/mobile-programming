import 'dart:convert';

import 'package:s14_shared_preference/model/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String key = 'task_lists';

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final taskJsonList = tasks.map((task) => task.toJson()).toList();
    await prefs.setString(key, jsonEncode(taskJsonList));
  }

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskJsonString = prefs.getString(key);

    if (taskJsonString == null) return [];

    final taskJsonList = jsonDecode(taskJsonString) as List<dynamic>;
    return taskJsonList
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
