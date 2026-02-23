// lib/features/cycle/domain/cycle_record.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CycleRecord {
  final String id; // ID của document trên Firestore
  final DateTime startDate;
  final DateTime? endDate;
  final int? periodLength;
  final int? cycleLength;

  CycleRecord({
    required this.id,
    required this.startDate,
    this.endDate,
    this.periodLength,
    this.cycleLength,
  });

  factory CycleRecord.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    final startDate = (data['startDate'] as Timestamp).toDate();
    final endDate = data['endDate'] != null ? (data['endDate'] as Timestamp).toDate() : null;

    int? periodLen;
    if (endDate != null) {
      periodLen = endDate.difference(startDate).inDays + 1;
    }

    return CycleRecord(
      id: doc.id,
      startDate: startDate,
      endDate: endDate,
      periodLength: periodLen,
      // cycleLength sẽ được tính toán trong provider
    );
  }
}