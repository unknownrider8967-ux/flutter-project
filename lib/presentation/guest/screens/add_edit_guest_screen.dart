import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';
import 'package:syncsphere/data/models/guest_model.dart';
import 'package:syncsphere/presentation/guest/providers/guest_provider.dart';

class AddEditGuestScreen extends StatefulWidget {
  final Guest? guest;
  
  const AddEditGuestScreen({super.key, this.guest});

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

  @override
  void initState() {
    super.initState();
    if (widget.guest != null) {
      _nameController.text = widget.guest!.name;
      _emailController.text = widget.guest!.email;
      _phoneController.text = widget.guest!.phone;
      _rsvpStatus = widget.guest!.rsvpStatus;
      _isPlusOne = widget.guest!.isPlusOne;
      _dietaryController.text = widget.guest!.dietaryRestrictions ?? '';
      _notesController.text = widget.guest!.notes ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.guest == null ? 'Add Guest' : 'Edit Guest'),
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
                  DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                  DropdownMenuItem(value: 'maybe', child: Text('Maybe')),
                  DropdownMenuItem(value: 'declined', child: Text('Declined')),
                ],
                onChanged: (value) {
                  setState(() {
                    _rsvpStatus = value!;
                  });
                },
              ),
              const SizedBox(height: DesignTokens.spacingM),
              SwitchListTile(
                title: const Text('Plus One'),
                subtitle: const Text('Allow guest to bring a plus one'),
                value: _isPlusOne,
                onChanged: (value) {
                  setState(() {
                    _isPlusOne = value;
                  });
                },
                activeColor: DesignTokens.primaryColor,
              ),
              const SizedBox(height: DesignTokens.spacingM),
              SyncSphereInputField(
                label: 'Dietary Restrictions',
                hint: 'Any dietary requirements?',
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
                label: widget.guest == null ? 'Add Guest' : 'Update Guest',
                onPressed: _saveGuest,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveGuest() async {
    if (!_formKey.currentState!.validate()) return;
    
    final guest = Guest(
      id: widget.guest?.id,
      eventId: 1,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      rsvpStatus: _rsvpStatus,
      isPlusOne: _isPlusOne,
      dietaryRestrictions: _dietaryController.text.trim(),
      notes: _notesController.text.trim(),
    );
    
    if (widget.guest == null) {
      await context.read<GuestProvider>().addGuest(guest);
    } else {
      await context.read<GuestProvider>().updateGuest(guest);
    }
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.guest == null ? 'Guest added!' : 'Guest updated!'),
          backgroundColor: DesignTokens.success,
        ),
      );
    }
  }
}