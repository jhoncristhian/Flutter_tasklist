import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Task {
  String text;
  bool completed;

  Task({required this.text, this.completed = false});
}

// class TaskController {
//   late SharedPreferences _prefs;

//   TaskController() {
//     _initSharedPreferences();
//   }

//   Future<void> _initSharedPreferences() async {
//     _prefs = await SharedPreferences.getInstance();
//   }

//   Future<List<Task>> loadTasks() async {
//     final taskStrings = _prefs.getStringList('tasks') ?? [];
//     return taskStrings.map((task) {
//       final parts = task.split('|');
//       return Task(text: parts[0], completed: parts[1] == 'true');
//     }).toList();
//   }

//   Future<void> saveTasks(List<Task> tasks) async {
//     final taskStrings =
//         tasks.map((task) => '${task.text}|${task.completed}').toList();
//     await _prefs.setStringList('tasks', taskStrings);
//   }

//   void toggleCompletion(Task task) {
//     task.completed = !task.completed;
//   }

//   void editTask(List<Task> tasks, int index, String editedText) {
//     tasks[index].text = editedText;
//   }

//   Future<void> deleteTask(
//       List<Task> tasks, BuildContext context, Task task) async {
//     await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Confirm deletion'),
//           content: Text('Are you sure you want to delete this task?'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Cierra el diálogo
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 tasks.remove(task);
//                 saveTasks(tasks);
//                 Navigator.of(context).pop(); // Cierra el diálogo
//               },
//               child: Text('Accept'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void addTask(TextEditingController newTaskController, List<Task> tasks,
//       String newTask) {
//     if (newTask.trim().isNotEmpty) {
//       tasks.add(Task(text: newTask));
//       newTaskController
//           .clear(); // Limpia el controlador después de agregar la tarea
//       newTask = ''; // Limpia la variable después de agregar la tarea
//       saveTasks(tasks);
//     }
//   }
// }
