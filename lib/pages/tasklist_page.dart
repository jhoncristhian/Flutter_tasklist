import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:task/controller/task_controller.dart';
import 'package:task/pages/add_task_page.dart';
import 'package:task/pages/edit_task_page.dart';

class TaskListStyles {
  static TextStyle completedTaskTextStyle = TextStyle(
    color: Color.fromARGB(255, 224, 228, 5),
    decoration: TextDecoration.lineThrough,
  );
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text('Task list'),
            ),
            body: Container(
              color: Color.fromARGB(
                  255, 59, 57, 57), // Fondo gris para toda la pantalla
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            color: Color.fromARGB(255, 73, 70,
                                70), // Fondo blanco para cada tarea
                          ),
                          child: ListTile(
                            leading: Checkbox(
                              value: tasks[index].completed,
                              onChanged: (value) =>
                                  handleToggleCompletion(context, tasks[index]),
                              fillColor:
                                  MaterialStateProperty.resolveWith<Color?>(
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
                                    '${tasks[index].text}',
                                    //'${index + 1}. ${tasks[index].text}',
                                    style:
                                        TaskListStyles.completedTaskTextStyle,
                                    maxLines: 1,
                                  )
                                : GestureDetector(
                                    onDoubleTap: () {
                                      //editTaskController.text = tasks[index].text;
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => EditPage(
                                                  tasks: tasks,
                                                  position: index,
                                                )),
                                      );
                                      print('editaaando');
                                    },
                                    child: Container(
                                      child: Text(
                                        '${tasks[index].text}',
                                        //'${index + 1}. ${tasks[index].text}',
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
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => EditPage(
                                                tasks: tasks,
                                                position: index,
                                              )),
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Centra los elementos horizontalmente
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            margin: EdgeInsets.only(
                                right:
                                    40), // Agrega espacio de 20 píxeles entre los iconos
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AddPage(
                                      tasks: [],
                                    ),
                                  ),
                                );
                              },
                              child: Center(
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Menu'),
                                      content: Text(
                                          'Developed by Daddy Jhon'), //22/10/23 10:56pm
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
                              },
                              child: Center(
                                child: Icon(
                                  Icons.menu,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )));
  }
}
