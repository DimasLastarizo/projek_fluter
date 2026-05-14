import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final DatabaseService _db = DatabaseService();
  static const String _allTimePeriodId = 'all_time';
  final DateFormat _monthChipFormatter = DateFormat('MMM');
  final NumberFormat _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final NumberFormat _compactCurrency = NumberFormat.compactCurrency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 1,
  );
  final NumberFormat _netCompactCurrency = NumberFormat.compactCurrency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 1,
  );

  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  late String _selectedPeriodId;

  @override
  void initState() {
    super.initState();
    _selectedPeriodId = _periodIdForMonth(_monthStart(DateTime.now()));
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final transactions = await _db.getAllTransactions();
    if (!mounted) return;
    setState(() {
      _transactions = transactions;
      _isLoading = false;
    });
  }

  DateTime _monthStart(DateTime date) => DateTime(date.year, date.month);

  String _periodIdForMonth(DateTime month) {
    final year = month.year.toString();
    final paddedMonth = month.month.toString().padLeft(2, '0');
    return '$year-$paddedMonth';
  }

  String _formatMonthLabel(DateTime month) {
    return DateFormat('MMM yyyy').format(month);
  }

  List<_PeriodOption> _buildPeriodOptions() {
    final months = <DateTime>{_monthStart(DateTime.now())};

    for (final transaction in _transactions) {
      months.add(_monthStart(transaction.date));
    }

    final sortedMonths = months.toList()..sort((a, b) => b.compareTo(a));

    return [
      const _PeriodOption(
        id: _allTimePeriodId,
        label: 'All time',
      ),
      ...sortedMonths.map(
        (month) => _PeriodOption(
          id: _periodIdForMonth(month),
          label: _formatMonthLabel(month),
          month: month,
        ),
      ),
    ];
  }

  List<_MonthlyStat> _buildMonthlyStats() {
    final now = DateTime.now();
    final stats = <_MonthlyStat>[];

    for (var offset = 6; offset >= 0; offset--) {
      final month = DateTime(now.year, now.month - offset, 1);
      var income = 0.0;
      var expense = 0.0;

      for (final transaction in _transactions) {
        final sameMonth = transaction.date.year == month.year &&
            transaction.date.month == month.month;
        if (!sameMonth) continue;

        if (transaction.type == TransactionType.income) {
          income += transaction.amount;
        } else {
          expense += transaction.amount;
        }
      }

      stats.add(
        _MonthlyStat(
          month: month,
          income: income,
          expense: expense,
        ),
      );
    }

    return stats;
  }

  String _resolveSelectedPeriodId(List<_PeriodOption> options) {
    for (final option in options) {
      if (option.id == _selectedPeriodId) {
        return _selectedPeriodId;
      }
    }

    return _periodIdForMonth(_monthStart(DateTime.now()));
  }

  DateTime? _selectedMonth(List<_PeriodOption> options, String selectedPeriodId) {
    for (final option in options) {
      if (option.id == selectedPeriodId) {
        return option.month;
      }
    }

    return _monthStart(DateTime.now());
  }

  String _selectedPeriodLabel(
    List<_PeriodOption> options,
    String selectedPeriodId,
  ) {
    for (final option in options) {
      if (option.id == selectedPeriodId) {
        return option.label;
      }
    }

    return _formatMonthLabel(_monthStart(DateTime.now()));
  }

  List<TransactionModel> _filteredTransactions(DateTime? selectedMonth) {
    if (selectedMonth == null) {
      return _transactions;
    }

    return _transactions
        .where(
          (t) =>
              t.date.year == selectedMonth.year &&
              t.date.month == selectedMonth.month,
        )
        .toList();
  }

  _OverviewMetrics _buildOverviewMetrics(List<TransactionModel> transactions) {
    final income = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final expense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final net = income - expense;
    final flow = income + expense;
    final spendingRate = income == 0 ? 0.0 : expense / income;

    return _OverviewMetrics(
      income: income,
      expense: expense,
      net: net,
      transactionCount: transactions.length,
      cashFlow: flow,
      spendingRate: spendingRate,
    );
  }

  String _formatCompact(double value) {
    if (value == 0) return 'Rp 0';
    return _compactCurrency.format(value);
  }

  String _formatSignedCompact(double value) {
    if (value == 0) return 'Rp 0';

    final prefix = value > 0 ? '+' : '-';
    return '$prefix${_formatCompact(value.abs())}';
  }

  String _buildInsightText(_OverviewMetrics metrics, String periodLabel) {
    if (metrics.transactionCount == 0) {
      return 'Belum ada transaksi pada $periodLabel. Mulai catat pemasukan dan pengeluaran supaya pola keuanganmu bisa terbaca.';
    }

    if (metrics.net > 0) {
      return '$periodLabel masih surplus ${_currency.format(metrics.net)}. Pengeluaranmu ada di ${(metrics.spendingRate * 100).toStringAsFixed(0)}% dari total pemasukan pada periode ini.';
    }

    if (metrics.net < 0) {
      return '$periodLabel sedang defisit ${_currency.format(metrics.net.abs())}. Artinya pengeluaran lebih besar daripada pemasukan pada periode ini.';
    }

    return '$periodLabel sedang seimbang. Total pemasukan dan pengeluaran pada periode ini nilainya sama.';
  }

  @override
  Widget build(BuildContext context) {
    final monthlyStats = _buildMonthlyStats();
    final periodOptions = _buildPeriodOptions();
    final resolvedSelectedPeriodId = _resolveSelectedPeriodId(periodOptions);
    final selectedMonth = _selectedMonth(
      periodOptions,
      resolvedSelectedPeriodId,
    );
    final selectedPeriodLabel = _selectedPeriodLabel(
      periodOptions,
      resolvedSelectedPeriodId,
    );
    final filteredTransactions = _filteredTransactions(selectedMonth);
    final metrics = _buildOverviewMetrics(filteredTransactions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryNavy, AppTheme.backgroundGradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.accentEmerald,
                  ),
                )
              : RefreshIndicator(
                  color: AppTheme.accentEmerald,
                  backgroundColor: AppTheme.cardDark,
                  onRefresh: _loadStatistics,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                          'Financial insights',
                          style: TextStyle(
                            color: AppTheme.warmCream,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pantau pola pemasukan dan pengeluaranmu dari transaksi yang sudah kamu simpan.',
                          style: TextStyle(
                            color: AppTheme.textMuted.withValues(alpha: 0.9),
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 18),
                          _StatsCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Monthly cash flow',
                                style: TextStyle(
                                  color: AppTheme.warmCream,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                '7 bulan terakhir',
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Row(
                                children: [
                                  _LegendChip(
                                    label: 'Income',
                                    color: AppTheme.incomeGreen,
                                  ),
                                  SizedBox(width: 10),
                                  _LegendChip(
                                    label: 'Expense',
                                    color: AppTheme.expenseRed,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              RepaintBoundary(
                                child: _MonthlyBarChart(
                                  stats: monthlyStats,
                                  compactCurrency: _compactCurrency,
                                  monthChipFormatter: _monthChipFormatter,
                                  selectedMonth: selectedMonth,
                                  onSelectMonth: (month) {
                                    setState(() {
                                      _selectedPeriodId =
                                          _periodIdForMonth(month);
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Tap bulan pada grafik untuk melihat rincian di kartu bawah.',
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                          _StatsCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Detailed breakdown',
                                      style: TextStyle(
                                        color: AppTheme.warmCream,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  _PeriodDropdown(
                                    options: periodOptions,
                                    value: resolvedSelectedPeriodId,
                                    onChanged: (value) {
                                      if (value == null) return;
                                      setState(() {
                                        _selectedPeriodId = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                filteredTransactions.isEmpty
                                    ? 'Belum ada transaksi pada $selectedPeriodLabel.'
                                    : '${metrics.transactionCount} transaksi tercatat pada $selectedPeriodLabel.',
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: RepaintBoundary(
                                  child: _RingOverviewChart(
                                    metrics: metrics,
                                    compactCurrency: _netCompactCurrency,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: _MetricTile(
                                      label: 'Income',
                                      value: _formatCompact(metrics.income),
                                      color: AppTheme.incomeGreen,
                                      icon: Icons.arrow_downward_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _MetricTile(
                                      label: 'Expense',
                                      value: _formatCompact(metrics.expense),
                                      color: AppTheme.expenseRed,
                                      icon: Icons.arrow_upward_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _MetricTile(
                                      label: 'Net result',
                                      value: _formatSignedCompact(metrics.net),
                                      color: metrics.net >= 0
                                          ? AppTheme.incomeGreen
                                          : AppTheme.expenseRed,
                                      icon: metrics.net >= 0
                                          ? Icons.trending_up_rounded
                                          : Icons.trending_down_rounded,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryNavy.withValues(alpha: 0.5),
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.controlRadius),
                                  border: Border.all(
                                    color: AppTheme.divider.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Quick insight',
                                      style: TextStyle(
                                        color: AppTheme.warmCream,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _buildInsightText(
                                        metrics,
                                        selectedPeriodLabel,
                                      ),
                                      style: const TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 12,
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _MonthlyStat {
  const _MonthlyStat({
    required this.month,
    required this.income,
    required this.expense,
  });

  final DateTime month;
  final double income;
  final double expense;
}

class _OverviewMetrics {
  const _OverviewMetrics({
    required this.income,
    required this.expense,
    required this.net,
    required this.transactionCount,
    required this.cashFlow,
    required this.spendingRate,
  });

  final double income;
  final double expense;
  final double net;
  final int transactionCount;
  final double cashFlow;
  final double spendingRate;
}

class _PeriodOption {
  const _PeriodOption({
    required this.id,
    required this.label,
    this.month,
  });

  final String id;
  final String label;
  final DateTime? month;
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
        boxShadow: [
          const BoxShadow(
            color: AppTheme.shadow,
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppTheme.controlRadius),
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.65)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.warmCream,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyBarChart extends StatelessWidget {
  const _MonthlyBarChart({
    required this.stats,
    required this.compactCurrency,
    required this.monthChipFormatter,
    required this.selectedMonth,
    required this.onSelectMonth,
  });

  final List<_MonthlyStat> stats;
  final NumberFormat compactCurrency;
  final DateFormat monthChipFormatter;
  final DateTime? selectedMonth;
  final ValueChanged<DateTime> onSelectMonth;

  @override
  Widget build(BuildContext context) {
    final maxValue = stats.fold<double>(
      0,
      (max, stat) => math.max(max, math.max(stat.income, stat.expense)),
    );
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;

    return SizedBox(
      height: 240,
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final chartHeight = constraints.maxHeight;
                final itemCount = stats.isEmpty ? 1 : stats.length;
                final slotWidth = constraints.maxWidth / itemCount;
                final safeSlotWidth = math.max(slotWidth - 2.0, 22.0);
                final outerPadding =
                    (safeSlotWidth * 0.06).clamp(0.5, 3.0).toDouble();
                final innerPadding =
                    (safeSlotWidth * 0.04).clamp(0.5, 3.0).toDouble();
                final barGap =
                    (safeSlotWidth * 0.08).clamp(2.0, 4.0).toDouble();
                final barWidth = ((safeSlotWidth -
                            (outerPadding * 2) -
                            (innerPadding * 2) -
                            barGap) /
                        2)
                    .clamp(5.0, 12.0)
                    .toDouble();

                return Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              4,
                              (index) => Container(
                                height: 1,
                                color: AppTheme.divider.withValues(alpha: 0.35),
                              ),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: stats.map((stat) {
                              final isSelected = selectedMonth != null &&
                                  selectedMonth!.year == stat.month.year &&
                                  selectedMonth!.month == stat.month.month;

                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: outerPadding,
                                  ),
                                  child: GestureDetector(
                                    onTap: () => onSelectMonth(stat.month),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: innerPadding,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppTheme.primaryNavy
                                                .withValues(alpha: 0.45)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(
                                          AppTheme.controlRadius,
                                        ),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppTheme.accentEmerald
                                                  .withValues(alpha: 0.45)
                                              : Colors.transparent,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                _BarSegment(
                                                  value: stat.income,
                                                  maxValue: safeMax,
                                                  chartHeight: chartHeight,
                                                  color: AppTheme.incomeGreen,
                                                  width: barWidth,
                                                ),
                                                SizedBox(width: barGap),
                                                _BarSegment(
                                                  value: stat.expense,
                                                  maxValue: safeMax,
                                                  chartHeight: chartHeight,
                                                  color: AppTheme.expenseRed,
                                                  width: barWidth,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            monthChipFormatter.format(
                                              stat.month,
                                            ),
                                            style: TextStyle(
                                              color: isSelected
                                                  ? AppTheme.warmCream
                                                  : AppTheme.textMuted,
                                              fontSize: 12,
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Puncak grafik: ${compactCurrency.format(maxValue)}',
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarSegment extends StatelessWidget {
  const _BarSegment({
    required this.value,
    required this.maxValue,
    required this.chartHeight,
    required this.color,
    required this.width,
  });

  final double value;
  final double maxValue;
  final double chartHeight;
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    final normalized = value <= 0 ? 0.04 : (value / maxValue).clamp(0.04, 1.0);
    final height = normalized * math.max(chartHeight - 34, 80);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: value <= 0 ? 0.15 : 0.95),
        borderRadius: BorderRadius.circular(AppTheme.controlRadius),
        boxShadow: value <= 0
            ? null
            : [
                BoxShadow(
                  color: color.withValues(alpha: 0.12),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
    );
  }
}

class _PeriodDropdown extends StatelessWidget {
  const _PeriodDropdown({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<_PeriodOption> options;
  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppTheme.controlRadius),
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.6)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(AppTheme.controlRadius),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppTheme.textMuted,
          ),
          style: const TextStyle(
            color: AppTheme.warmCream,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option.id,
              child: Text(option.label),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _RingOverviewChart extends StatelessWidget {
  const _RingOverviewChart({
    required this.metrics,
    required this.compactCurrency,
  });

  final _OverviewMetrics metrics;
  final NumberFormat compactCurrency;

  @override
  Widget build(BuildContext context) {
    final ringValues = [
      metrics.income,
      metrics.expense,
      metrics.net.abs(),
    ];
    final maxValue = ringValues.fold<double>(0, math.max);
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(220),
            painter: _RingChartPainter(
              rings: [
                _RingData(
                  progress: metrics.income / safeMax,
                  color: AppTheme.incomeGreen,
                ),
                _RingData(
                  progress: metrics.expense / safeMax,
                  color: AppTheme.expenseRed,
                ),
                _RingData(
                  progress: metrics.net.abs() / safeMax,
                  color: metrics.net >= 0
                      ? AppTheme.warmCream
                      : AppTheme.textMuted,
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Income - expense',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                metrics.net >= 0
                    ? '+${compactCurrency.format(metrics.net)}'
                    : '-${compactCurrency.format(metrics.net.abs())}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: metrics.net >= 0
                      ? AppTheme.incomeGreen
                      : AppTheme.expenseRed,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingData {
  const _RingData({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;
}

class _RingChartPainter extends CustomPainter {
  const _RingChartPainter({
    required this.rings,
  });

  final List<_RingData> rings;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    const strokeWidth = 6.0;
    const gap = 16.0;
    final radii = [84.0, 68.0, 52.0];

    for (var i = 0; i < rings.length; i++) {
      final ring = rings[i];
      final radius = radii[i];
      final rect = Rect.fromCircle(center: center, radius: radius);

      final trackPaint = Paint()
        ..color = AppTheme.divider.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final progressPaint = Paint()
        ..color = ring.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, trackPaint);

      final progress = ring.progress.clamp(0.0, 1.0);
      final sweep = math.max(progress * (math.pi * 2 - gap / radius), 0.0);
      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweep,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingChartPainter oldDelegate) {
    if (oldDelegate.rings.length != rings.length) {
      return true;
    }

    for (var i = 0; i < rings.length; i++) {
      final oldRing = oldDelegate.rings[i];
      final ring = rings[i];

      if (oldRing.progress != ring.progress || oldRing.color != ring.color) {
        return true;
      }
    }

    return false;
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppTheme.controlRadius),
        border: Border.all(
          color: AppTheme.divider.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.warmCream,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
