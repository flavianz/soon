import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/task.dart';

final userProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

final tasksProvider = StreamProvider.autoDispose<List<Task>>((ref) {
  final user = ref.watch(userProvider);
  return FirebaseFirestore.instance
      .collection("tasks")
      .where("user", isEqualTo: user.value?.uid ?? "-")
      .orderBy("deadline_timestamp")
      .snapshots()
      .map((docs) => docs.docs.map(Task.fromDoc).toList());
});
