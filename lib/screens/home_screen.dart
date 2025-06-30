import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../models/task.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../widgets/task_card.dart';
import '../widgets/stats_card.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        AppConstants.appName,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showSearchDialog(),
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => _showFilterDialog(),
        ),
        IconButton(
          icon: const Icon(Icons.brightness_6),
          onPressed: () => context.read<ThemeProvider>().toggleTheme(),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        if (taskProvider.tasks.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => taskProvider.loadTasks(),
          child: CustomScrollView(
            slivers: [
              _buildStatsSection(taskProvider),
              _buildTasksList(taskProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first task',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(TaskProvider taskProvider) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Total',
                value: taskProvider.totalTasks.toString(),
                icon: Icons.list_alt,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppConstants.smallPadding),
            Expanded(
              child: StatsCard(
                title: 'Completed',
                value: taskProvider.completedTasks.toString(),
                icon: Icons.check_circle,
                color: AppColors.lowPriority,
              ),
            ),
            const SizedBox(width: AppConstants.smallPadding),
            Expanded(
              child: StatsCard(
                title: 'Pending',
                value: taskProvider.pendingTasks.toString(),
                icon: Icons.pending,
                color: AppColors.mediumPriority,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList(TaskProvider taskProvider) {
    final tasks = taskProvider.filteredTasks;
    
    if (tasks.isEmpty && taskProvider.tasks.isNotEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 60,
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No tasks found',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your filters',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final task = tasks[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: AppConstants.mediumAnimation,
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: TaskCard(
                  task: task,
                  onTap: () => _editTask(task),
                  onToggle: () => taskProvider.toggleTaskCompletion(task),
                  onDelete: () => _deleteTask(task),
                ),
              ),
            ),
          );
        },
        childCount: tasks.length,
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _addNewTask(),
      icon: const Icon(Icons.add),
      label: const Text('Add Task'),
    );
  }

  void _addNewTask() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTaskScreen(),
      ),
    );
  }

  void _editTask(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(task: task),
      ),
    );
  }

  void _deleteTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskProvider>().deleteTask(task.id!);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => const SearchDialog(),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const FilterBottomSheet(),
    );
  }
}

class SearchDialog extends StatelessWidget {
  const SearchDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search tasks',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                context.read<TaskProvider>().setSearchQuery(value);
              },
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    context.read<TaskProvider>().setSearchQuery('');
                    Navigator.pop(context);
                  },
                  child: const Text('Clear'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Filter Tasks',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildStatusFilter(context),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildCategoryFilter(context),
          const SizedBox(height: AppConstants.defaultPadding),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<TaskProvider>().clearFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Wrap(
          spacing: AppConstants.smallPadding,
          children: TaskStatus.values.map((status) {
            return Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                final isSelected = taskProvider.currentFilter == status;
                return FilterChip(
                  label: Text(status.name.toUpperCase()),
                  selected: isSelected,
                  onSelected: (selected) {
                    taskProvider.setFilter(selected ? status : TaskStatus.pending);
                  },
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Wrap(
          spacing: AppConstants.smallPadding,
          children: AppConstants.taskCategories.map((category) {
            return Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                final isSelected = taskProvider.categoryFilter == category;
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    taskProvider.setCategoryFilter(selected ? category : '');
                  },
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }
} 