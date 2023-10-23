import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/controller/task_controller.dart';
import 'package:task/main.dart';

class AddPage extends StatefulWidget {
  late List<Task> tasks;
  AddPage({required this.tasks});
  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  late SharedPreferences _prefs;
  TextEditingController _textController = TextEditingController();
  int tamanoActual = 0;
  String newTask = '';
  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      widget.tasks = (_prefs.getStringList('tasks') ?? []).map((task) {
        final parts = task.split('|');
        return Task(text: parts[0], completed: parts[1] == 'true');
      }).toList();
    });
  }

  void handleAddTask() {
    if (newTask.trim().isNotEmpty) {
      setState(() {
        widget.tasks.add(Task(text: newTask));
        _textController.clear();
        newTask = '';
        _saveTasks();
      });
    }
  }

  Future<void> _saveTasks() async {
    final taskStrings =
        widget.tasks.map((task) => '${task.text}|${task.completed}').toList();
    await _prefs.setStringList('tasks', taskStrings);
  }

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
    tamanoActual = _textController.text.length;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: Color.fromARGB(255, 59, 57, 57),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
          ),
          inputDecorationTheme: InputDecorationTheme(
            hintStyle: TextStyle(color: Colors.white),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text('Add Note'),
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                if (_textController.text.length != tamanoActual) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirm cancel'),
                        content:
                            Text('Are you sure you want to cancel this task?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: Text('Accept'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  // Aquí guardar el texto.
                  //print((MediaQuery.of(context).size.height / 20).round());
                  if (_textController.text.length > 0) {
                    if (_textController.text.length != tamanoActual) {
                      handleAddTask();

                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => TaskListApp()),
                      );
                    }
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Error'),
                          content: Text('Empty field'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Accept'),
                            )
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  newTask = value;
                });
              },
              controller: _textController,
              maxLines: null,
              minLines: (deviceHeight / 20).round(),
              enabled: true,
              decoration: InputDecoration(
                hintText: 'Write here...',
                filled: true,
                fillColor: Color.fromARGB(255, 73, 70, 70),
                hintStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ));
  }
}
