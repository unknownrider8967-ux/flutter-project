import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';
import 'package:syncsphere/data/models/task_model.dart';
import 'package:syncsphere/presentation/task/providers/task_provider.dart';
import 'package:syncsphere/presentation/task/screens/add_edit_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  final int eventId;

  const TaskListScreen({super.key, required this.eventId});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks(widget.eventId);
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
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddEditTaskScreen(eventId: widget.eventId),
                ),
              );
              if (context.mounted) {
                context.read<TaskProvider>().loadTasks(widget.eventId);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                DesignTokens.spacingL,
                DesignTokens.spacingS,
                DesignTokens.spacingL,
                DesignTokens.spacingS),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      hintText: 'Status',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    value: 'all',
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(value: 'todo', child: Text('To Do')),
                      DropdownMenuItem(
                          value: 'in_progress', child: Text('In Progress')),
                      DropdownMenuItem(value: 'review', child: Text('Review')),
                      DropdownMenuItem(value: 'done', child: Text('Done')),
                    ],
                    onChanged: (value) =>
                        taskProvider.filterByStatus(value!),
                  ),
                ),
                const SizedBox(width: DesignTokens.spacingM),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      hintText: 'Priority',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    value: 'all',
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(value: 'high', child: Text('High')),
                      DropdownMenuItem(
                          value: 'medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'low', child: Text('Low')),
                    ],
                    onChanged: (value) =>
                        taskProvider.filterByPriority(value!),
                  ),
                ),
              ],
            ),
          ),
          if (tasks.isNotEmpty) _buildProgressBar(tasks),
          if (taskProvider.isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (tasks.isEmpty)
            Expanded(
              child: EmptyStateWidget(
                title: 'No Tasks Yet',
                subtitle:
                    'Create a task to start organizing your event work.',
                actionLabel: 'Add Task',
                icon: Icons.assignment_outlined,
                onActionPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddEditTaskScreen(eventId: widget.eventId),
                    ),
                  ).then((_) {
                    if (!context.mounted) return;
                    context.read<TaskProvider>().loadTasks(widget.eventId);
                  });
                },
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(DesignTokens.spacingL),
                itemCount: tasks.length,
                itemBuilder: (context, index) =>
                    _buildTaskCard(tasks[index]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(List<Task> tasks) {
    final done = tasks.where((t) => t.isCompleted).length;
    final progress = tasks.isEmpty ? 0.0 : done / tasks.length;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingXS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$done / ${tasks.length} completed',
                style: const TextStyle(
                    fontSize: 12, color: DesignTokens.textSecondary),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingXS),
          ClipRRect(
            borderRadius: DesignTokens.radiusXL,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: DesignTokens.surfaceVariant,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(DesignTokens.primaryColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return SyncSphereCard(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: task.isCompleted,
                onChanged: (value) {
                  final status = value! ? 'done' : 'todo';
                  context
                      .read<TaskProvider>()
                      .updateTaskStatus(task.id!, status);
                },
                activeColor: DesignTokens.primaryColor,
              ),
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
                        color: task.isCompleted
                            ? DesignTokens.textHint
                            : null,
                      ),
                    ),
                    if (task.description.isNotEmpty)
                      Text(
                        task.description,
                        style: const TextStyle(
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
                  color: task.priorityColor.withValues(alpha: 0.1),
                  borderRadius: DesignTokens.radiusS,
                  border: Border.all(color: task.priorityColor),
                ),
                child: Text(
                  task.priorityLabel,
                  style: TextStyle(
                    fontSize: 9,
                    color: task.priorityColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.spacingXS),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (value) {
                  if (value == 'edit') {
                    final taskProvider = context.read<TaskProvider>();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditTaskScreen(
                            task: task, eventId: widget.eventId),
                      ),
                    ).then((_) {
                      if (!context.mounted) return;
                      taskProvider.loadTasks(widget.eventId);
                    });
                  } else if (value == 'delete') {
                    _showDeleteDialog(task.id!);
                  } else if (value.startsWith('status_')) {
                    final status = value.replaceFirst('status_', '');
                    context
                        .read<TaskProvider>()
                        .updateTaskStatus(task.id!, status);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ]),
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
                    child: Row(children: [
                      Icon(Icons.delete_outline,
                          size: 18, color: DesignTokens.error),
                      SizedBox(width: 8),
                      Text('Delete',
                          style: TextStyle(color: DesignTokens.error)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
          if (task.assignedTo != null || task.dueDate != null)
            Padding(
              padding: const EdgeInsets.only(
                  left: 48, bottom: DesignTokens.spacingXS),
              child: Row(
                children: [
                  if (task.assignedTo != null) ...[
                    const Icon(Icons.person_outline,
                        size: 12, color: DesignTokens.textHint),
                    const SizedBox(width: 4),
                    Text(
                      task.assignedTo!,
                      style: const TextStyle(
                          fontSize: 11,
                          color: DesignTokens.textSecondary),
                    ),
                  ],
                  if (task.assignedTo != null && task.dueDate != null)
                    const SizedBox(width: DesignTokens.spacingM),
                  if (task.dueDate != null) ...[
                    const Icon(Icons.schedule_outlined,
                        size: 12, color: DesignTokens.textHint),
                    const SizedBox(width: 4),
                    Text(
                      'Due ${DateFormat('MMM d').format(task.dueDate!)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: task.dueDate!.isBefore(DateTime.now()) &&
                                !task.isCompleted
                            ? DesignTokens.error
                            : DesignTokens.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
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
            child: const Text('Delete',
                style: TextStyle(color: DesignTokens.error)),
          ),
        ],
      ),
    );
  }
}
