import '../entities/task.dart';
import '../repositories/task_repository.dart';

class ToggleTask {
  final TaskRepository repository;

  ToggleTask(this.repository);

  Future<void> call(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    return repository.updateTask(updatedTask);
  }
}