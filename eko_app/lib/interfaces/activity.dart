import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eko_app/types/activity.dart';

Future<void> setNewActivityBool(bool value, String uid) async {
  final firestore = FirebaseFirestore.instance;
  await firestore.collection('users').doc(uid).set({
    'newActivity': value,
  }, SetOptions(merge: true));
}

Future<void> uploadActivity(ActivityModel activity, String user) async {
  final firestore = FirebaseFirestore.instance;
  await Future.wait([
    firestore
        .collection('users')
        .doc(user)
        .collection('newActivity')
        .add(activity.toJson()),
    setNewActivityBool(true, user),
  ]);
}
