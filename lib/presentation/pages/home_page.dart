import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tazk/domain/entities/task.dart';
import '../providers/task_providers.dart';
import 'add_task_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredTasks = ref.watch(filteredTasksProvider);
    final currentFilter = ref.watch(taskFilterProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Task Manager'),
        centerTitle: true,
        elevation: 0,
        actions: [
          PopupMenuButton<TaskFilter>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) {
              ref.read(taskFilterProvider.notifier).state = filter;
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: TaskFilter.all,
                child: Text(
                  'All Tasks',
                  style: TextStyle(
                    fontWeight: currentFilter == TaskFilter.all
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              PopupMenuItem(
                value: TaskFilter.active,
                child: Text(
                  'Active',
                  style: TextStyle(
                    fontWeight: currentFilter == TaskFilter.active
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              PopupMenuItem(
                value: TaskFilter.completed,
                child: Text(
                  'Completed',
                  style: TextStyle(
                    fontWeight: currentFilter == TaskFilter.completed
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: filteredTasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentFilter == TaskFilter.all
                        ? 'No tasks yet'
                        : currentFilter == TaskFilter.active
                            ? 'No active tasks'
                            : 'No completed tasks',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return TaskCard(task: task);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTaskPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskCard extends ConsumerWidget {
  final Task task;

  const TaskCard({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted ? Colors.grey : Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    task.isCompleted 
                        ? Icons.check_circle 
                        : Icons.circle_outlined,
                    color: task.isCompleted ? Colors.green : Colors.grey,
                  ),
                  onPressed: () {
                    ref.read(tasksProvider.notifier).toggleTaskStatus(task);
                  },
                ),
              ],
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                task.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  decoration:
                      task.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(task.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmation(context, ref);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(tasksProvider.notifier).removeTask(task.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
