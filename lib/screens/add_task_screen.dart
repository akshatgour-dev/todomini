import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;
  const AddTaskScreen({super.key, this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String _category = AppConstants.taskCategories.first;
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  bool _hasReminder = false;
  DateTime? _reminderTime;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _category = task?.category ?? AppConstants.taskCategories.first;
    _priority = task?.priority ?? TaskPriority.medium;
    _dueDate = task?.dueDate;
    _hasReminder = task?.hasReminder ?? false;
    _reminderTime = task?.reminderTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    final taskProvider = context.read<TaskProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'Add Task'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                taskProvider.deleteTask(widget.task!.id!);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                ),
                maxLength: AppConstants.maxTaskTitleLength,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
                maxLength: AppConstants.maxTaskDescriptionLength,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: AppConstants.taskCategories
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: taskProvider.getCategoryColor(cat),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Text(cat),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _category = val!),
                    ),
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  Expanded(
                    child: DropdownButtonFormField<TaskPriority>(
                      value: _priority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        prefixIcon: Icon(Icons.flag),
                      ),
                      items: TaskPriority.values
                          .map((priority) => DropdownMenuItem(
                                value: priority,
                                child: Text(_priorityLabel(priority)),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _priority = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: Text(_dueDate == null
                          ? 'No due date'
                          : 'Due: ${DateFormat.yMMMd().format(_dueDate!)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_calendar),
                        onPressed: _pickDueDate,
                      ),
                    ),
                  ),
                  if (_dueDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _dueDate = null),
                    ),
                ],
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              SwitchListTile.adaptive(
                value: _hasReminder,
                onChanged: (val) => setState(() => _hasReminder = val),
                title: const Text('Set Reminder'),
                secondary: const Icon(Icons.alarm),
              ),
              if (_hasReminder)
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.alarm),
                        title: Text(_reminderTime == null
                            ? 'No reminder time'
                            : 'Remind at: ${DateFormat.yMMMd().add_jm().format(_reminderTime!)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: _pickReminderTime,
                        ),
                      ),
                    ),
                    if (_reminderTime != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _reminderTime = null),
                      ),
                  ],
                ),
              const SizedBox(height: AppConstants.largePadding),
              ElevatedButton.icon(
                icon: Icon(isEditing ? Icons.save : Icons.add),
                label: Text(isEditing ? 'Save Changes' : 'Add Task'),
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _pickReminderTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _reminderTime ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (pickedDate == null) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderTime ?? now),
    );
    if (pickedTime == null) return;
    setState(() {
      _reminderTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;
    final taskProvider = context.read<TaskProvider>();
    final color = taskProvider.getCategoryColor(_category);
    final newTask = Task(
      id: widget.task?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      category: _category,
      priority: _priority,
      status: widget.task?.status ?? TaskStatus.pending,
      createdAt: widget.task?.createdAt,
      dueDate: _dueDate,
      completedAt: widget.task?.completedAt,
      reminderTime: _hasReminder ? _reminderTime : null,
      categoryColor: color,
      hasReminder: _hasReminder,
    );
    if (widget.task == null) {
      taskProvider.addTask(newTask);
    } else {
      taskProvider.updateTask(newTask);
    }
    Navigator.pop(context);
  }
} 