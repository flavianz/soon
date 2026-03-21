import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskEffort { easy, medium, hard, veryHard }

class Task {
  String id;
  String description;
  TaskEffort effort;
  DateTime creationTimestamp;
  DateTime deadlineTimestamp;

  Task(
    this.id,
    this.description,
    this.effort,
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
    final effort = switch (data["effort"]) {
      "easy" => TaskEffort.easy,
      "medium" => TaskEffort.medium,
      "hard" => TaskEffort.hard,
      "very_hard" => TaskEffort.veryHard,
      _ => throw Exception("Invalid effort: ${data["effort"]}"),
    };

    if (hasBeenCompleted) {
      final completionTimestamp = (data["deadline_timestamp"] as Timestamp)
          .toDate();
      return CompletedTask(
        doc.id,
        description,
        effort,
        creationTimestamp,
        deadlineTimestamp,
        completionTimestamp,
      );
    }

    return Task(
      doc.id,
      description,
      effort,
      creationTimestamp,
      deadlineTimestamp,
    );
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
    super.effort,
    super.creationTimestamp,
    super.deadlineTimestamp,
    this.completionTimestamp,
  );
}
