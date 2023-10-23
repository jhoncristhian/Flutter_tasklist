import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/controller/task_controller.dart';
import 'package:task/main.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditPage extends StatefulWidget {
  late int position;
  late List<Task> tasks;
  EditPage({required this.position, required this.tasks});
  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late SharedPreferences _prefs;
  TextEditingController _textController = TextEditingController();
  int tamanoActual = 0;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
    _textController.text = widget.tasks[widget.position].text;
    tamanoActual = _textController.text.length;
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    //await _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      widget.tasks = (_prefs.getStringList('tasks') ?? []).map((task) {
        final parts = task.split('|');
        return Task(text: parts[0], completed: parts[1] == 'true');
      }).toList();
    });
  }

  void handleEditTask(BuildContext context, int index, String editedText) {
    setState(() {
      widget.tasks[index].text = editedText;
      _saveTasks();
    });
    Navigator.of(context).pop(); // Cierra el cuadro de diálogo de edición
  }

  Future<void> _saveTasks() async {
    final taskStrings =
        widget.tasks.map((task) => '${task.text}|${task.completed}').toList();
    await _prefs.setStringList('tasks', taskStrings);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _showToast() {
    Fluttertoast.showToast(
      msg: "without changes",
      toastLength: Toast
          .LENGTH_SHORT, // Puedes usar Toast.LENGTH_SHORT o Toast.LENGTH_LONG
      gravity: ToastGravity.BOTTOM, // Cambia la posición del toast
      timeInSecForIosWeb: 1, // Duración en segundos (solo para iOS y web)
      backgroundColor: Colors.grey, // Color de fondo del toast
      textColor: Colors.white, // Color del texto del toast
      fontSize: 16.0, // Tamaño de fuente del texto
    );
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
            title: Text('Edit Note'),
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                if (_textController.text.length > 0) {
                  if (_textController.text.length != tamanoActual) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirm cancel'),
                          content: Text(
                              'Are you sure you want to cancel this task?'),
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
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  // Aquí guardar el texto.
                  //print((MediaQuery.of(context).size.height / 20).round());
                  if (_textController.text.length > 0) {
                    if (_textController.text.length != tamanoActual) {
                      //handleAddTask();
                      handleEditTask(
                        context,
                        widget.position,
                        _textController.text,
                      );
                      _textController.clear();

                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => TaskListApp()),
                      );
                    } else {
                      _showToast();
                      print('si no hay cambios');
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
