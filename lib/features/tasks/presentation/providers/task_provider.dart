// lib/features/tasks/presentation/providers/task_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../domain/task.dart';

class TaskProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;


  // Lấy stream các công việc GỐC (không có cha)
  Stream<List<Task>>? get rootTasksStream {
    if (_userId == null) return null;
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .where('parentId', isEqualTo: null) // Chỉ lấy các task có parentId là null
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  // Lấy stream các công việc CON của một công việc cha cụ thể
  Stream<List<Task>> getSubtasksStream(String parentId) {
    if (_userId == null) return const Stream.empty();
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .where('parentId', isEqualTo: parentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  // Thêm một công việc mới (có thể là cha hoặc con)
  Future<void> addTask({
    required String title,
    String? parentId, // Cung cấp parentId nếu đây là công việc con
    TaskPriority priority = TaskPriority.low,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_userId == null || title.isEmpty) return;

    await _firestore.collection('users').doc(_userId).collection('tasks').add({
      'title': title,
      'isDone': false,
      'createdAt': Timestamp.now(),
      'parentId': parentId,
      'priority': priority.name, // Lưu tên của enum
      'startDate': startDate != null ? Timestamp.fromDate(startDate) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate) : null,
    });
  }

  // Cập nhật trạng thái hoàn thành
  Future<void> toggleTaskStatus(String taskId, bool currentStatus) async {
    if (_userId == null) return;
    await _firestore
        .collection('users').doc(_userId).collection('tasks').doc(taskId)
        .update({'isDone': !currentStatus});
  }

  // Xóa một công việc (sẽ cần logic phức tạp hơn để xóa cả các con của nó sau này)
  Future<void> deleteTask(String taskId) async {
    if (_userId == null) return;
    await _firestore
        .collection('users').doc(_userId).collection('tasks').doc(taskId)
        .delete();
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> data) async {
    if (_userId == null) return;
    await _firestore
        .collection('users').doc(_userId).collection('tasks').doc(taskId)
        .update(data);
  }
}

