import 'package:flutter/material.dart';
import 'package:task/pages/tasklist_page.dart';

void main() {
  runApp(TaskListApp());
}

class TaskListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task list',
      home: TaskListScreen(),
    );
  }
}
