import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';
import 'package:syncsphere/data/models/task_model.dart';
import 'package:syncsphere/presentation/task/providers/task_provider.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;
  final int eventId;

  const AddEditTaskScreen({super.key, this.task, required this.eventId});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _assignedToController = TextEditingController();

  String _priority = 'medium';
  String _status = 'todo';
  DateTime? _dueDate;
  bool _isLoading = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.task!;
      _titleController.text = t.title;
      _descriptionController.text = t.description;
      _priority = t.priority;
      _status = t.status;
      _assignedToController.text = t.assignedTo ?? '';
      _dueDate = t.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assignedToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Add Task'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.spacingL),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SyncSphereInputField(
                label: 'Task Title',
                hint: 'Enter task title',
                controller: _titleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: DesignTokens.spacingM),
              SyncSphereInputField(
                label: 'Description',
                hint: 'Describe the task',
                controller: _descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: DesignTokens.spacingM),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                value: _priority,
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                ],
                onChanged: (value) => setState(() => _priority = value!),
              ),
              const SizedBox(height: DesignTokens.spacingM),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                value: _status,
                items: const [
                  DropdownMenuItem(value: 'todo', child: Text('To Do')),
                  DropdownMenuItem(
                      value: 'in_progress', child: Text('In Progress')),
                  DropdownMenuItem(value: 'review', child: Text('Review')),
                  DropdownMenuItem(value: 'done', child: Text('Done')),
                ],
                onChanged: (value) => setState(() => _status = value!),
              ),
              const SizedBox(height: DesignTokens.spacingM),
              SyncSphereInputField(
                label: 'Assigned To',
                hint: 'Enter assignee name',
                controller: _assignedToController,
              ),
              const SizedBox(height: DesignTokens.spacingM),
              InkWell(
                onTap: _selectDate,
                borderRadius: DesignTokens.radiusM,
                child: Container(
                  padding: const EdgeInsets.all(DesignTokens.spacingM),
                  decoration: BoxDecoration(
                    color: DesignTokens.surfaceVariant,
                    borderRadius: DesignTokens.radiusM,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: DesignTokens.textHint, size: 20),
                      const SizedBox(width: DesignTokens.spacingM),
                      Text(
                        _dueDate != null
                            ? 'Due: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                            : 'Select Due Date (optional)',
                        style: TextStyle(
                          color: _dueDate != null
                              ? DesignTokens.textPrimary
                              : DesignTokens.textHint,
                        ),
                      ),
                      const Spacer(),
                      if (_dueDate != null)
                        GestureDetector(
                          onTap: () => setState(() => _dueDate = null),
                          child: const Icon(Icons.close,
                              size: 18, color: DesignTokens.textHint),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.spacingXL),
              SyncSphereButton(
                label: _isEditing ? 'Update Task' : 'Add Task',
                onPressed: _saveTask,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _dueDate = date);
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final task = Task(
      id: widget.task?.id,
      eventId: widget.eventId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priority: _priority,
      status: _status,
      assignedTo: _assignedToController.text.trim().isEmpty
          ? null
          : _assignedToController.text.trim(),
      dueDate: _dueDate,
    );

    if (_isEditing) {
      await context.read<TaskProvider>().updateTask(task);
    } else {
      await context.read<TaskProvider>().addTask(task);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Task updated!' : 'Task added!'),
          backgroundColor: DesignTokens.success,
        ),
      );
    }
  }
}
