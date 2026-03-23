import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/task.dart';
import '../utils.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Function(Task) onEdit;

  const TaskCard({super.key, required this.task, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final timeDiff = getTimeDifferenceText(task.deadlineTimestamp);
    return Dismissible(
      key: Key("${task.id}_${task.hasBeenCompleted()}"),
      background: Container(
        color: task.hasBeenCompleted() ? Colors.redAccent : Colors.green,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20),
        child: Icon(
          task.hasBeenCompleted() ? Icons.undo : Icons.check,
          color: Colors.white,
        ),
      ),

      secondaryBackground: Container(
        color: Colors.grey,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.edit, color: Colors.white),
      ),

      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          if (!task.hasBeenCompleted()) {
            await FirebaseFirestore.instance
                .collection("tasks")
                .doc(task.id)
                .update({
                  "has_been_completed": true,
                  "completion_timestamp": Timestamp.now(),
                });
          } else {
            await FirebaseFirestore.instance
                .collection("tasks")
                .doc(task.id)
                .update({
                  "has_been_completed": false,
                  "completion_timestamp": FieldValue.delete(),
                });
          }
        } else {
          onEdit(task);
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
                    TaskEffort.easy => Colors.green.shade600,
                    TaskEffort.medium => Colors.yellow.shade700,
                    TaskEffort.hard => Colors.orange.shade900,
                    TaskEffort.veryHard => Colors.redAccent.shade400,
                  },
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: task.hasBeenCompleted()
                    ? Center(
                        child: Text("Done", style: TextStyle(fontSize: 12)),
                      )
                    : Column(
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
