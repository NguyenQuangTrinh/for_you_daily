// lib/features/tasks/presentation/widgets/task_expansion_tile.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../domain/task.dart';
import '../providers/task_provider.dart';
import '../screens/task_detail_screen.dart';

class TaskExpansionTile extends StatelessWidget {
  final Task task;
  final int nestingLevel;

  const TaskExpansionTile({
    super.key,
    required this.task,
    this.nestingLevel = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Chỉ các công việc gốc (cấp 0) mới có kiểu Card nổi bật
    if (nestingLevel == 0) {
      return _buildRootTaskCard(context);
    } else {
      // Các công việc con sẽ có giao diện đơn giản hơn để phân cấp
      return _buildSubtaskTile(context);
    }
  }

  // --- Widget cho CÔNG VIỆC GỐC (có Card và Shadow) ---
  Widget _buildRootTaskCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4, // Tăng độ nổi để có bóng rõ hơn
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Giúp bo tròn các widget con bên trong
      child: _buildExpansionTileContent(context),
    );
  }

  // --- Widget cho CÔNG VIỆC CON (giao diện lồng vào trong) ---
  Widget _buildSubtaskTile(BuildContext context) {
    // Thụt lề cho các cấp con
    final double leftPadding = 16.0 * nestingLevel;

    return Container(
      padding: EdgeInsets.only(left: leftPadding),
      child: _buildExpansionTileContent(context),
    );
  }

  // --- Nội dung chung của ExpansionTile ---
  Widget _buildExpansionTileContent(BuildContext context) {
    final taskProvider = context.read<TaskProvider>();

    String? formatTaskDates() {
      if (task.startDate == null && task.endDate == null) return null;
      final dateFormat = DateFormat('dd/MM/yy');
      final startDateString = task.startDate != null ? dateFormat.format(task.startDate!) : '...';
      final endDateString = task.endDate != null ? dateFormat.format(task.endDate!) : '...';
      return '$startDateString - $endDateString';
    }

    return ExpansionTile(
      key: PageStorageKey(task.id),
      // Tắt màu nền mặc định để màu của Card được hiển thị
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      title: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: task.priorityColor,
              borderRadius: BorderRadius.circular(4), // Bo tròn vạch màu
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                    color: task.isDone ? Colors.grey : null,
                  ),
                ),
                if (formatTaskDates() != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    formatTaskDates()!,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Xem chi tiết',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
              );
            },
          ),
          Checkbox(
            value: task.isDone,
            onChanged: (value) {
              taskProvider.toggleTaskStatus(task.id, task.isDone);
            },
          ),
        ],
      ),
      children: [
        _SubtaskList(parentId: task.id, nestingLevel: nestingLevel + 1),
      ],
    );
  }
}
// Widget con này dùng StreamBuilder để tải và hiển thị danh sách công việc con
class _SubtaskList extends StatelessWidget {
  final String parentId;
  final int nestingLevel;

  const _SubtaskList({required this.parentId, required this.nestingLevel});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.read<TaskProvider>();
    return StreamBuilder<List<Task>>(
      stream: taskProvider.getSubtasksStream(parentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: EdgeInsets.only(left: 16.0 * (nestingLevel + 1), top: 8, bottom: 8),
            alignment: Alignment.centerLeft,
            child: Text('Chưa có công việc con', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
          );
        }

        final subtasks = snapshot.data!;
        return Column(
          children: subtasks.map((subtask) {
            // Đệ quy: Mỗi subtask cũng là một ExpansionTile
            return TaskExpansionTile(task: subtask, nestingLevel: nestingLevel);
          }).toList(),
        );
      },
    );
  }
}