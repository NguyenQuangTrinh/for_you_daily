// lib/features/cycle/presentation/screens/cycle_screen.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../providers/cycle_provider.dart';
import '../widgets/cycle_chart_card.dart';
import '../widgets/detailed_cycle_info_card.dart';


class CycleScreen extends StatefulWidget {
  const CycleScreen({super.key});

  @override
  State<CycleScreen> createState() => _CycleScreenState();
}

class _CycleScreenState extends State<CycleScreen> {
  // Các biến cục bộ quản lý trạng thái của UI
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  late TextEditingController _notesController;

  // Các Set để tối ưu việc render lịch
  final Set<DateTime> _periodDays = {};
  final Set<DateTime> _fertileDays = {};
  DateTime? _ovulationDay;
  DateTime? _predictedNextPeriodStart;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();

    // Tải log cho ngày được chọn ban đầu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CycleProvider>().fetchDailyLog(_selectedDay);
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // Hàm helper để chuẩn hóa ngày (loại bỏ thông tin giờ/phút/giây)
  DateTime _dateOnly(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  // Cập nhật các Set dữ liệu từ Provider để vẽ lịch
  void _updateLocalSets(CycleProvider provider) {
    _predictedNextPeriodStart = provider.predictedNextPeriodStart;
    _periodDays.clear();
    _fertileDays.clear();
    _ovulationDay = null;
    final today = _dateOnly(DateTime.now());
    for (final record in provider.cycleRecords) {
      DateTime start = _dateOnly(record.startDate);
      // Mặc định endDate là startDate nếu nó null (cho kỳ kinh đang diễn ra)
      DateTime end = record.endDate != null ? _dateOnly(record.endDate!) : today;

      for (var day = start; !day.isAfter(end); day = day.add(const Duration(days: 1))) {
        _periodDays.add(day);
      }
    }

    if (provider.fertileWindowStart != null && provider.fertileWindowEnd != null) {
      for (var day = provider.fertileWindowStart!; !day.isAfter(provider.fertileWindowEnd!); day = day.add(const Duration(days: 1))) {
        _fertileDays.add(_dateOnly(day));
      }
    }
    if (provider.predictedOvulationDate != null) {
      _ovulationDay = _dateOnly(provider.predictedOvulationDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dùng context.watch để lắng nghe toàn bộ thay đổi từ provider
    final cycleProvider = context.watch<CycleProvider>();

    // Cập nhật các sets mỗi khi provider có dữ liệu mới
    _updateLocalSets(cycleProvider);

    // Cập nhật text trong ô ghi chú một cách an toàn
    final log = cycleProvider.selectedDayLog;
    if (log != null && isSameDay(log.date, _selectedDay)) {
      if (_notesController.text != log.notes) {
        _notesController.text = log.notes;
        _notesController.selection = TextSelection.fromPosition(TextPosition(offset: _notesController.text.length));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theo dõi chu kỳ'),
        centerTitle: true,
      ),
      body: cycleProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          _buildTableCalendar(),
          const SizedBox(height: 24),
          _buildDailyNotesSection(cycleProvider),
          const SizedBox(height: 24),
          CycleChartCard(chartData: cycleProvider.recentCompletedCyclesForChart),
          const SizedBox(height: 16),
          DetailedCycleInfoCard( provider: cycleProvider,),
        ],
      ),
    );
  }

  // Widget xây dựng Lịch
  Widget _buildTableCalendar() {
    return Card(
      elevation: 2,
      child: TableCalendar(
        locale: 'vi_VN',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            context.read<CycleProvider>().fetchDailyLog(selectedDay);
          }
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() { _calendarFormat = format; });
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) => _buildCell(day:day, isSelected: false, isToday: false),
          todayBuilder: (context, day, focusedDay) => _buildCell(day:day, isSelected: false, isToday: true),
          selectedBuilder: (context, day, focusedDay) => _buildCell(day:day, isSelected: true, isToday: isSameDay(day, DateTime.now())),
          outsideBuilder: (context, day, focusedDay) => Center(child: Text(day.day.toString(), style: const TextStyle(color: Colors.grey))),
        ),
      ),
    );
  }

  // Widget xây dựng từng ô ngày trong lịch
  Widget _buildCell({required DateTime day, required bool isSelected, required bool isToday}) {
    final date = _dateOnly(day);
    final isPeriod = _periodDays.contains(date);
    final isFertile = _fertileDays.contains(date);
    final isOvulation = isSameDay(_ovulationDay, date);
    final isPredicted = isSameDay(_predictedNextPeriodStart, date);

    BoxDecoration decoration = const BoxDecoration();
    TextStyle textStyle = const TextStyle();

    if (isSelected) {
      decoration = BoxDecoration(color: Colors.blue.shade200, shape: BoxShape.circle);
      textStyle = const TextStyle(color: Colors.white);
    } else if (isOvulation) {
      decoration = BoxDecoration(color: Colors.orange.shade300, shape: BoxShape.circle);
    } else if (isFertile) {
      decoration = BoxDecoration(color: Colors.green.shade200, shape: BoxShape.circle);
    } else if (isPeriod) {
      decoration = BoxDecoration(color: Colors.red.shade200, shape: BoxShape.circle);
    } else if (isPredicted) {
      decoration = BoxDecoration(border: Border.all(color: Colors.blue, width: 1.5), shape: BoxShape.circle);
    } else if (isToday) {
      decoration = BoxDecoration(border: Border.all(color: Colors.red, width: 1.5) ,shape: BoxShape.circle);
    }

    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: decoration,
      alignment: Alignment.center,
      child: Text(day.day.toString(), style: textStyle),
    );
  }

  // Widget xây dựng phần Ghi chú
  Widget _buildDailyNotesSection(CycleProvider provider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ghi chú & Triệu chứng cho: ${DateFormat('dd/MM/yyyy', 'vi_VN').format(_selectedDay)}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12.0),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Thêm ghi chú ở đây...', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12.0),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  context.read<CycleProvider>().saveDailyLog(_selectedDay, _notesController.text);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu ghi chú!')));
                },
                child: provider.isLoadingLog ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Lưu Ghi chú'),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Widget xây dựng thẻ Thông tin
  Widget _buildCycleInfoCard(CycleProvider provider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thông tin chu kỳ', style: Theme.of(context).textTheme.titleMedium),
            const Divider(height: 24),
            _InfoRow(title: 'Chu kỳ trung bình:', value: provider.averageCycleLength),
            _InfoRow(title: 'Kỳ kinh trung bình:', value: provider.averagePeriodLength),
            const Divider(height: 24),
            _InfoRow(title: 'Dự đoán kỳ tới:', value: provider.predictedNextPeriodStart != null ? DateFormat('dd/MM/yyyy').format(provider.predictedNextPeriodStart!) : '...'),
            _InfoRow(title: 'Dự đoán rụng trứng:', value: provider.predictedOvulationDate != null ? DateFormat('dd/MM/yyyy').format(provider.predictedOvulationDate!) : '...'),
            _InfoRow(title: 'Cửa sổ thụ thai:', value: provider.fertileWindowStart != null ? '${DateFormat('dd/MM').format(provider.fertileWindowStart!)} - ${DateFormat('dd/MM/yyyy').format(provider.fertileWindowEnd!)}' : '...'),
          ],
        ),
      ),
    );
  }
}


// Widget con để hiển thị một dòng thông tin
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
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}