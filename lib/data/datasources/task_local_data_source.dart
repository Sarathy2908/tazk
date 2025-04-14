import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final SharedPreferences sharedPreferences;

  TaskLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<TaskModel>> getTasks() async {
    final jsonString = sharedPreferences.getString('tasks');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => TaskModel.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<void> addTask(TaskModel task) async {
    final tasks = await getTasks();
    tasks.add(task);
    await _saveTasks(tasks);
  }

  @override
  Future<void> updateTask(TaskModel updatedTask) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
      await _saveTasks(tasks);
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    final tasks = await getTasks();
    tasks.removeWhere((task) => task.id == id);
    await _saveTasks(tasks);
  }

  Future<void> _saveTasks(List<TaskModel> tasks) async {
    final jsonList = tasks.map((task) => task.toJson()).toList();
    await sharedPreferences.setString('tasks', json.encode(jsonList));
  }
}