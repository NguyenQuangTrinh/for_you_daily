// lib/features/cycle/presentation/widgets/detailed_cycle_info_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/cycle_provider.dart';

class DetailedCycleInfoCard extends StatelessWidget {
  final CycleProvider provider;

  const DetailedCycleInfoCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thông tin chu kỳ', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _InfoRow(title: 'Trạng thái hiện tại:', value: provider.currentCycleStatus),
            const Divider(height: 24),
            _InfoRow(title: 'Chu kỳ trung bình:', value: provider.averageCycleLength),
            _InfoRow(title: 'Kỳ kinh trung bình:', value: provider.averagePeriodLength),
            const Divider(height: 24),
            _InfoRow(
                title: 'Dự đoán kỳ tới:',
                value: provider.predictedNextPeriodStart != null
                    ? DateFormat('dd/MM/yyyy').format(provider.predictedNextPeriodStart!)
                    : '...'),
            _InfoRow(
                title: 'Dự đoán rụng trứng:',
                value: provider.predictedOvulationDate != null
                    ? DateFormat('dd/MM/yyyy').format(provider.predictedOvulationDate!)
                    : '...'),
            _InfoRow(
                title: 'Cửa sổ thụ thai:',
                value: provider.fertileWindowStart != null && provider.fertileWindowEnd != null
                    ? '${DateFormat('dd/MM').format(provider.fertileWindowStart!)} - ${DateFormat('dd/MM/yyyy').format(provider.fertileWindowEnd!)}'
                    : '...'),
          ],
        ),
      ),
    );
  }
}

// Widget con chỉ dùng trong file này
class _InfoRow extends StatelessWidget {
  final String title;
  final String value;
  const _InfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start, // Căn các dòng trên cùng
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade500)),
          const SizedBox(width: 16), // Thêm một chút khoảng cách

          // Bọc Text giá trị trong Expanded
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end, // Căn phải cho text
            ),
          ),
        ],
      ),
    );
  }
}