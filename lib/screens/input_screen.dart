import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

class InputScreen extends StatefulWidget {
  final TransactionType? initialType;

  const InputScreen({super.key, this.initialType});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final DatabaseService _db = DatabaseService();
  bool _isLoading = false;
  late TransactionType _selectedType;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? TransactionType.expense;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final rawAmount = _amountController.text.replaceAll('.', '');
    final amount = double.tryParse(rawAmount);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid amount')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final transaction = TransactionModel(
      id: const Uuid().v4(),
      amount: amount,
      description: _descriptionController.text.trim(),
      type: _selectedType,
      date: DateTime.now(),
    );

    await _db.insertTransaction(transaction);

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _selectedType == TransactionType.income;
    final activeColor = isIncome ? AppTheme.incomeGreen : AppTheme.expenseRed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ScaleTransition(
          scale: _scaleAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type Toggle
                  const Text(
                    'Transaction Type',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.cardMedium,
                      borderRadius: BorderRadius.circular(AppTheme.controlRadius),
                      border: Border.all(
                        color: AppTheme.coolGrey.withValues(alpha: 0.35),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppTheme.shadow,
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _TypeToggle(
                            label: 'Income',
                            icon: Icons.arrow_downward_rounded,
                            isSelected: _selectedType == TransactionType.income,
                            activeColor: AppTheme.incomeGreen,
                            onTap: () => setState(
                                () => _selectedType = TransactionType.income),
                          ),
                        ),
                        Expanded(
                          child: _TypeToggle(
                            label: 'Expense',
                            icon: Icons.arrow_upward_rounded,
                            isSelected: _selectedType == TransactionType.expense,
                            activeColor: AppTheme.expenseRed,
                            onTap: () => setState(
                                () => _selectedType = TransactionType.expense),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Amount Display Card
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: activeColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppTheme.panelRadius),
                      border: Border.all(color: activeColor.withValues(alpha: 0.5)),
                      boxShadow: const [
                        BoxShadow(
                          color: AppTheme.shadow,
                          blurRadius: 14,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isIncome
                                  ? Icons.arrow_downward_rounded
                                  : Icons.arrow_upward_rounded,
                              color: activeColor,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isIncome ? 'Income Amount' : 'Expense Amount',
                              style: TextStyle(
                                color: activeColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Rp',
                              style: TextStyle(
                                color: activeColor.withValues(alpha: 0.6),
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  color: activeColor,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  _ThousandSeparatorFormatter(),
                                ],
                                decoration: const InputDecoration(
                                  hintText: '0',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  contentPadding: EdgeInsets.zero,
                                  hintStyle: TextStyle(
                                    color: AppTheme.inputHintGhost,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Amount cannot be empty';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description Field
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    style: const TextStyle(color: AppTheme.textLight, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: isIncome
                          ? 'e.g. Monthly salary, Transfer from parents...'
                          : 'e.g. Lunch, Gas, Electricity bill...',
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Description cannot be empty';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  // Quick tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _getQuickTags(isIncome).map((tag) {
                      return GestureDetector(
                        onTap: () {
                          _descriptionController.text = tag;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: activeColor.withValues(alpha: 0.08),
                            borderRadius:
                                BorderRadius.circular(AppTheme.controlRadius),
                            border:
                                Border.all(color: activeColor.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: activeColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 36),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: activeColor,
                        foregroundColor: AppTheme.primaryNavy,
                        disabledBackgroundColor: activeColor.withValues(alpha: 0.4),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primaryNavy,
                              ),
                            )
                          : Text(
                              isIncome ? 'Save Income' : 'Save Expense',
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<String> _getQuickTags(bool isIncome) {
    if (isIncome) {
      return ['Salary', 'Freelance', 'Transfer', 'Bonus', 'Sales', 'Other'];
    } else {
      return ['Food', 'Transport', 'Shopping', 'Bills', 'Entertainment', 'Health'];
    }
  }
}

class _TypeToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _TypeToggle({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.controlRadius),
          border: isSelected
              ? Border.all(color: activeColor.withValues(alpha: 0.4))
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : AppTheme.textMuted,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : AppTheme.textMuted,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThousandSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final raw = newValue.text.replaceAll('.', '');
    final number = int.tryParse(raw);
    if (number == null) return oldValue;
    final formatted = NumberFormat('#,###', 'id_ID').format(number);
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
