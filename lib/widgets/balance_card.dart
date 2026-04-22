import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.cardMedium, AppTheme.cardDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.accentEmerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.account_balance_wallet_rounded,
                        color: AppTheme.accentEmerald, size: 14),
                    SizedBox(width: 5),
                    Text(
                      'CURRENT BALANCE',
                      style: TextStyle(
                        color: AppTheme.accentEmerald,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Rp 0',
            style: TextStyle(
              color: AppTheme.warmCream,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: AppTheme.divider, height: 1),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'Income',
                  amount: 'Rp 0',
                  color: AppTheme.incomeGreen,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
              SizedBox(width: 1, height: 40),
              Expanded(
                child: _SummaryItem(
                  label: 'Expense',
                  amount: 'Rp 0',
                  color: AppTheme.expenseRed,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final IconData icon;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
