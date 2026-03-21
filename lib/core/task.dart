import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String id;
  String description;
  DateTime creationTimestamp;
  DateTime deadlineTimestamp;

  Task(
    this.id,
    this.description,
    this.creationTimestamp,
    this.deadlineTimestamp,
  );

  factory Task.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final description = data["description"] as String;
    final creationTimestamp = (data["creation_timestamp"] as Timestamp)
        .toDate();
    final deadlineTimestamp = (data["deadline_timestamp"] as Timestamp)
        .toDate();
    final hasBeenCompleted = data["has_been_completed"] as bool;

    if (hasBeenCompleted) {
      final completionTimestamp = (data["deadline_timestamp"] as Timestamp)
          .toDate();
      return CompletedTask(
        doc.id,
        description,
        creationTimestamp,
        deadlineTimestamp,
        completionTimestamp,
      );
    }

    return Task(doc.id, description, creationTimestamp, deadlineTimestamp);
  }

  bool hasBeenCompleted() {
    return this is CompletedTask;
  }
}

class CompletedTask extends Task {
  DateTime completionTimestamp;

  CompletedTask(
    super.id,
    super.description,
    super.creationTimestamp,
    super.deadlineTimestamp,
    this.completionTimestamp,
  );
}
