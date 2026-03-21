import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soon/providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);
    if (tasks.isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (tasks.hasError) {
      print(tasks.error);
      return Center(child: Text("Error"));
    }
    return SingleChildScrollView(
      child: Column(
        children: tasks.value!.map((task) {
          return Card.outlined(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(task.description),
            ),
          );
        }).toList(),
      ),
    );
  }
}
