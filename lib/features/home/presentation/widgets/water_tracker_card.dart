import 'package:flutter/material.dart';
import '../../../../app/config/constants/app_colors.dart';

class WaterTrackerCard extends StatelessWidget {
  const WaterTrackerCard({super.key, required this.waterDrunk, required this.dailyGoal, required this.onAddWater});

  final int waterDrunk;
  final int dailyGoal;
  final VoidCallback onAddWater;

  @override
  Widget build(BuildContext context) {
    final double progress = (dailyGoal > 0) ? (waterDrunk / dailyGoal) : 0.0;
    final String percentage = (progress * 100).toStringAsFixed(0);

    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Theo dõi nước uống', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // Hiển thị dữ liệu thật được truyền vào
            Text('Hôm nay: $waterDrunk / $dailyGoal ml'),
            const SizedBox(height: 16),
            // Progress bar
            LayoutBuilder(
              builder: (context, constraints) {
                final double progressBarWidth = constraints.maxWidth;

                return Stack(
                  clipBehavior: Clip.none, // Cho phép nhãn hiển thị bên ngoài Stack
                  children: [
                    // Thanh background
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    // Thanh tiến trình
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      width: progressBarWidth * progress.clamp(0.0, 1.0),
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    // Nhãn % di động
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      left: (progressBarWidth * progress.clamp(0.0, 1.0)) - 15, // Dịch trái 1 chút để căn giữa
                      top: -22, // Đặt nhãn phía trên thanh progress
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: progress > 0.05 ? 1.0 : 0.0, // Chỉ hiện khi > 5%
                        child: Text(
                          '$percentage%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Thêm 250 ml'),
                // Gọi hàm được truyền từ cha
                onPressed: onAddWater,
              ),
            ),
          ],
        ),
      ),
    );
  }
}