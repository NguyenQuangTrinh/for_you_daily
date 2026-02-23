// lib/features/cycle/domain/cycle_period.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CyclePeriod {
  final DateTime startDate;
  final DateTime? endDate;

  CyclePeriod({required this.startDate, this.endDate});

  factory CyclePeriod.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return CyclePeriod(
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null ? (data['endDate'] as Timestamp).toDate() : null,
    );
  }
}