import 'package:flutter/material.dart';
import 'package:s14_shared_preference/model/task.dart';
import 'package:s14_shared_preference/services/preferences_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PreferencesService _preferencesService = PreferencesService();
  final TextEditingController addController = TextEditingController();

  List<Task> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    addController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final loadedTasks = await _preferencesService.loadTasks();

    setState(() {
      tasks = loadedTasks;
      isLoading = false;
    });
  }

  Future<void> saveTasks() async {
    await _preferencesService.saveTasks(tasks);
  }

  void _addTask() {
    final title = addController.text.trim();
    if (title.isEmpty) return;

    final newTask = Task(id: DateTime.now().toString(), title: title);

    setState(() {
      tasks.add(newTask);
      addController.clear();
    });

    saveTasks();
  }

  void _toggleDone(Task task) {
    setState(() {
      task.isDone = !task.isDone;
    });

    saveTasks();
  }

  void _deleteTask(Task task) {
    setState(() {
      tasks.removeWhere((t) => t.id == task.id);
    });

    saveTasks();
  }

  Future<void> _clearAllDialog() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear All Tasks"),
        content: const Text("Are you sure you want to clear all tasks?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Clear All"),
          ),
        ],
      ),
    );

    if (ok == true) {
      setState(() {
        tasks.clear();
      });
      await _preferencesService.clearTasks();
    }
  }

  Future<void> _updateTaskDialog(Task task) async {
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: task.title);
        return AlertDialog(
          title: const Text("Update Task"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter new title"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text("Update"),
            ),
          ],
        );
      },
    );

    if (newTitle != null && newTitle.isNotEmpty) {
      setState(() {
        task.title = newTitle;
      });
      saveTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _clearAllDialog,
            tooltip: 'Clear All Tasks',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: addController,
                          decoration: const InputDecoration(
                            hintText: 'Add a task',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          _addTask();
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 0),
                Expanded(
                  child: tasks.isEmpty
                      ? const Center(child: Text('No tasks'))
                      : ListView.separated(
                          separatorBuilder: (context, index) =>
                              const Divider(height: 0),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return ListTile(
                              leading: Checkbox(
                                value: task.isDone,
                                onChanged: (checked) {
                                  _toggleDone(task);
                                },
                              ),
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  decoration: task.isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              onTap: () {
                                _updateTaskDialog(task);
                              },
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _deleteTask(task);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
