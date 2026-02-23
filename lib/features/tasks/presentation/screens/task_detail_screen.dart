
// lib/features/tasks/presentation/screens/task_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../domain/task.dart';
import '../providers/task_provider.dart';
import 'add_edit_task_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    // Helper để định dạng ngày tháng
    String formatTaskDates(DateTime? start, DateTime? end) {
      if (start == null && end == null) return 'Chưa có';
      final dateFormat = DateFormat('dd/MM/yyyy');
      final startDateString = start != null ? dateFormat.format(start) : '...';
      final endDateString = end != null ? dateFormat.format(end) : '...';
      return '$startDateString - $endDateString';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết công việc"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Chỉnh sửa',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddEditTaskScreen(existingTask: task)),
              );
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- PHẦN HIỂN THỊ THÔNG TIN CHI TIẾT ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _DetailItem(
                  icon: Icons.flag_outlined,
                  title: 'Độ ưu tiên',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: task.priorityColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(task.priority.name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                _DetailItem(
                  icon: Icons.calendar_today_outlined,
                  title: 'Thời gian',
                  child: Text(formatTaskDates(task.startDate, task.endDate)),
                ),
                const SizedBox(height: 12),
                _DetailItem(
                  icon: Icons.description_outlined,
                  title: 'Mô tả',
                  child: Text(
                    task.description != null && task.description!.isNotEmpty
                        ? task.description!
                        : 'Chưa có mô tả.',
                    style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // --- PHẦN DANH SÁCH CÔNG VIỆC CON ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Text('Công việc con', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: taskProvider.getSubtasksStream(task.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Chưa có công việc con nào.'));
                }
                final subtasks = snapshot.data!;
                return ListView.builder(
                  itemCount: subtasks.length,
                  itemBuilder: (context, index) {
                    final subtask = subtasks[index];
                    // Dùng ListTile đơn giản cho công việc con
                    return ListTile(
                      title: Text(
                        subtask.title,
                        style: TextStyle(
                          decoration: subtask.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                      ),
                      leading: Checkbox(
                        value: subtask.isDone,
                        onChanged: (value) {
                          taskProvider.toggleTaskStatus(subtask.id, subtask.isDone);
                        },
                      ),
                      // Cho phép đi sâu vào các cấp con hơn nữa
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => TaskDetailScreen(task: subtask),
                      )),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEditTaskScreen(parentId: task.id)),
          );
        },
        tooltip: 'Thêm công việc con',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Widget con để hiển thị một dòng chi tiết cho gọn
class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _DetailItem({required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey.shade500, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey.shade500)),
              const SizedBox(height: 4),
              child,
            ],
          ),
        ),
      ],
    );
  }
}