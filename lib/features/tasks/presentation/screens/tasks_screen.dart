// lib/features/tasks/presentation/screens/tasks_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_expansion_tile.dart';
import 'add_edit_task_screen.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Công việc'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Task>>(
        stream: taskProvider.rootTasksStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Chưa có công việc nào.'));
          }

          final allTasks = snapshot.data!;
          final rootTasks = allTasks.where((task) => task.parentId == null).toList();
          return ListView.builder(
            itemCount: rootTasks.length,
            itemBuilder: (context, index) {
              final task = rootTasks[index];
              // Sử dụng widget TaskExpansionTile đã được tách ra
              return TaskExpansionTile(task: task, nestingLevel: 0);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditTaskScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

}

