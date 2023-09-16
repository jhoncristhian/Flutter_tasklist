import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Task {
  String text;
  bool completed;

  Task({required this.text, this.completed = false});
}

class TaskListStyles {
  static TextStyle completedTaskTextStyle = TextStyle(
    color: Color.fromARGB(255, 224, 228, 5),
    decoration: TextDecoration.lineThrough,
  );
}

void main() {
  runApp(TaskListApp());
}

class TaskListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task list',
      home: TaskListScreen(),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late SharedPreferences _prefs;
  List<Task> tasks = [];
  String newTask = ''; // Variable para almacenar la nueva tarea
  TextEditingController newTaskController = TextEditingController();
  TextEditingController editTaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      tasks = (_prefs.getStringList('tasks') ?? []).map((task) {
        final parts = task.split('|');
        return Task(text: parts[0], completed: parts[1] == 'true');
      }).toList();
    });
  }

  Future<void> _saveTasks() async {
    final taskStrings =
        tasks.map((task) => '${task.text}|${task.completed}').toList();
    await _prefs.setStringList('tasks', taskStrings);
  }

  void handleToggleCompletion(BuildContext context, Task task) {
    setState(() {
      task.completed = !task.completed;
      _saveTasks();
    });
  }

  void handleEditTask(BuildContext context, int index, String editedText) {
    setState(() {
      tasks[index].text = editedText;
      _saveTasks();
    });
    Navigator.of(context).pop(); // Cierra el cuadro de diálogo de edición
  }

  void handleDeleteTask(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm deletion'),
          content: Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  tasks.remove(task);
                  _saveTasks();
                });
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: Text('Accept'),
            ),
          ],
        );
      },
    );
  }

  void handleAddTask() {
    if (newTask.trim().isNotEmpty) {
      setState(() {
        tasks.add(Task(text: newTask));
        newTaskController
            .clear(); // Limpia el controlador después de agregar la tarea
        newTask = ''; // Limpia la variable después de agregar la tarea
        _saveTasks();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Task list'),
        ),
        body: Container(
          color: Color.fromARGB(
              255, 59, 57, 57), // Fondo gris para toda la pantalla
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            newTask = value;
                          });
                        },
                        controller: newTaskController,
                        style: TextStyle(
                          color: Colors
                              .white, // Cambia el color del texto que escribes a blanco
                        ),
                        decoration: InputDecoration(
                          labelText: 'New task',
                          labelStyle: TextStyle(
                            color: Colors
                                .white, // Cambiar el color del texto "New task" a blanco
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        handleAddTask();
                      },
                      child: Text('Add'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: Color.fromARGB(
                            255, 73, 70, 70), // Fondo blanco para cada tarea
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: tasks[index].completed,
                          onChanged: (value) =>
                              handleToggleCompletion(context, tasks[index]),
                          fillColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return Color.fromARGB(220, 3, 170,
                                    25); // Color cuando está marcado
                              }
                              return Colors
                                  .white; // Color cuando no está marcado
                            },
                          ),
                        ),
                        title: tasks[index].completed
                            ? Text(
                                '${index + 1}. ${tasks[index].text}',
                                style: TaskListStyles.completedTaskTextStyle,
                                maxLines: 1,
                              )
                            : GestureDetector(
                                onTap: () {
                                  editTaskController.text = tasks[index].text;
                                },
                                child: Container(
                                  child: Text(
                                    '${index + 1}. ${tasks[index].text}',
                                    style: TextStyle(
                                      color: Colors
                                          .white, // Cambia el color del texto a blanco
                                      fontSize: 16, // Tamaño de fuente
                                    ),
                                    overflow: TextOverflow.clip,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                editTaskController.text = tasks[index].text;

                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Edit task'),
                                      content: SingleChildScrollView(
                                        child: TextField(
                                          controller: editTaskController,
                                          maxLines:
                                              null, // Permite múltiples líneas
                                          decoration: InputDecoration(
                                            hintText: tasks[index].text,
                                          ),
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            handleEditTask(
                                              context,
                                              index,
                                              editTaskController.text,
                                            );
                                            editTaskController.clear();
                                          },
                                          child: Text('Save'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                handleDeleteTask(context, tasks[index]);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
