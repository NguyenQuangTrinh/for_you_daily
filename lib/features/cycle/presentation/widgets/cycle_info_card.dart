// lib/features/home/presentation/widgets/cycle_info_card.dart
import 'package:flutter/material.dart';
import 'package:for_you_daily/features/cycle/presentation/screens/cycle_tracker_screen.dart';

class CycleInfoCard extends StatelessWidget {
  // Thêm tham số status
  final String status;
  final VoidCallback onMarkCycle;

  const CycleInfoCard({
    super.key,
    required this.status, required this.onMarkCycle, // Bắt buộc phải có
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
            const Text('Thông tin chu kỳ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textDirection: TextDirection.ltr),
            const SizedBox(height: 8),
            // Hiển thị status được truyền vào
            Text(status, style: TextStyle(color: Colors.grey.shade400),),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: onMarkCycle, child: const Text('Đánh dấu kỳ kinh')),
                TextButton(onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CycleScreen()),
                  );
                }, child: const Text('Xem lịch')),
              ],
            )
          ],
        ),
      ),
    );
  }
}