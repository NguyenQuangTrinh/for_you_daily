// lib/features/home/presentation/widgets/tasks_card.dart
import 'package:flutter/material.dart';
import 'package:for_you_daily/features/tasks/presentation/screens/tasks_screen.dart';

class TasksCard extends StatelessWidget {
  // Thêm tham số để nhận số lượng công việc
  final int taskCount;

  const TasksCard({
    super.key,
    required this.taskCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Công việc hôm nay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // Hiển thị số lượng công việc thật
            Text(
              taskCount > 0
                  ? 'Bạn có $taskCount công việc cần làm.'
                  : 'Bạn không có công việc nào hôm nay. Tuyệt vời!',
              style: TextStyle(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TasksScreen()),
                  );
                },
                child: const Text('Xem tất cả công việc'),
              ),
            )
          ],
        ),
      ),
    );
  }
}