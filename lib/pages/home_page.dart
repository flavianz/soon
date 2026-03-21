import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soon/providers.dart';

import '../core/task.dart';
import '../utils.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final tasksStream = ref.watch(tasksProvider);
    if (tasksStream.isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (tasksStream.hasError) {
      print(tasksStream.error);
      return Center(child: Text("Error"));
    }

    final inputController = TextEditingController();

    final tasks = tasksStream.value!;
    tasks.sort(
      (task1, task2) =>
          task1.deadlineTimestamp.compareTo(task2.deadlineTimestamp),
    );

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: tasks.map((task) {
                final timeDiff = getTimeDifferenceText(task.deadlineTimestamp);
                return Dismissible(
                  key: Key(task.id),
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 20),
                    child: Icon(Icons.check, color: Colors.white),
                  ),

                  // Swipe left → red background
                  secondaryBackground: Container(
                    color: Colors.grey,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.edit, color: Colors.white),
                  ),

                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      print("left");
                      return true;
                    } else {
                      print("right");
                      return false;
                    }
                  },
                  child: Card.outlined(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              minHeight: 18,
                              minWidth: 18,
                            ),
                            decoration: BoxDecoration(
                              color: switch (task.effort) {
                                TaskEffort.easy => Colors.green.shade100,
                                TaskEffort.medium => Colors.yellow.shade500,
                                TaskEffort.hard => Colors.amber.shade500,
                                TaskEffort.veryHard =>
                                  Colors.redAccent.shade100,
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
                                Text(
                                  timeDiff.$2,
                                  style: TextStyle(fontSize: 12),
                                ),
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
              }).toList(),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Card.filled(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            color: Theme.of(context).focusColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  TextField(
                    controller: inputController,
                    decoration: InputDecoration(
                      hintText: "Soon I'm going to...",
                      border: InputBorder.none,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(onPressed: () {}, child: Text("Today")),
                      OutlinedButton(onPressed: () {}, child: Text("Medium")),
                      FilledButton.icon(
                        icon: Icon(Icons.check),
                        onPressed: () {
                          FirebaseFirestore.instance.collection("tasks").add({
                            "description": inputController.text,
                            "creation_timestamp": Timestamp.now(),
                            "deadline_timestamp": Timestamp.now(),
                            "effort": "medium",
                            "has_been_completed": false,
                            "user": FirebaseAuth.instance.currentUser!.uid,
                          });
                        },
                        label: Text("Done"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
