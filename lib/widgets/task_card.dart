import 'package:flutter/material.dart';
import '../models/task.dart';
import '../constants/app_colors.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => onToggle?.call(),
          activeColor: AppColors.primary,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: task.categoryColor,
                shape: BoxShape.circle,
              ),
            ),
            Text(
              task.category,
              style: TextStyle(
                color: task.categoryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.flag,
              size: 16,
              color: _priorityColor(task.priority),
            ),
            Text(
              ' ${_priorityLabel(task.priority)}',
              style: TextStyle(
                color: _priorityColor(task.priority),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (task.dueDate != null) ...[
              const SizedBox(width: 12),
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Theme.of(context).colorScheme.outline,
              ),
              Text(
                ' ${_formatDate(task.dueDate!)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ],
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline),
                color: AppColors.error,
                onPressed: onDelete,
              )
            : null,
      ),
    );
  }

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return AppColors.highPriority;
      case TaskPriority.medium:
        return AppColors.mediumPriority;
      case TaskPriority.low:
        return AppColors.lowPriority;
    }
  }

  String _priorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 