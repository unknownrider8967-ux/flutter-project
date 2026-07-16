import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';
import 'package:syncsphere/data/models/task_model.dart';
import 'package:syncsphere/presentation/task/providers/task_provider.dart';
import 'package:syncsphere/presentation/task/screens/add_edit_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  int _eventId = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks(_eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final tasks = taskProvider.tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddEditTaskScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(DesignTokens.spacingL),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      hintText: 'Filter by status',
                      border: OutlineInputBorder(),
                    ),
                    value: 'all',
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Tasks')),
                      DropdownMenuItem(value: 'todo', child: Text('To Do')),
                      DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                      DropdownMenuItem(value: 'review', child: Text('Review')),
                      DropdownMenuItem(value: 'done', child: Text('Done')),
                    ],
                    onChanged: (value) {
                      taskProvider.filterByStatus(value!);
                    },
                  ),
                ),
                const SizedBox(width: DesignTokens.spacingM),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      hintText: 'Filter by priority',
                      border: OutlineInputBorder(),
                    ),
                    value: 'all',
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Priorities')),
                      DropdownMenuItem(value: 'high', child: Text('High')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'low', child: Text('Low')),
                    ],
                    onChanged: (value) {
                      taskProvider.filterByPriority(value!);
                    },
                  ),
                ),
              ],
            ),
          ),
          if (taskProvider.isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (tasks.isEmpty)
            const Expanded(
              child: EmptyStateWidget(
                title: 'No Tasks Yet',
                subtitle: 'Create a task to get started with your event planning.',
                actionLabel: 'Add Task',
                icon: Icons.assignment_outlined,
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(DesignTokens.spacingL),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return _buildTaskCard(task);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return SyncSphereCard(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) {
                    final status = value! ? 'done' : 'todo';
                    context.read<TaskProvider>().updateTaskStatus(task.id!, status);
                  },
                  activeColor: DesignTokens.primaryColor,
                ),
                const SizedBox(width: DesignTokens.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (task.description.isNotEmpty)
                        Text(
                          task.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: DesignTokens.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacingS,
                    vertical: DesignTokens.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: task.priorityColor.withOpacity(0.1),
                    borderRadius: DesignTokens.radiusS,
                    border: Border.all(color: task.priorityColor),
                  ),
                  child: Text(
                    task.priorityLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: task.priorityColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: DesignTokens.spacingS),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditTaskScreen(task: task),
                        ),
                      );
                    } else if (value == 'delete') {
                      _showDeleteDialog(task.id!);
                    } else if (value.startsWith('status_')) {
                      final status = value.replaceFirst('status_', '');
                      context.read<TaskProvider>().updateTaskStatus(task.id!, status);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: DesignTokens.spacingS),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'status_todo',
                      child: Text('Move to To Do'),
                    ),
                    const PopupMenuItem(
                      value: 'status_in_progress',
                      child: Text('Move to In Progress'),
                    ),
                    const PopupMenuItem(
                      value: 'status_review',
                      child: Text('Move to Review'),
                    ),
                    const PopupMenuItem(
                      value: 'status_done',
                      child: Text('Mark Done'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 20, color: DesignTokens.error),
                          SizedBox(width: DesignTokens.spacingS),
                          Text('Delete', style: TextStyle(color: DesignTokens.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (task.assignedTo != null || task.dueDate != null)
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Row(
                  children: [
                    if (task.assignedTo != null) ...[
                      const Icon(
                        Icons.person_outline,
                        size: 14,
                        color: DesignTokens.textHint,
                      ),
                      const SizedBox(width: DesignTokens.spacingXS),
                      Text(
                        task.assignedTo!,
                        style: TextStyle(
                          fontSize: 12,
                          color: DesignTokens.textSecondary,
                        ),
                      ),
                    ],
                    if (task.assignedTo != null && task.dueDate != null)
                      const SizedBox(width: DesignTokens.spacingM),
                    if (task.dueDate != null) ...[
                      const Icon(
                        Icons.event_note_outlined,
                        size: 14,
                        color: DesignTokens.textHint,
                      ),
                      const SizedBox(width: DesignTokens.spacingXS),
                      Text(
                        'Due ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: DesignTokens.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(int id) {
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
              context.read<TaskProvider>().deleteTask(id);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: DesignTokens.error),
            ),
          ),
        ],
      ),
    );
  }
}