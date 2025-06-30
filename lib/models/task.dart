import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high }
enum TaskStatus { pending, completed, archived }

class Task {
  final int? id;
  final String title;
  final String? description;
  final String category;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime? reminderTime;
  final Color categoryColor;
  final bool hasReminder;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.category,
    required this.priority,
    this.status = TaskStatus.pending,
    DateTime? createdAt,
    this.dueDate,
    this.completedAt,
    this.reminderTime,
    required this.categoryColor,
    this.hasReminder = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? dueDate,
    DateTime? completedAt,
    DateTime? reminderTime,
    Color? categoryColor,
    bool? hasReminder,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      reminderTime: reminderTime ?? this.reminderTime,
      categoryColor: categoryColor ?? this.categoryColor,
      hasReminder: hasReminder ?? this.hasReminder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority.index,
      'status': status.index,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'reminderTime': reminderTime?.millisecondsSinceEpoch,
      'categoryColor': categoryColor.value,
      'hasReminder': hasReminder ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      priority: TaskPriority.values[map['priority']],
      status: TaskStatus.values[map['status']],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      dueDate: map['dueDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
          : null,
      completedAt: map['completedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'])
          : null,
      reminderTime: map['reminderTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['reminderTime'])
          : null,
      categoryColor: Color(map['categoryColor']),
      hasReminder: map['hasReminder'] == 1,
    );
  }

  bool get isCompleted => status == TaskStatus.completed;
  bool get isOverdue => dueDate != null && dueDate!.isBefore(DateTime.now()) && !isCompleted;
  bool get isDueToday => dueDate != null && 
      dueDate!.year == DateTime.now().year &&
      dueDate!.month == DateTime.now().month &&
      dueDate!.day == DateTime.now().day;

  @override
  String toString() {
    return 'Task(id: $id, title: $title, category: $category, priority: $priority, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 