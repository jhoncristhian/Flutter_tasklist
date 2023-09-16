class Task {
  int id; // ID de la tarea
  String text; // Texto de la tarea
  bool completed; // Estado de completitud de la tarea

  Task({required this.id, required this.text, this.completed = false});

  // Convierte un objeto Task a un mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'completed': completed ? 1 : 0,
    };
  }

  // Convierte un mapa a un objeto Task
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      text: map['text'],
      completed: map['completed'] == 1,
    );
  }
}
