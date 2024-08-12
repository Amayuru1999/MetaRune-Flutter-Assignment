import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: TextTheme(
          headline5: TextStyle(color: Colors.deepPurple.shade700),
          subtitle1: TextStyle(color: Colors.deepPurple.shade600),
        ),
      ),
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<String> _tasks = [];
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tasks = prefs.getStringList('tasks') ?? [];
    });
  }

  _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('tasks', _tasks);
  }

  _addTask(String task) {
    setState(() {
      _tasks.add(task);
      _saveTasks();
    });
  }

  _editTask(int index, String newTask) {
    setState(() {
      _tasks[index] = newTask;
      _saveTasks();
    });
  }

  _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
      _saveTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                labelText: 'Enter task',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                prefixIcon: const Icon(Icons.add_task),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                final task = _taskController.text;
                if (task.isNotEmpty) {
                  _addTask(task);
                  _taskController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple, // Background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text('Add Task'),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text(
                        _tasks[index],
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTask(index),
                      ),
                      onTap: () async {
                        final newTask = await showDialog<String>(
                          context: context,
                          builder: (context) =>
                              EditTaskDialog(task: _tasks[index]),
                        );
                        if (newTask != null && newTask.isNotEmpty) {
                          _editTask(index, newTask);
                        }
                      },
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

class EditTaskDialog extends StatefulWidget {
  final String task;
  const EditTaskDialog({super.key, required this.task});

  @override
  // ignore: library_private_types_in_public_api
  _EditTaskDialogState createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _editController.text = widget.task;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Task'),
      content: TextField(
        controller: _editController,
        decoration: const InputDecoration(
          labelText: 'Task',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_editController.text);
          },
          child: const Text('Save'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
