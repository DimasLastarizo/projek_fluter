import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final double totalIncome;
  final double totalExpense;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final isPositive = balance >= 0;
    final statusColor = isPositive ? AppTheme.incomeGreen : AppTheme.expenseRed;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.cardGradientStart, AppTheme.cardDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.panelRadius),
        border: Border.all(
          color: AppTheme.coolGrey.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadow,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 5,
            child: DecoratedBox(decoration: BoxDecoration(color: statusColor)),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentEmerald.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(AppTheme.controlRadius),
                        border: Border.all(
                          color: AppTheme.accentEmerald.withValues(alpha: 0.45),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_rounded,
                            color: AppTheme.accentEmerald,
                            size: 14,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'SALDO SAAT INI',
                            style: TextStyle(
                              color: AppTheme.accentEmerald,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  formatter.format(balance.abs()),
                  style: TextStyle(
                    color: isPositive ? AppTheme.warmCream : AppTheme.expenseRed,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                if (!isPositive)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Saldo minus',
                      style: TextStyle(
                        color: AppTheme.expenseRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                const Divider(color: AppTheme.divider, height: 1),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryItem(
                        label: 'Income',
                        amount: formatter.format(totalIncome),
                        color: AppTheme.incomeGreen,
                        icon: Icons.arrow_downward_rounded,
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppTheme.divider),
                    Expanded(
                      child: _SummaryItem(
                        label: 'Expense',
                        amount: formatter.format(totalExpense),
                        color: AppTheme.expenseRed,
                        icon: Icons.arrow_upward_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
