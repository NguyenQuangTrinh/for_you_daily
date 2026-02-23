// lib/features/tasks/domain/task.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Định nghĩa các mức độ ưu tiên
enum TaskPriority { low, medium, high }

class Task {
  final String id;
  final String title;
  final bool isDone;
  final DateTime createdAt;
  final String? description;

  // Các trường mới
  final String? parentId; // ID của công việc cha, null nếu là công việc gốc
  final TaskPriority priority; // Mức độ ưu tiên
  final DateTime? startDate;
  final DateTime? endDate;

  Task({
    required this.id,
    required this.title,
    required this.isDone,
    required this.createdAt,
    this.parentId,
    this.description,
    this.priority = TaskPriority.low, // Mặc định là thấp
    this.startDate,
    this.endDate,
  });

  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Hàm helper an toàn để chuyển đổi Timestamp? sang DateTime?
    DateTime? safeTimestampToDate(Timestamp? timestamp) {
      return timestamp?.toDate();
    }

    return Task(
      id: doc.id,
      title: data['title'] ?? 'Không có tiêu đề',
      isDone: data['isDone'] ?? false,

      // Xử lý an toàn: Nếu createdAt là null, dùng ngày giờ hiện tại
      createdAt: safeTimestampToDate(data['createdAt']) ?? DateTime.now(),

      parentId: data['parentId'],

      description: data['description'],

      priority: TaskPriority.values.firstWhere(
            (e) => e.name == data['priority'],
        orElse: () => TaskPriority.low,
      ),

      // Dùng hàm helper để chuyển đổi an toàn
      startDate: safeTimestampToDate(data['startDate']),
      endDate: safeTimestampToDate(data['endDate']),
    );
  }


  // Helper để lấy màu sắc từ độ ưu tiên
  Color get priorityColor {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red.shade300;
      case TaskPriority.medium:
        return Colors.orange.shade300;
      case TaskPriority.low:
      return Colors.blue.shade300;
    }
  }
}