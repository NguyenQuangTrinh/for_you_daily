// lib/features/cycle/presentation/providers/cycle_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../domain/cycle_record.dart';
import '../../domain/daily_log.dart' ;


class CycleProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Dữ liệu thô từ Firestore
  List<CycleRecord> _cycleRecords = [];
  DailyLog? _selectedDayLog;

  // Trạng thái loading
  bool _isLoading = true;
  bool _isLoadingLog = false;

  // Dữ liệu đã được tính toán
  String _currentCycleStatus = "Đang tải...";
  String _averageCycleLength = "...";
  String _averagePeriodLength = "...";
  DateTime? _predictedNextPeriodStart;
  DateTime? _predictedOvulationDate;
  DateTime? _fertileWindowStart;
  DateTime? _fertileWindowEnd;

  // Getters để UI truy cập
  List<CycleRecord> get cycleRecords => _cycleRecords;
  DailyLog? get selectedDayLog => _selectedDayLog;
  bool get isLoading => _isLoading;
  bool get isLoadingLog => _isLoadingLog;
  String get currentCycleStatus => _currentCycleStatus;
  String get averageCycleLength => _averageCycleLength;
  String get averagePeriodLength => _averagePeriodLength;
  DateTime? get predictedNextPeriodStart => _predictedNextPeriodStart;
  DateTime? get predictedOvulationDate => _predictedOvulationDate;
  DateTime? get fertileWindowStart => _fertileWindowStart;
  DateTime? get fertileWindowEnd => _fertileWindowEnd;

  // Lấy dữ liệu chu kỳ cho biểu đồ
  List<CycleRecord> get recentCompletedCyclesForChart {
    return _cycleRecords.where((r) => r.cycleLength != null).toList().reversed.take(6).toList().reversed.toList();
  }


  CycleProvider() {
    _init();
  }

  // Hàm khởi tạo
  void _init() {
    if (_auth.currentUser != null) {
      fetchCycleData();
    } else {
      _auth.authStateChanges().listen((user) {
        if (user != null) {
          fetchCycleData();
        }
      });
    }
  }

  // Lấy toàn bộ dữ liệu chu kỳ từ Firestore
  Future<void> fetchCycleData() async {
    _isLoading = true;
    notifyListeners();

    final user = _auth.currentUser;
    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('menstrual_cycles')
        .orderBy('startDate', descending: false)
        .get();

    _cycleRecords = snapshot.docs.map((doc) => CycleRecord.fromFirestore(doc)).toList();
    _calculateStatistics(); // Tính toán sau khi lấy dữ liệu

    _isLoading = false;
    notifyListeners();
  }

  // Bắt đầu kỳ kinh
  Future<void> startPeriod() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).collection('menstrual_cycles').add({
      'startDate': Timestamp.now(),
      'endDate': null,
    });
    await fetchCycleData(); // Tải lại toàn bộ dữ liệu
  }

  // Kết thúc kỳ kinh
  Future<void> endPeriod() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final snapshot = await _firestore.collection('users').doc(user.uid)
        .collection('menstrual_cycles').where('endDate', isEqualTo: null)
        .orderBy('startDate', descending: true).limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({'endDate': Timestamp.now()});
      await fetchCycleData(); // Tải lại toàn bộ dữ liệu
    }
  }

  // Lấy ghi chú cho một ngày cụ thể
  Future<void> fetchDailyLog(DateTime date) async {
    _isLoadingLog = true;
    notifyListeners();

    final user = _auth.currentUser;
    if (user == null) {
      _isLoadingLog = false;
      notifyListeners();
      return;
    }

    final dateString = DateFormat('yyyy-MM-dd').format(date);
    final docRef = _firestore.collection('users').doc(user.uid).collection('daily_logs').doc(dateString);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      _selectedDayLog = DailyLog.fromFirestore(docSnapshot);
    } else {
      _selectedDayLog = DailyLog(date: date, notes: '');
    }

    _isLoadingLog = false;
    notifyListeners();
  }

  // Lưu ghi chú
  Future<void> saveDailyLog(DateTime date, String notes) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    await _firestore.collection('users').doc(user.uid).collection('daily_logs').doc(dateString).set({
      'notes': notes,
    });
    // Cập nhật lại log hiện tại để UI thay đổi nếu cần
    if (_selectedDayLog?.date == date) {
      _selectedDayLog = DailyLog(date: date, notes: notes);
      notifyListeners();
    }
  }

  // Hàm tính toán các chỉ số
  void _calculateStatistics() {
    if (_cycleRecords.isEmpty) {
      _currentCycleStatus = "Chạm để thêm dữ liệu chu kỳ đầu tiên.";
      return;
    }

    for (int i = 0; i < _cycleRecords.length; i++) {
      if (i > 0) {
        final current = _cycleRecords[i];
        final previous = _cycleRecords[i-1];
        final length = current.startDate.difference(previous.startDate).inDays;
        _cycleRecords[i] = CycleRecord(
            id: current.id,
            startDate: current.startDate,
            endDate: current.endDate,
            periodLength: current.periodLength,
            cycleLength: length // Gán cycleLength
        );
      }
    }

    // Cập nhật trạng thái hiện tại
    final lastCycle = _cycleRecords.last;
    if(lastCycle.endDate == null){
      final dayOfPeriod = DateTime.now().difference(lastCycle.startDate).inDays + 1;
      _currentCycleStatus = 'Đang trong ngày thứ $dayOfPeriod của kỳ kinh';
    } else {
      final dayOfCycle = DateTime.now().difference(lastCycle.startDate).inDays + 1;
      _currentCycleStatus = 'Ngày thứ $dayOfCycle của chu kỳ';
    }

    List<int> periodLengths = _cycleRecords.where((r) => r.periodLength != null).map((r) => r.periodLength!).toList();
    List<int> cycleLengths = _cycleRecords.where((r) => r.cycleLength != null).map((r) => r.cycleLength!).toList();

    for (int i = 0; i < _cycleRecords.length; i++) {
      final current = _cycleRecords[i];
      if(current.endDate != null) {
        periodLengths.add(current.endDate!.difference(current.startDate).inDays + 1);
      }
      if (i > 0) {
        final previous = _cycleRecords[i-1];
        cycleLengths.add(current.startDate.difference(previous.startDate).inDays);
      }
    }

    if (cycleLengths.length < 1 || periodLengths.isEmpty) {
      _averageCycleLength = '...';
      _averagePeriodLength = '...';
      return;
    }

    final avgPeriod = (periodLengths.reduce((a, b) => a + b) / periodLengths.length).round();
    _averagePeriodLength = '$avgPeriod ngày';

    final avgCycle = (cycleLengths.reduce((a, b) => a + b) / cycleLengths.length).round();
    _averageCycleLength = '$avgCycle ngày';

    // Dự đoán
    final lastPeriodStart = _cycleRecords.last.startDate;
    _predictedNextPeriodStart = lastPeriodStart.add(Duration(days: avgCycle));
    _predictedOvulationDate = _predictedNextPeriodStart!.subtract(const Duration(days: 14));
    _fertileWindowStart = _predictedOvulationDate!.subtract(const Duration(days: 4));
    _fertileWindowEnd = _predictedOvulationDate!.add(const Duration(days: 1));
  }
}