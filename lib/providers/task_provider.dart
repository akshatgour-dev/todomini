import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_service.dart';
import '../constants/app_colors.dart';

class TaskProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  TaskStatus _currentFilter = TaskStatus.pending;
  String _searchQuery = '';
  String _categoryFilter = '';
  
  List<Task> get tasks => _tasks;
  List<Task> get filteredTasks => _filteredTasks;
  TaskStatus get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;
  String get categoryFilter => _categoryFilter;
  
  // Statistics
  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((task) => task.isCompleted).length;
  int get pendingTasks => _tasks.where((task) => !task.isCompleted).length;
  int get overdueTasks => _tasks.where((task) => task.isOverdue).length;
  int get dueTodayTasks => _tasks.where((task) => task.isDueToday).length;

  // Initialize provider
  Future<void> initialize() async {
    await loadTasks();
  }

  // Load all tasks from database
  Future<void> loadTasks() async {
    try {
      _tasks = await _databaseService.getAllTasks();
      _applyFilters();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }
  }

  // Add new task
  Future<void> addTask(Task task) async {
    try {
      final id = await _databaseService.insertTask(task);
      final newTask = task.copyWith(id: id);
      _tasks.insert(0, newTask);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding task: $e');
    }
  }

  // Update existing task
  Future<void> updateTask(Task task) async {
    try {
      await _databaseService.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating task: $e');
    }
  }

  // Delete task
  Future<void> deleteTask(int taskId) async {
    try {
      await _databaseService.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(
      status: task.isCompleted ? TaskStatus.pending : TaskStatus.completed,
      completedAt: task.isCompleted ? null : DateTime.now(),
    );
    await updateTask(updatedTask);
  }

  // Set filter
  void setFilter(TaskStatus status) {
    _currentFilter = status;
    _applyFilters();
    notifyListeners();
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Set category filter
  void setCategoryFilter(String category) {
    _categoryFilter = category;
    _applyFilters();
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _currentFilter = TaskStatus.pending;
    _searchQuery = '';
    _categoryFilter = '';
    _applyFilters();
    notifyListeners();
  }

  // Apply filters to tasks
  void _applyFilters() {
    _filteredTasks = _tasks.where((task) {
      // Status filter
      if (_currentFilter != TaskStatus.pending && task.status != _currentFilter) {
        return false;
      }
      
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final title = task.title.toLowerCase();
        final description = task.description?.toLowerCase() ?? '';
        if (!title.contains(query) && !description.contains(query)) {
          return false;
        }
      }
      
      // Category filter
      if (_categoryFilter.isNotEmpty && task.category != _categoryFilter) {
        return false;
      }
      
      return true;
    }).toList();
  }

  // Get tasks by category
  List<Task> getTasksByCategory(String category) {
    return _tasks.where((task) => task.category == category).toList();
  }

  // Get overdue tasks
  Future<List<Task>> getOverdueTasks() async {
    return await _databaseService.getOverdueTasks();
  }

  // Get tasks due today
  Future<List<Task>> getTasksDueToday() async {
    return await _databaseService.getTasksDueToday();
  }

  // Get tasks with reminders
  Future<List<Task>> getTasksWithReminders() async {
    return await _databaseService.getTasksWithReminders();
  }

  // Search tasks
  Future<List<Task>> searchTasks(String query) async {
    return await _databaseService.searchTasks(query);
  }

  // Get category statistics
  Map<String, int> getCategoryStats() {
    final stats = <String, int>{};
    for (final task in _tasks) {
      stats[task.category] = (stats[task.category] ?? 0) + 1;
    }
    return stats;
  }

  // Get priority statistics
  Map<TaskPriority, int> getPriorityStats() {
    final stats = <TaskPriority, int>{};
    for (final task in _tasks) {
      stats[task.priority] = (stats[task.priority] ?? 0) + 1;
    }
    return stats;
  }

  // Get color for category
  Color getCategoryColor(String category) {
    final categories = ['Personal', 'Work', 'Shopping', 'Health', 'Education', 'Finance', 'Travel', 'Other'];
    final index = categories.indexOf(category);
    if (index != -1 && index < AppColors.categoryColors.length) {
      return AppColors.categoryColors[index];
    }
    return AppColors.categoryColors.last;
  }

  // Get priority color
  Color getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return AppColors.highPriority;
      case TaskPriority.medium:
        return AppColors.mediumPriority;
      case TaskPriority.low:
        return AppColors.lowPriority;
    }
  }

  // Dispose
  @override
  void dispose() {
    _databaseService.close();
    super.dispose();
  }
} 