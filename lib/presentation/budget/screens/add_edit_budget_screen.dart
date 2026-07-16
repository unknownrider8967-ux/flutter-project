import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';
import 'package:syncsphere/data/models/budget_model.dart';
import 'package:syncsphere/presentation/budget/providers/budget_provider.dart';

class AddEditBudgetScreen extends StatefulWidget {
  final BudgetEntry? entry;
  final int eventId;

  const AddEditBudgetScreen({super.key, this.entry, required this.eventId});

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
  bool _isLoading = false;

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final e = widget.entry!;
      _categoryController.text = e.category;
      _descriptionController.text = e.description;
      _amountController.text = e.amount.toStringAsFixed(2);
      _isIncome = e.isIncome;
      _date = e.date;
      _paidByController.text = e.paidBy ?? '';
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _paidByController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Entry' : 'Add Budget Entry'),
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
              // Income / Expense toggle
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isIncome = false),
                      child: Container(
                        padding: const EdgeInsets.all(DesignTokens.spacingM),
                        decoration: BoxDecoration(
                          color: !_isIncome
                              ? DesignTokens.error.withOpacity(0.1)
                              : DesignTokens.surfaceVariant,
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(12)),
                          border: Border.all(
                            color: !_isIncome
                                ? DesignTokens.error
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_upward,
                                color: !_isIncome
                                    ? DesignTokens.error
                                    : DesignTokens.textHint,
                                size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Expense',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: !_isIncome
                                    ? DesignTokens.error
                                    : DesignTokens.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isIncome = true),
                      child: Container(
                        padding: const EdgeInsets.all(DesignTokens.spacingM),
                        decoration: BoxDecoration(
                          color: _isIncome
                              ? DesignTokens.success.withOpacity(0.1)
                              : DesignTokens.surfaceVariant,
                          borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(12)),
                          border: Border.all(
                            color: _isIncome
                                ? DesignTokens.success
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_downward,
                                color: _isIncome
                                    ? DesignTokens.success
                                    : DesignTokens.textHint,
                                size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Income',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _isIncome
                                    ? DesignTokens.success
                                    : DesignTokens.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spacingL),
              SyncSphereInputField(
                label: 'Category',
                hint: 'e.g., Venue, Catering, Marketing',
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
                hint: 'Brief description of the entry',
                controller: _descriptionController,
                maxLines: 2,
              ),
              const SizedBox(height: DesignTokens.spacingM),
              SyncSphereInputField(
                label: 'Amount (\$)',
                hint: '0.00',
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Amount is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: DesignTokens.spacingM),
              SyncSphereInputField(
                label: 'Paid By',
                hint: 'Who paid for this? (optional)',
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
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: DesignTokens.textHint, size: 20),
                      const SizedBox(width: DesignTokens.spacingM),
                      Text(
                        'Date: ${_date.day}/${_date.month}/${_date.year}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right,
                          color: DesignTokens.textHint),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.spacingXL),
              SyncSphereButton(
                label: _isEditing ? 'Update Entry' : 'Add Entry',
                onPressed: _saveEntry,
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
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _date = date);
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final entry = BudgetEntry(
      id: widget.entry?.id,
      eventId: widget.eventId,
      category: _categoryController.text.trim(),
      description: _descriptionController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      isIncome: _isIncome,
      date: _date,
      paidBy: _paidByController.text.trim().isEmpty
          ? null
          : _paidByController.text.trim(),
    );

    if (_isEditing) {
      await context.read<BudgetProvider>().updateBudgetEntry(entry);
    } else {
      await context.read<BudgetProvider>().addBudgetEntry(entry);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Entry updated!' : 'Entry added!'),
          backgroundColor: DesignTokens.success,
        ),
      );
    }
  }
}
