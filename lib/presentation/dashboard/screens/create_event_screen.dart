import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';
import 'package:syncsphere/data/models/event_model.dart';
import 'package:syncsphere/presentation/dashboard/providers/event_provider.dart';

class CreateEventScreen extends StatefulWidget {
  /// If [event] is provided the screen operates in edit mode.
  final Event? event;

  const CreateEventScreen({super.key, this.event});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _categoryController = TextEditingController();
  final _maxGuestsController = TextEditingController();
  final _budgetController = TextEditingController();

  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  DateTime _endDate = DateTime.now().add(const Duration(days: 8));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);

  bool _isLoading = false;
  String _status = 'draft';

  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final e = widget.event!;
      _nameController.text = e.name;
      _descriptionController.text = e.description;
      _locationController.text = e.location;
      _categoryController.text = e.category;
      _maxGuestsController.text = e.maxGuests?.toString() ?? '';
      _budgetController.text = e.budget?.toString() ?? '';
      _startDate = e.startDate;
      _endDate = e.endDate;
      _startTime = TimeOfDay(hour: e.startDate.hour, minute: e.startDate.minute);
      _endTime = TimeOfDay(hour: e.endDate.hour, minute: e.endDate.minute);
      _status = e.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    _maxGuestsController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Event' : 'Create Event'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.spacingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SyncSphereInputField(
                label: 'Event Name',
                hint: 'Enter event name',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Event name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: DesignTokens.spacingM),
              SyncSphereInputField(
                label: 'Description',
                hint: 'Describe your event',
                controller: _descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: DesignTokens.spacingM),
              SyncSphereInputField(
                label: 'Location',
                hint: 'Enter venue location',
                controller: _locationController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Location is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: DesignTokens.spacingM),
              _buildDateTimePicker(),
              const SizedBox(height: DesignTokens.spacingM),
              Row(
                children: [
                  Expanded(
                    child: SyncSphereInputField(
                      label: 'Category',
                      hint: 'e.g., Conference',
                      controller: _categoryController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Category is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spacingM),
                  Expanded(
                    child: SyncSphereInputField(
                      label: 'Max Guests',
                      hint: 'Number',
                      controller: _maxGuestsController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spacingM),
              SyncSphereInputField(
                label: 'Budget (\$)',
                hint: 'Total event budget',
                controller: _budgetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: DesignTokens.spacingM),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                value: _status,
                items: const [
                  DropdownMenuItem(value: 'draft', child: Text('Draft')),
                  DropdownMenuItem(value: 'published', child: Text('Published')),
                  DropdownMenuItem(value: 'ongoing', child: Text('Ongoing')),
                  DropdownMenuItem(value: 'completed', child: Text('Completed')),
                ],
                onChanged: (value) {
                  setState(() => _status = value!);
                },
              ),
              const SizedBox(height: DesignTokens.spacingXL),
              SyncSphereButton(
                label: _isEditing ? 'Update Event' : 'Create Event',
                onPressed: _saveEvent,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date & Time',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: DesignTokens.spacingS),
        Row(
          children: [
            Expanded(child: _dateTile(true)),
            const SizedBox(width: DesignTokens.spacingM),
            Expanded(child: _dateTile(false)),
          ],
        ),
      ],
    );
  }

  Widget _dateTile(bool isStart) {
    final date = isStart ? _startDate : _endDate;
    final time = isStart ? _startTime : _endTime;
    return InkWell(
      onTap: () => _selectDate(isStart),
      borderRadius: DesignTokens.radiusM,
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spacingM),
        decoration: BoxDecoration(
          color: DesignTokens.surfaceVariant,
          borderRadius: DesignTokens.radiusM,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isStart ? 'Start' : 'End',
              style: const TextStyle(
                  fontSize: 11, color: DesignTokens.textHint),
            ),
            const SizedBox(height: 2),
            Text(
              '${date.month}/${date.day}/${date.year}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              time.format(context),
              style: const TextStyle(
                  fontSize: 12, color: DesignTokens.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: isStart ? _startTime : _endTime,
      );

      if (time != null) {
        setState(() {
          if (isStart) {
            _startDate = date;
            _startTime = time;
          } else {
            _endDate = date;
            _endTime = time;
          }
        });
      }
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    final provider = context.read<EventProvider>();

    if (_isEditing) {
      final updated = widget.event!.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        startDate: startDateTime,
        endDate: endDateTime,
        location: _locationController.text.trim(),
        category: _categoryController.text.trim(),
        status: _status,
        maxGuests: int.tryParse(_maxGuestsController.text.trim()),
        budget: double.tryParse(_budgetController.text.trim()),
        updatedAt: DateTime.now(),
      );
      await provider.updateEvent(updated);
    } else {
      final event = Event(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        startDate: startDateTime,
        endDate: endDateTime,
        location: _locationController.text.trim(),
        category: _categoryController.text.trim(),
        status: _status,
        maxGuests: int.tryParse(_maxGuestsController.text.trim()),
        budget: double.tryParse(_budgetController.text.trim()),
      );
      await provider.createEvent(event);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(_isEditing ? 'Event updated!' : 'Event created!'),
          backgroundColor: DesignTokens.success,
        ),
      );
    }
  }
}
