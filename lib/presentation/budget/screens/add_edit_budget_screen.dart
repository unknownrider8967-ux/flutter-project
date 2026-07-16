import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';
import 'package:syncsphere/data/models/budget_model.dart';
import 'package:syncsphere/presentation/budget/providers/budget_provider.dart';

class AddEditBudgetScreen extends StatefulWidget {
  final BudgetEntry? entry;
  
  const AddEditBudgetScreen({super.key, this.entry});

  @override
  State<AddEditBudgetScreen> createState() => _AddEditBudgetScreenState();
}

class _AddEditBudgetScreenState extends State<AddEditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _paidByController = TextEditingController();
  
  bool _isIncome = false;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _categoryController.text = widget.entry!.category;
      _descriptionController.text = widget.entry!.description;
      _amountController.text = widget.entry!.amount.toString();
      _isIncome = widget.entry!.isIncome;
      _date = widget.entry!.date;
      _paidByController.text = widget.entry!.paidBy ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'Add Budget Entry' : 'Edit Budget Entry'),
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
                label: 'Category',
                hint: 'e.g., Venue, Catering',
                controller: _categoryController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Category is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: DesignTokens.spacingM),
              SyncSphereInputField(
                label: 'Description',
                hint: 'Describe the expense/income',
                controller: _descriptionController,
              ),
              const SizedBox(height: DesignTokens.spacingM),
              SyncSphereInputField(
                label: 'Amount',
                hint: 'Enter amount',
                controller: _amountController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Amount is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: DesignTokens.spacingM),
              SwitchListTile(
                title: const Text('Income'),
                subtitle: const Text('Toggle to switch between income and expense'),
                value: _isIncome,
                onChanged: (value) {
                  setState(() {
                    _isIncome = value;
                  });
                },
                activeColor: DesignTokens.success,
              ),
              const SizedBox(height: DesignTokens.spacingM),
              SyncSphereInputField(
                label: 'Paid By',
                hint: 'Who paid for this?',
                controller: _paidByController,
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
                        'Date: ${_date.day}/${_date.month}/${_date.year}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
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
                label: widget.entry == null ? 'Add Entry' : 'Update Entry',
                onPressed: _saveEntry,
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
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _date = date;
      });
    }
  }

  void _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;
    
    final entry = BudgetEntry(
      id: widget.entry?.id,
      eventId: 1,
      category: _categoryController.text.trim(),
      description: _descriptionController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      isIncome: _isIncome,
      date: _date,
      paidBy: _paidByController.text.trim().isEmpty
          ? null
          : _paidByController.text.trim(),
    );
    
    if (widget.entry == null) {
      await context.read<BudgetProvider>().addBudgetEntry(entry);
    } else {
      await context.read<BudgetProvider>().updateBudgetEntry(entry);
    }
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.entry == null ? 'Entry added!' : 'Entry updated!'),
          backgroundColor: DesignTokens.success,
        ),
      );
    }
  }
}