import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final emailVerificationCutoffProvider = FutureProvider<DateTime?>((ref) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('utilities')
        .doc('auth')
        .get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    final value = data['emailVerificationCutoffDate'];
    if (value is Timestamp) {
      return value.toDate().toUtc();
    }
    if (value is String) {
      return DateTime.tryParse(value)?.toUtc();
    }
    return null;
  } catch (e, st) {
    debugPrint('Failed to load emailVerificationCutoffDate: $e\n$st');
    return null;
  }
});
