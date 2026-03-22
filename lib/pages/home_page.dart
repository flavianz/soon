import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soon/components/task_card.dart';
import 'package:soon/providers.dart';
import 'package:soon/utils.dart';

import '../core/task.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final inputController = TextEditingController();

  TaskEffort effort = TaskEffort.easy;
  DateTime deadline = DateTime.now();

  bool isEditMode = false;
  Task? editTask;

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

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

    final tasks = tasksStream.value!;
    tasks.sort(
      (task1, task2) =>
          task1.deadlineTimestamp.compareTo(task2.deadlineTimestamp),
    );

    onEdit(Task task) {
      setState(() {
        isEditMode = true;
        editTask = task;
        inputController.text = task.description;
        deadline = task.deadlineTimestamp.addDays(-1);
        effort = task.effort;
      });
    }

    final openTasks = tasks
        .where((task) => !task.hasBeenCompleted())
        .map((task) => TaskCard(task: task, onEdit: onEdit))
        .toList();
    final completedTasks = tasks
        .where((task) => task.hasBeenCompleted())
        .map((task) => TaskCard(task: task, onEdit: onEdit))
        .toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: "Open"),
              Tab(text: "Completed"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                openTasks.isEmpty
                    ? Center(child: Text("No open tasks"))
                    : ListView(children: openTasks),

                completedTasks.isEmpty
                    ? Center(child: Text("No completed tasks"))
                    : ListView(children: completedTasks),
              ],
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    isEditMode
                        ? Text(
                            "Editing: ${editTask!.description}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).dividerColor,
                            ),
                          )
                        : SizedBox.shrink(),
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
                        OutlinedButton(
                          onPressed: () async {
                            if (deadline.isBefore(DateTime.now().addDays(2))) {
                              setState(() {
                                deadline = deadline.addDays(1);
                              });
                            } else {
                              final pickedDate = await showDatePicker(
                                context: context,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().addMonths(12 * 10),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  deadline = pickedDate;
                                });
                              }
                            }
                          },
                          child: Text(() {
                            if (deadline.isSameDate(DateTime.now())) {
                              return "Today";
                            }
                            if (deadline.isSameDate(
                              DateTime.now().addDays(1),
                            )) {
                              return "Tomorrow";
                            }
                            if (deadline
                                    .difference(DateTime.now())
                                    .abs()
                                    .inDays <
                                6) {
                              return deadline.getWeekdayAbbreviation();
                            }
                            return deadline.toFormattedDateString();
                          }()),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: switch (effort) {
                              TaskEffort.easy => Colors.green.shade600,
                              TaskEffort.medium => Colors.yellow.shade800,
                              TaskEffort.hard => Colors.orange.shade900,
                              TaskEffort.veryHard => Colors.redAccent.shade400,
                            },
                          ),
                          onPressed: () {
                            setState(() {
                              effort = switch (effort) {
                                TaskEffort.easy => TaskEffort.medium,
                                TaskEffort.medium => TaskEffort.hard,
                                TaskEffort.hard => TaskEffort.veryHard,
                                TaskEffort.veryHard => TaskEffort.easy,
                              };
                            });
                          },
                          child: Text(switch (effort) {
                            TaskEffort.easy => "Easy",
                            TaskEffort.medium => "Medium",
                            TaskEffort.hard => "Hard",
                            TaskEffort.veryHard => "Very Hard",
                          }),
                        ),
                        FilledButton.icon(
                          icon: Icon(Icons.check),
                          onPressed: () async {
                            if (isEditMode) {
                              await FirebaseFirestore.instance
                                  .collection("tasks")
                                  .doc(editTask!.id)
                                  .update({
                                    "description": inputController.text,
                                    "deadline_timestamp": Timestamp.fromDate(
                                      deadline.getDayStart().addDays(1),
                                    ),
                                    "effort": switch (effort) {
                                      TaskEffort.easy => "easy",
                                      TaskEffort.medium => "medium",
                                      TaskEffort.hard => "hard",
                                      TaskEffort.veryHard => "very_hard",
                                    },
                                  });
                            } else {
                              await FirebaseFirestore.instance
                                  .collection("tasks")
                                  .add({
                                    "description": inputController.text,
                                    "creation_timestamp": Timestamp.now(),
                                    "deadline_timestamp": Timestamp.fromDate(
                                      deadline.getDayStart().addDays(1),
                                    ),
                                    "effort": switch (effort) {
                                      TaskEffort.easy => "easy",
                                      TaskEffort.medium => "medium",
                                      TaskEffort.hard => "hard",
                                      TaskEffort.veryHard => "very_hard",
                                    },
                                    "has_been_completed": false,
                                    "user":
                                        FirebaseAuth.instance.currentUser!.uid,
                                  });
                            }
                            setState(() {
                              isEditMode = false;
                              editTask = null;
                              effort = TaskEffort.easy;
                              deadline = DateTime.now();
                              inputController.clear();
                            });
                          },
                          label: Text(isEditMode ? "Done" : "Add"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
