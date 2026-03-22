import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soon/components/task_card.dart';
import 'package:soon/providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final inputController = TextEditingController();

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
    final openTasks = tasks
        .where((task) => !task.hasBeenCompleted())
        .map((task) => TaskCard(task: task))
        .toList();
    final completedTasks = tasks
        .where((task) => task.hasBeenCompleted())
        .map((task) => TaskCard(task: task))
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
      ),
    );
  }
}
