import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/task.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/toggle_task.dart';
import '../../data/datasources/task_local_data_source.dart';
import '../../data/repositories/task_repository_impl.dart';


final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Should be overridden in main.dart');
});

final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return TaskLocalDataSourceImpl(sharedPreferences: sharedPreferences);
});


final taskRepositoryProvider = Provider((ref) {
  final localDataSource = ref.watch(taskLocalDataSourceProvider);
  return TaskRepositoryImpl(localDataSource: localDataSource);
});


final getTasksUseCaseProvider = Provider((ref) {
  return GetTasks(ref.watch(taskRepositoryProvider));
});

final addTaskUseCaseProvider = Provider((ref) {
  return AddTask(ref.watch(taskRepositoryProvider));
});

final toggleTaskUseCaseProvider = Provider((ref) {
  return ToggleTask(ref.watch(taskRepositoryProvider));
});

final deleteTaskUseCaseProvider = Provider((ref) {
  return DeleteTask(ref.watch(taskRepositoryProvider));
});

class TasksNotifier extends StateNotifier<List<Task>> {
  final GetTasks _getTasks;
  final AddTask _addTask;
  final ToggleTask _toggleTask;
  final DeleteTask _deleteTask;
  final Uuid _uuid = const Uuid();

  TasksNotifier({
    required GetTasks getTasks,
    required AddTask addTask,
    required ToggleTask toggleTask,
    required DeleteTask deleteTask,
  })  : _getTasks = getTasks,
        _addTask = addTask,
        _toggleTask = toggleTask,
        _deleteTask = deleteTask,
        super([]) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    final tasks = await _getTasks();
    state = tasks;
  }

  Future<void> addNewTask(String title, String description) async {
    final newTask = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );
    await _addTask(newTask);
    await loadTasks();
  }

  Future<void> toggleTaskStatus(Task task) async {
    await _toggleTask(task);
    await loadTasks();
  }

  Future<void> removeTask(String id) async {
    await _deleteTask(id);
    await loadTasks();
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  final getTasks = ref.watch(getTasksUseCaseProvider);
  final addTask = ref.watch(addTaskUseCaseProvider);
  final toggleTask = ref.watch(toggleTaskUseCaseProvider);
  final deleteTask = ref.watch(deleteTaskUseCaseProvider);

  return TasksNotifier(
    getTasks: getTasks,
    addTask: addTask,
    toggleTask: toggleTask,
    deleteTask: deleteTask,
  );
});

enum TaskFilter { all, completed, active }

final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);

final filteredTasksProvider = Provider<List<Task>>((ref) {
  final filter = ref.watch(taskFilterProvider);
  final tasks = ref.watch(tasksProvider);

  switch (filter) {
    case TaskFilter.completed:
      return tasks.where((task) => task.isCompleted).toList();
    case TaskFilter.active:
      return tasks.where((task) => !task.isCompleted).toList();
    case TaskFilter.all:
    return tasks;
  }
});