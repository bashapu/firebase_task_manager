

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/model/task_model.dart';
import 'package:task_manager/screens/profile_screen.dart';
import 'signin_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskController = TextEditingController();
  TaskPriority _selectedPriority = TaskPriority.medium;

  Stream<List<Task>> getTasks() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .orderBy('priority', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addTask() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    if (_taskController.text.isEmpty) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).collection('tasks').add({
      'name': _taskController.text,
      'isCompleted': false,
      'priority': _selectedPriority.index,
      'dueDate': DateTime.now().toIso8601String(),
    });
    _taskController.clear();
    setState(() => _selectedPriority = TaskPriority.medium);
  }

  Future<void> toggleCompletion(Task task) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(task.id)
        .update({'isCompleted': !task.isCompleted});
  }

  Future<void> deleteTask(Task task) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(task.id)
        .delete();
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignInScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Manager"),
        actions: [IconButton(onPressed: logout, icon: const Icon(Icons.logout))],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(hintText: 'Enter a task'),
                  ),
                ),
                DropdownButton<TaskPriority>(
                  value: _selectedPriority,
                  onChanged: (value) => setState(() => _selectedPriority = value!),
                  items: TaskPriority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(priority.name),
                    );
                  }).toList(),
                ),
                ElevatedButton(onPressed: addTask, child: const Icon(Icons.add)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: getTasks(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final tasks = snapshot.data!;
                if (tasks.isEmpty) {
                  return const Center(child: Text("No tasks yet."));
                }
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (_) => toggleCompletion(task),
                        ),
                        title: Text(
                          task.name,
                          style: TextStyle(
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: task.isCompleted ? Colors.grey : Colors.black,
                          ),
                        ),
                        subtitle: Text("Priority: ${task.priority.name}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteTask(task),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
            label: Text('Profile Page'),
            icon: Icon(Icons.navigate_next), // Optional icon
          )
        ],
      ),
    );
  }
}