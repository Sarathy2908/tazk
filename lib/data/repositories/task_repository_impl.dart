import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Task>> getTasks() async {
    final taskModels = await localDataSource.getTasks();
    return taskModels;
  }

  @override
  Future<void> addTask(Task task) async {
    final taskModel = TaskModel.fromTask(task);
    await localDataSource.addTask(taskModel);
  }

  @override
  Future<void> updateTask(Task task) async {
    final taskModel = TaskModel.fromTask(task);
    await localDataSource.updateTask(taskModel);
  }

  @override
  Future<void> deleteTask(String id) async {
    await localDataSource.deleteTask(id);
  }
}