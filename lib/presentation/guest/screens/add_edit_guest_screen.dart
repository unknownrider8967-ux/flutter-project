import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';
import 'package:syncsphere/data/models/guest_model.dart';
import 'package:syncsphere/presentation/guest/providers/guest_provider.dart';

class AddEditGuestScreen extends StatefulWidget {
  final Guest? guest;
  final int eventId;

  const AddEditGuestScreen({
    super.key,
    this.guest,
    required this.eventId,
  });

  @override
  State<AddEditGuestScreen> createState() => _AddEditGuestScreenState();
}

class _AddEditGuestScreenState extends State<AddEditGuestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dietaryController = TextEditingController();
  final _notesController = TextEditingController();

  String _rsvpStatus = 'pending';
  bool _isPlusOne = false;
  bool _isLoading = false;

  bool get _isEditing => widget.guest != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final g = widget.guest!;
      _nameController.text = g.name;
      _emailController.text = g.email;
      _phoneController.text = g.phone;
      _rsvpStatus = g.rsvpStatus;
      _isPlusOne = g.isPlusOne;
      _dietaryController.text = g.dietaryRestrictions ?? '';
      _notesController.text = g.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dietaryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Guest' : 'Add Guest'),
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
                label: 'Full Name',
                hint: 'Enter guest name',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: DesignTokens.spacingM),
              SyncSphereInputField(
                label: 'Email',
                hint: 'Enter email address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: DesignTokens.spacingM),
              SyncSphereInputField(
                label: 'Phone',
                hint: 'Enter phone number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: DesignTokens.spacingM),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'RSVP Status',
                  border: OutlineInputBorder(),
                ),
                value: _rsvpStatus,
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(
                      value: 'confirmed', child: Text('Confirmed')),
                  DropdownMenuItem(value: 'maybe', child: Text('Maybe')),
                  DropdownMenuItem(value: 'declined', child: Text('Declined')),
                ],
                onChanged: (value) {
                  setState(() => _rsvpStatus = value!);
                },
              ),
              const SizedBox(height: DesignTokens.spacingM),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Brings a +1'),
                subtitle: const Text('Allow guest to bring a plus one'),
                value: _isPlusOne,
                onChanged: (value) {
                  setState(() => _isPlusOne = value);
                },
                activeColor: DesignTokens.primaryColor,
              ),
              const SizedBox(height: DesignTokens.spacingS),
              SyncSphereInputField(
                label: 'Dietary Restrictions',
                hint: 'e.g., Vegetarian, Gluten-free',
                controller: _dietaryController,
              ),
              const SizedBox(height: DesignTokens.spacingM),
              SyncSphereInputField(
                label: 'Notes',
                hint: 'Additional notes about this guest',
                controller: _notesController,
                maxLines: 3,
              ),
              const SizedBox(height: DesignTokens.spacingXL),
              SyncSphereButton(
                label: _isEditing ? 'Update Guest' : 'Add Guest',
                onPressed: _saveGuest,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveGuest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final guest = Guest(
      id: widget.guest?.id,
      eventId: widget.eventId,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      rsvpStatus: _rsvpStatus,
      isPlusOne: _isPlusOne,
      dietaryRestrictions: _dietaryController.text.trim().isEmpty
          ? null
          : _dietaryController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (_isEditing) {
      await context.read<GuestProvider>().updateGuest(guest);
    } else {
      await context.read<GuestProvider>().addGuest(guest);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(_isEditing ? 'Guest updated!' : 'Guest added!'),
          backgroundColor: DesignTokens.success,
        ),
      );
    }
  }
}
