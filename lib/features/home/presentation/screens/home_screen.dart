// lib/features/home/presentation/screens/home_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../cycle/presentation/providers/cycle_provider.dart';
import '../../../cycle/presentation/widgets/cycle_info_card.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../tasks/domain/task.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../widgets/tasks_card.dart';
import '../widgets/water_tracker_card.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _waterDrunk = 0;
  final int _dailyGoal = 2000;
  final int _amountPerGlass = 250;
  String _cycleStatus = 'Chưa có dữ liệu.';

  User? _user;
  DocumentReference? _todayDocRef;

  @override
  void initState() {
    super.initState();
    _initUserAndLoadData();
  }

  // Hàm khởi tạo người dùng và tải dữ liệu
  Future<void> _initUserAndLoadData() async {
    // Đăng nhập ẩn danh nếu chưa có người dùng
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
    _user = FirebaseAuth.instance.currentUser;

    if (_user != null) {
      // Tạo tham chiếu đến document của ngày hôm nay
      final todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _todayDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('water_logs')
          .doc(todayString);

      _loadData();
      _loadCycleData();
    }
  }



  // --- LOGIC MỚI VỚI FIRESTORE ---
  Future<void> _loadData() async {
    if (_todayDocRef == null) return;
    final docSnapshot = await _todayDocRef!.get();

    if (docSnapshot.exists) {
      // Nếu document của ngày hôm nay tồn tại, lấy dữ liệu
      final data = docSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _waterDrunk = data['waterDrunk'] ?? 0;
      });
    } else {
      // Nếu không, tạo document mới với giá trị là 0
      await _saveData(0);
    }
  }

  Future<void> _saveData(int waterAmount) async {
    if (_todayDocRef == null) return;

    // Ghi dữ liệu vào Firestore
    await _todayDocRef!.set({'waterDrunk': waterAmount});

    setState(() {
      _waterDrunk = waterAmount;
    });
  }

  void _logWater() {
    if (_waterDrunk < _dailyGoal) {
      int newAmount = _waterDrunk + _amountPerGlass;
      if (newAmount > _dailyGoal) {
        newAmount = _dailyGoal;
      }
      _saveData(newAmount);
    }
  }

  // --- LOGIC MỚI CHO CHU KỲ ---

  // Hiển thị dialog
  void _showMarkCycleDialog() {
    // Lấy provider, listen: false vì đang ở trong hàm, không cần rebuild
    final cycleProvider = context.read<CycleProvider>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // ... (nội dung dialog giữ nguyên)
          actions: <Widget>[
            TextButton(
              child: const Text('Bắt đầu kỳ kinh'),
              onPressed: () {
                Navigator.of(context).pop();
                cycleProvider.startPeriod(); // Gọi provider
              },
            ),
            TextButton(
              child: const Text('Kết thúc kỳ kinh'),
              onPressed: () {
                Navigator.of(context).pop();
                cycleProvider.endPeriod(); // Gọi provider
              },
            ),
            //...
          ],
        );
      },
    );
  }

  // Bắt đầu một kỳ kinh mới
  Future<void> _startPeriod() async {
    if (_user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .collection('menstrual_cycles')
        .add({
      'startDate': Timestamp.now(),
      'endDate': null, // Để trống endDate để biết kỳ kinh đang diễn ra
    });
    _loadCycleData(); // Tải lại dữ liệu để cập nhật UI
  }

  // Kết thúc kỳ kinh hiện tại
  Future<void> _endPeriod() async {
    if (_user == null) return;
    // Tìm kỳ kinh gần nhất chưa có ngày kết thúc
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .collection('menstrual_cycles')
        .where('endDate', isEqualTo: null)
        .orderBy('startDate', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Cập nhật ngày kết thúc là hôm nay
      final docId = querySnapshot.docs.first.id;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('menstrual_cycles')
          .doc(docId)
          .update({'endDate': Timestamp.now()});

      _loadCycleData(); // Tải lại dữ liệu để cập nhật UI
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy kỳ kinh nào đang diễn ra để kết thúc.')),
      );
    }
  }

  // Cập nhật lại hàm tải dữ liệu
  Future<void> _loadCycleData() async {
    if (_user == null) return;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .collection('menstrual_cycles')
        .orderBy('startDate', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final latestCycle = querySnapshot.docs.first.data();
      final startDate = (latestCycle['startDate'] as Timestamp).toDate();
      final endDate = latestCycle['endDate'] as Timestamp?;

      if (endDate == null) {
        // Kỳ kinh đang diễn ra
        final dayOfPeriod = DateTime.now().difference(startDate).inDays + 1;
        setState(() {
          _cycleStatus = 'Đang trong ngày thứ $dayOfPeriod của kỳ kinh';
        });
      } else {
        // Kỳ kinh đã kết thúc, tính ngày của chu kỳ mới
        final dayOfCycle = DateTime.now().difference(startDate).inDays + 1;
        setState(() {
          _cycleStatus = 'Ngày thứ $dayOfCycle của chu kỳ';
        });
      }
    } else {
      setState(() {
        _cycleStatus = 'Chạm để thêm dữ liệu chu kỳ đầu tiên.';
      });
    }
  }

  // --- KẾT THÚC LOGIC CHU KỲ ---

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng!';
    if (hour < 18) return 'Chào buổi chiều!';
    return 'Chào buổi tối!';
  }

  Future<void> _refreshData() async {
    // Gọi lại hàm tải dữ liệu nước
    await _loadData();
    // Yêu cầu CycleProvider tải lại dữ liệu của nó và báo cho UI cập nhật
    if (mounted) {
      await context.read<CycleProvider>().fetchCycleData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat("EEEE, dd 'tháng' MM yyyy", 'vi_VN').format(DateTime.now());
    final cycleStatus = context.watch<CycleProvider>().currentCycleStatus;
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Trang chủ', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                },
              ),
            ]),
            const SizedBox(height: 8),
            Text(_getGreeting(), style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(formattedDate, style: TextStyle(color: Colors.grey.shade400)),
            const SizedBox(height: 24),
            CycleInfoCard(status: cycleStatus,onMarkCycle: _showMarkCycleDialog,),
            const SizedBox(height: 16),
            WaterTrackerCard(
              waterDrunk: _waterDrunk,
              dailyGoal: _dailyGoal,
              onAddWater: _logWater,
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<Task>>(
              stream: taskProvider.rootTasksStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  // Hiển thị card với số 0 trong lúc chờ
                  return const TasksCard(taskCount: 0);
                }
                final allTasks = snapshot.data!;
                // Đếm số công việc gốc chưa hoàn thành
                final incompleteTasksCount = allTasks
                    .where((task) => task.parentId == null && !task.isDone)
                    .length;

                return TasksCard(taskCount: incompleteTasksCount);
              },
            ),
          ],
        ),
      ),
    );
  }
}