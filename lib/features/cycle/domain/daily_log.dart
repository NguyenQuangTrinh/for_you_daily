// lib/features/cycle/domain/daily_log.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyLog {
  final DateTime date;
  final String notes;

  DailyLog({required this.date, this.notes = ''});

  factory DailyLog.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return DailyLog(
      date: (doc.id as String).isNotEmpty ? DateTime.parse(doc.id) : DateTime.now(),
      notes: data['notes'] ?? '',
    );
  }
}