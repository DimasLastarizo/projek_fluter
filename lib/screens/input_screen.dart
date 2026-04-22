import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class InputScreen extends StatefulWidget {
  final bool isIncome;

  const InputScreen({super.key, required this.isIncome});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  late bool _isIncome;

  @override
  void initState() {
    super.initState();
    _isIncome = widget.isIncome;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _isIncome ? AppTheme.incomeGreen : AppTheme.expenseRed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _TypeToggle(
                        label: 'Expense',
                        icon: Icons.arrow_upward_rounded,
                        isSelected: !_isIncome,
                        activeColor: AppTheme.expenseRed,
                        onTap: () => setState(() => _isIncome = false),
                      ),
                    ),
                    Expanded(
                      child: _TypeToggle(
                        label: 'Income',
                        icon: Icons.arrow_downward_rounded,
                        isSelected: _isIncome,
                        activeColor: AppTheme.incomeGreen,
                        onTap: () => setState(() => _isIncome = true),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Amount Card
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: activeColor.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isIncome
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: activeColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isIncome ? 'Income Amount' : 'Expense Amount',
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
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: TextStyle(
                              color: activeColor,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            ),
                            decoration: const InputDecoration(
                              hintText: '0',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                              hintStyle: TextStyle(
                                color: Color(0x448BA5BC),
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Description
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
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                style: const TextStyle(color: AppTheme.textLight, fontSize: 15),
                decoration: InputDecoration(
                  hintText: _isIncome
                      ? 'e.g. Monthly salary, Transfer from parents...'
                      : 'e.g. Lunch, Gas, Electricity bill...',
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 12),

              // Quick tags
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (_isIncome
                        ? ['Salary', 'Freelance', 'Transfer', 'Bonus', 'Sales', 'Other']
                        : ['Food', 'Transport', 'Shopping', 'Bills', 'Entertainment', 'Health'])
                    .map((tag) => GestureDetector(
                          onTap: () => _descriptionController.text = tag,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: activeColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: activeColor.withValues(alpha: 0.2)),
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
                        ))
                    .toList(),
              ),

              const SizedBox(height: 36),

              // Save Button (static, just pops back)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeColor,
                    foregroundColor: AppTheme.primaryNavy,
                  ),
                  child: Text(_isIncome ? 'Save Income' : 'Save Expense'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
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
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
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
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
