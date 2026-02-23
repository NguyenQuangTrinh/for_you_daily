// lib/features/cycle/presentation/widgets/cycle_chart_card.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/cycle_record.dart';

class CycleChartCard extends StatelessWidget {
  final List<CycleRecord> chartData;

  const CycleChartCard({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    if (chartData.length < 2) {
      return Card(
        elevation: 2,
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Biến động Độ dài Chu kỳ', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              const Center(child: Text('Cần ít nhất 2 chu kỳ hoàn chỉnh để vẽ biểu đồ.', style: TextStyle(color: Colors.grey))),
            ],
          ),
        ),
      );
    }

    double minY = chartData.map((d) => d.cycleLength!.toDouble()).reduce((a, b) => a < b ? a : b) - 5;
    if (minY < 0) minY = 0;
    double maxY = chartData.map((d) => d.cycleLength!.toDouble()).reduce((a, b) => a > b ? a : b) + 5;

    return Card(
      elevation: 2,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Biến động Độ dài Chu kỳ (6 kỳ gần nhất)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  minY: minY,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final record = chartData[group.x.toInt()];
                        return BarTooltipItem(
                          '${record.cycleLength} ngày\n',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          children: <TextSpan>[
                            TextSpan(
                              text: DateFormat('MM/yyyy', 'vi_VN').format(record.startDate),
                              style: const TextStyle(color: Colors.yellow, fontSize: 12),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < chartData.length) {
                            final record = chartData[index];
                            return SideTitleWidget(
                              // fitInside: meta.axisSide,
                              space: 4,
                              meta: meta,
                              child: Text(DateFormat('MM/yy').format(record.startDate), style: const TextStyle(fontSize: 10)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value == meta.min || value == meta.max || value % 5 == 0) {
                            return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
                  ),
                  barGroups: List.generate(chartData.length, (index) {
                    final record = chartData[index];
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: record.cycleLength!.toDouble(),
                          color: Theme.of(context).primaryColor,
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}