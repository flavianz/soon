import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/task.dart';
import '../utils.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final timeDiff = getTimeDifferenceText(task.deadlineTimestamp);
    return Dismissible(
      key: Key("${task.id}_${task.hasBeenCompleted()}"),
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20),
        child: Icon(Icons.check, color: Colors.white),
      ),

      secondaryBackground: Container(
        color: Colors.grey,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.edit, color: Colors.white),
      ),

      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await FirebaseFirestore.instance
              .collection("tasks")
              .doc(task.id)
              .update({
                "has_been_completed": true,
                "completion_timestamp": Timestamp.now(),
              });
        } else {
          print("right");
        }
        return false;
      },
      child: Card.outlined(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                constraints: BoxConstraints(minHeight: 18, minWidth: 18),
                decoration: BoxDecoration(
                  color: switch (task.effort) {
                    TaskEffort.easy => Colors.green.shade100,
                    TaskEffort.medium => Colors.yellow.shade500,
                    TaskEffort.hard => Colors.orange.shade500,
                    TaskEffort.veryHard => Colors.redAccent.shade100,
                  },
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    Text(timeDiff.$1),
                    Text(timeDiff.$2, style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              SizedBox(height: 32, child: VerticalDivider()),
              Text(task.description),
            ],
          ),
        ),
      ),
    );
  }
}
