import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Map<String, dynamic>> _tasks = [];  // Liste des tâches
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();  // Charger les tâches enregistrées
  }

  // Charger les tâches depuis SharedPreferences
  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksString = prefs.getString('tasks');  // Récupérer la liste des tâches en JSON

    if (tasksString != null && tasksString.isNotEmpty) {
      // Convertir le JSON en liste de cartes (Map)
      List<dynamic> tasksList = jsonDecode(tasksString);
      setState(() {
        _tasks = tasksList.map((task) => Map<String, dynamic>.from(task)).toList();
      });
    } else {
      setState(() {
        _tasks = [];  // Si aucune tâche n'est enregistrée, on commence avec une liste vide
      });
    }
  }

  // Enregistrer les tâches dans SharedPreferences
  Future<void> _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tasksString = jsonEncode(_tasks);  // Convertir la liste des tâches en JSON
    await prefs.setString('tasks', tasksString);  // Sauvegarder les tâches sous forme de chaîne JSON
  }

  // Ajouter une nouvelle tâche
  Future<void> _addTask() async {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _tasks.add({
          'task': _controller.text, // Description de la tâche
          'isDone': false, // Par défaut, la tâche est non terminée
        });
        _controller.clear(); // Effacer le champ de saisie
      });
      await _saveTasks();  // Sauvegarder les tâches après l'ajout
    }
  }

  // Basculer l'état de "isDone" pour une tâche
  Future<void> _toggleTask(int index) async {
    setState(() {
      _tasks[index]['isDone'] = !_tasks[index]['isDone'];
    });
    await _saveTasks();  // Sauvegarder les tâches après modification
  }

  // Supprimer une tâche
  Future<void> _deleteTask(int index) async {
    setState(() {
      _tasks.removeAt(index); // Supprimer la tâche
    });
    await _saveTasks();  // Sauvegarder les tâches après suppression
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BACKGROUND MAIN COLOR
      backgroundColor: Color(0xFFAAADC4),

      // APPBAR OPTIONS
      appBar: AppBar(
        title: Text(
          'MY TASKS',
          style: TextStyle(
            fontSize: 30,
            fontFamily: "LexendExa",
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, offset: Offset(0, 2), blurRadius: 10)],
          ),
        ),
        backgroundColor: Color(0xFFAAADC4),
        centerTitle: true,
      ),

      // BODY OPTIONS
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Champ de saisie et bouton pour ajouter une tâche
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Nom de la nouvelle tâche',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(color: Color(0xFF3E442B)),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD6EEFF),
                  ),
                  child: Text(
                    'Ajouter',
                    style: TextStyle(color: Colors.black, fontFamily: "LexendExa"),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Afficher la liste des tâches
            Expanded(
              child: _tasks.isEmpty
                  ? Center(
                child: Text(
                  'C\'est bien vide ici...',
                  style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: "LexendExa"),
                ),
              )
                  : ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Card(
                    color: Color(0xFFD6EEFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: Checkbox(
                        value: task['isDone'],
                        onChanged: (value) => _toggleTask(index),
                        activeColor: Colors.teal,
                      ),
                      title: Text(
                        task['task'],
                        style: TextStyle(
                          fontFamily: "LexendExa",
                          decoration: task['isDone'] ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTask(index),
                      ),
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
