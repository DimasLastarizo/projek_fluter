import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_card.dart';
import '../theme/app_theme.dart';
import 'input_screen.dart';
import 'history_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _db = DatabaseService();
  List<TransactionModel> _transactions = [];
  double _balance = 0;
  double _totalIncome = 0;
  double _totalExpense = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final transactions = await _db.getAllTransactions();
    final balance = await _db.getTotalBalance();
    final income = await _db.getTotalIncome();
    final expense = await _db.getTotalExpense();
    setState(() {
      _transactions = transactions;
      _balance = balance;
      _totalIncome = income;
      _totalExpense = expense;
      _isLoading = false;
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Good Morning';
    if (hour < 15) return 'Good Afternoon';
    if (hour < 18) return 'Good Evening';
    return 'Good Night';
  }

  void _goToHistory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    );
    _loadData();
  }

  void _goToStatistics() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StatisticsScreen()),
    );
  }

  void _navigateToInput(TransactionType type) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => InputScreen(initialType: type)),
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.accentEmerald),
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'HELLO D :)',
                              style: TextStyle(
                                color: AppTheme.warmCream,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Track your money like your own life.',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: _goToHistory,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.cardDark,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.divider),
                            ),
                            child: const Icon(
                              Icons.history_rounded,
                              color: AppTheme.textMuted,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    BalanceCard(
                      balance: _balance,
                      totalIncome: _totalIncome,
                      totalExpense: _totalExpense,
                    ),
                    const SizedBox(height: 14),
                    // Quick Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            label: 'Income',
                            icon: Icons.add_rounded,
                            color: AppTheme.incomeGreen,
                            onTap: () => _navigateToInput(TransactionType.income),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            label: 'Expense',
                            icon: Icons.remove_rounded,
                            color: AppTheme.expenseRed,
                            onTap: () => _navigateToInput(TransactionType.expense),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Section title + tombol statistik
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Tracking',
                          style: TextStyle(
                            color: AppTheme.warmCream,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        GestureDetector(
                          onTap: _goToStatistics,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.cardDark,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.divider),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.bar_chart_rounded, color: AppTheme.textMuted, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Statistics',
                                  style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Transaction list — fills remaining screen space
                    Expanded(
                      child: _transactions.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    color: AppTheme.textMuted.withValues(alpha: 0.5),
                                    size: 48,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No transactions yet',
                                    style: TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Start recording your income\nor expenses',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                const cardHeight = 82.0;
                                final maxFit = (constraints.maxHeight / cardHeight).floor();
                                final showCount = maxFit.clamp(1, _transactions.length);
                                final previewList = _transactions.take(showCount).toList();

                                return Column(
                                  children: previewList
                                      .map((t) => TransactionCard(transaction: t))
                                      .toList(),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}