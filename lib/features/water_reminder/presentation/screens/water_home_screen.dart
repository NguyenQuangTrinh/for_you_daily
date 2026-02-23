// lib/features/water_reminder/presentation/screens/water_home_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/config/constants/app_colors.dart';
import '../../../../core/widgets/app_drawer.dart'; // Import drawer mới

class WaterHomeScreen extends StatefulWidget {
  const WaterHomeScreen({super.key});

  @override
  State<WaterHomeScreen> createState() => _WaterHomeScreenState();
}

class _WaterHomeScreenState extends State<WaterHomeScreen> {
  int _waterDrunk = 0;
  final int _dailyGoal = 2000;
  final int _amountPerGlass = 250;

  static const String waterDrunkKey = 'water_drunk';
  static const String lastLoggedDateKey = 'last_logged_date';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Các hàm _loadData, _saveData, _logWater giữ nguyên như cũ...
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateUtils.dateOnly(DateTime.now()).toIso8601String();

    // Lấy ngày lưu trữ lần cuối
    final lastLoggedDate = prefs.getString(lastLoggedDateKey);

    // Nếu là ngày mới, reset dữ liệu. Nếu không, tải dữ liệu cũ.
    if (lastLoggedDate == today) {
      setState(() {
        _waterDrunk = prefs.getInt(waterDrunkKey) ?? 0;
      });
    } else {
      // Nếu là ngày mới, reset về 0 và lưu lại
      setState(() {
        _waterDrunk = 0;
      });
      await _saveData(0); // Lưu giá trị 0 cho ngày hôm nay
    }
  }

  Future<void> _saveData(int waterAmount) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateUtils.dateOnly(DateTime.now()).toIso8601String();

    await prefs.setInt(waterDrunkKey, waterAmount);
    await prefs.setString(lastLoggedDateKey, today);
  }

  // Hàm được gọi khi nhấn nút '+'
  void _logWater() {
    // Chỉ tăng nếu chưa đạt mục tiêu
    if (_waterDrunk < _dailyGoal) {
      setState(() {
        _waterDrunk += _amountPerGlass;
        // Đảm bảo không vượt quá mục tiêu
        if (_waterDrunk > _dailyGoal) {
          _waterDrunk = _dailyGoal;
        }
      });
      _saveData(_waterDrunk); // Lưu lại giá trị mới
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;
    final progress = (_waterDrunk / _dailyGoal).clamp(0.0, 1.0);

    return Scaffold(
      // Thêm drawer vào Scaffold
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Mục tiêu hôm nay'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Giao diện chai nước
            SizedBox(
              width: size.width * 0.6,
              height: size.height * 0.5,
              child: Stack(
                children: [
                  // Lớp nền của chai nước
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey.shade200
                          : Colors.grey.shade800,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 4,
                      ),
                    ),
                  ),

                  // Lớp nước bên trong (với hiệu ứng động)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOut,
                      height: size.height * 0.5 * progress,
                      decoration: const BoxDecoration(
                        color: AppColors.water,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(26),
                          topRight: Radius.circular(26),
                          bottomLeft: Radius.circular(26),
                          bottomRight: Radius.circular(26),
                        ),
                      ),
                    ),
                  ),

                  // Lớp hiển thị text
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: textTheme.displayLarge?.copyWith(color: progress > 0.4 ? Colors.white : AppColors.textPrimary),
                        ),
                        Text(
                          '$_waterDrunk / $_dailyGoal ml',
                          style: textTheme.headlineSmall?.copyWith(color: progress > 0.5 ? Colors.white70 : AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // Nút bấm được thiết kế lại
            SizedBox(
              width: 80,
              height: 80,
              child: FloatingActionButton(
                onPressed: _logWater,
                tooltip: 'Thêm một lần uống',
                child: const Icon(Icons.add, size: 40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}