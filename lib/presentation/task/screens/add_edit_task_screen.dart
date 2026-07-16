import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';
import 'package:syncsphere/data/models/task_model.dart';
import 'package:syncsphere/presentation/task/providers/task_provider.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;
  
  const AddEditTaskScreen({super.key, this.task});

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

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _priority = widget.task!.priority;
      _status = widget.task!.status;
      _assignedToController.text = widget.task!.assignedTo ?? '';
      _dueDate = widget.task!.dueDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
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
                onChanged: (value) {
                  setState(() {
                    _priority = value!;
                  });
                },
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
                  DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                  DropdownMenuItem(value: 'review', child: Text('Review')),
                  DropdownMenuItem(value: 'done', child: Text('Done')),
                ],
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _dueDate != null
                            ? 'Due: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                            : 'Select Due Date',
                        style: TextStyle(
                          color: _dueDate != null
                              ? DesignTokens.textPrimary
                              : DesignTokens.textHint,
                        ),
                      ),
                      Icon(
                        Icons.calendar_today_outlined,
                        color: DesignTokens.textHint,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.spacingXL),
              SyncSphereButton(
                label: widget.task == null ? 'Add Task' : 'Update Task',
                onPressed: _saveTask,
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
    
    if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }

  void _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    
    final task = Task(
      id: widget.task?.id,
      eventId: 1,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priority: _priority,
      status: _status,
      assignedTo: _assignedToController.text.trim().isEmpty
          ? null
          : _assignedToController.text.trim(),
      dueDate: _dueDate,
    );
    
    if (widget.task == null) {
      await context.read<TaskProvider>().addTask(task);
    } else {
      await context.read<TaskProvider>().updateTask(task);
    }
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.task == null ? 'Task added!' : 'Task updated!'),
          backgroundColor: DesignTokens.success,
        ),
      );
    }
  }
}