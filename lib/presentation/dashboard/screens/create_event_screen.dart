import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';
import 'package:syncsphere/data/models/event_model.dart';
import 'package:syncsphere/presentation/dashboard/providers/event_provider.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
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
                      hint: 'Number of guests',
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
                keyboardType: TextInputType.number,
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
                ],
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),
              const SizedBox(height: DesignTokens.spacingXL),
              SyncSphereButton(
                label: 'Create Event',
                onPressed: _createEvent,
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
        Text(
          'Date & Time',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: DesignTokens.textPrimary,
          ),
        ),
        const SizedBox(height: DesignTokens.spacingS),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(true),
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
                        'Start',
                        style: TextStyle(
                          fontSize: 12,
                          color: DesignTokens.textHint,
                        ),
                      ),
                      Text(
                        '${_startDate.month}/${_startDate.day}/${_startDate.year} ${_startTime.format(context)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: DesignTokens.spacingM),
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(false),
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
                        'End',
                        style: TextStyle(
                          fontSize: 12,
                          color: DesignTokens.textHint,
                        ),
                      ),
                      Text(
                        '${_endDate.month}/${_endDate.day}/${_endDate.year} ${_endTime.format(context)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
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

  Future<void> _createEvent() async {
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
    
    await context.read<EventProvider>().createEvent(event);
    
    setState(() => _isLoading = false);
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event created successfully!'),
          backgroundColor: DesignTokens.success,
        ),
      );
    }
  }
}