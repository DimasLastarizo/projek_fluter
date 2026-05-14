import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';
import '../widgets/transaction_card.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseService _db = DatabaseService();
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final transactions = await _db.getAllTransactions();
    setState(() {
      _transactions = transactions;
      _isLoading = false;
    });
  }

  // Kelompokkan transaksi berdasarkan tanggal
  Map<String, List<TransactionModel>> _groupByDate() {
    final Map<String, List<TransactionModel>> grouped = {};
    final dateFormatter = DateFormat('dd MMMM yyyy');
    for (final t in _transactions) {
      final key = dateFormatter.format(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }
    return grouped;
  }

  Future<bool> _confirmDelete(TransactionModel transaction) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.panelRadius),
          ),
          title: const Text(
            'Hapus transaksi?',
            style: TextStyle(
              color: AppTheme.warmCream,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Transaksi "${transaction.description}" akan dihapus dari riwayat dan saldo kamu akan ikut diperbarui.',
            style: const TextStyle(
              color: AppTheme.textMuted,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Batal',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Hapus',
                style: TextStyle(
                  color: AppTheme.expenseRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _deleteTransaction(TransactionModel transaction) async {
    setState(() {
      _transactions.removeWhere((item) => item.id == transaction.id);
    });

    await _db.deleteTransaction(transaction.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.cardDark,
        content: Text(
          'Transaksi "${transaction.description}" berhasil dihapus.',
          style: const TextStyle(color: AppTheme.warmCream),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDate();
    final keys = grouped.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.accentEmerald),
              )
            : _transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          color: AppTheme.textMuted.withValues(alpha: 0.5),
                          size: 56,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum ada transaksi',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: AppTheme.accentEmerald,
                    backgroundColor: AppTheme.cardDark,
                    onRefresh: _loadData,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                      itemCount: keys.length + 1,
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.cardDark,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.controlRadius),
                                border: Border.all(
                                  color:
                                      AppTheme.coolGrey.withValues(alpha: 0.35),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppTheme.shadow,
                                    blurRadius: 8,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.swipe_left_rounded,
                                    color: AppTheme.expenseRed,
                                    size: 18,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Geser transaksi ke kiri untuk menghapus input yang salah.',
                                      style: TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final dateKey = keys[i - 1];
                        final items = grouped[dateKey]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10, top: 6),
                              child: Text(
                                dateKey,
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                            ...items.map(
                              (t) => Dismissible(
                                key: ValueKey(t.id),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (_) => _confirmDelete(t),
                                onDismissed: (_) {
                                  _deleteTransaction(t);
                                },
                                background: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: AppTheme.expenseRed.withValues(alpha: 0.18),
                                    borderRadius:
                                        BorderRadius.circular(AppTheme.controlRadius),
                                    border: Border.all(
                                      color: AppTheme.expenseRed.withValues(alpha: 0.35),
                                    ),
                                  ),
                                  alignment: Alignment.centerRight,
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Icon(
                                        Icons.delete_outline_rounded,
                                        color: AppTheme.expenseRed,
                                        size: 22,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Hapus',
                                        style: TextStyle(
                                          color: AppTheme.expenseRed,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                child: TransactionCard(transaction: t),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
