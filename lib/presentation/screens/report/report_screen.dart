import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../core/constants/expense_categories.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../blocs/expense/expense_cubit.dart';
import '../../../domain/entities/expense_entity.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  Future<void> _exportSummary(List<ExpenseEntity> expenses) async {
    final totalExpense = expenses.fold<double>(0, (s, e) => s + e.amount);
    final monthName = DateFormat('MMMM yyyy', 'vi').format(DateTime(_selectedYear, _selectedMonth));

    final buffer = StringBuffer();
    buffer.writeln('Báo cáo chi tiêu PicFi — $monthName');
    buffer.writeln('Tổng chi: ${CurrencyFormatter.format(totalExpense)}');
    buffer.writeln('');

    final categoryStats = <String, double>{};
    for (final e in expenses) {
      categoryStats[e.category] = (categoryStats[e.category] ?? 0) + e.amount;
    }
    final sorted = categoryStats.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sorted) {
      final cat = ExpenseCategory.values.firstWhere(
        (c) => c.name == entry.key,
        orElse: () => ExpenseCategory.other,
      );
      buffer.writeln('${cat.label}: ${CurrencyFormatter.format(entry.value)}');
    }

    buffer.writeln('');
    buffer.writeln('Tạo bởi PicFi — ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/BaoCaoPicFi_$_selectedMonth$_selectedYear.txt');
    await file.writeAsString(buffer.toString());
    await Share.shareXFiles([XFile(file.path)], text: 'Báo cáo chi tiêu PicFi');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0FBF9), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white,
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                      ),
                    ),
                    const Spacer(),
                    const Text('Xuất báo cáo', style: TextStyle(
                      fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800,
                    )),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Month/Year picker
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _MonthYearPicker(
                        month: _selectedMonth,
                        year: _selectedYear,
                        onChanged: (month, year) => setState(() {
                          _selectedMonth = month;
                          _selectedYear = year;
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Preview
              Expanded(
                child: BlocBuilder<ExpenseCubit, ExpenseState>(
                  builder: (context, state) {
                    final expenses = state.expenses.where((e) =>
                        e.date.month == _selectedMonth &&
                        e.date.year == _selectedYear).toList();

                    final totalExpense = expenses.fold<double>(0, (s, e) => s + e.amount);

                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _SummaryCard(label: 'Tổng chi', value: totalExpense, color: const Color(0xFFFF6B6B)),
                        const SizedBox(height: 20),

                        const Text('Giao dịch trong tháng', style: TextStyle(
                          fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w700,
                        )),
                        const SizedBox(height: 8),
                        if (expenses.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                children: [
                                  Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 8),
                                  Text('Chưa có giao dịch nào', style: TextStyle(
                                    fontFamily: 'Inter', fontSize: 14, color: Colors.grey.shade500,
                                  )),
                                ],
                              ),
                            ),
                          )
                        else
                          ...expenses.take(10).map((e) => _TransactionRow(expense: e)),
                        if (expenses.length > 10)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text('...và ${expenses.length - 10} giao dịch khác', textAlign: TextAlign.center,
                                style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.grey.shade500)),
                          ),
                      ],
                    );
                  },
                ),
              ),

              // Export buttons
              Container(
                padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).padding.bottom + 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: BlocBuilder<ExpenseCubit, ExpenseState>(
                  builder: (context, state) {
                    final expenses = state.expenses.where((e) =>
                        e.date.month == _selectedMonth &&
                        e.date.year == _selectedYear).toList();

                    if (expenses.isEmpty) {
                      return Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(child: Text('Không có dữ liệu', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700, color: Colors.grey))),
                      );
                    }

                    return SizedBox(
                      width: double.infinity,
                      child: _exportButton(
                        icon: Icons.share_rounded,
                        label: 'Xuất báo cáo',
                        onTap: () => _exportSummary(expenses),
                        isLoading: false,
                      ),
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

class _SummaryCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _SummaryCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: color.withValues(alpha: 0.7))),
                const SizedBox(height: 4),
                Text(CurrencyFormatter.format(value), style: TextStyle(fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final dynamic expense;

  const _TransactionRow({required this.expense});

  @override
  Widget build(BuildContext context) {
    final cat = ExpenseCategory.values.firstWhere(
      (c) => c.name == expense.category,
      orElse: () => ExpenseCategory.other,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cat.color.withValues(alpha: 0.1),
            ),
            child: Icon(cat.icon, size: 18, color: cat.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.note ?? cat.label, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600)),
                Text('${expense.date.day}/${expense.date.month}', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Text('-${CurrencyFormatter.format(expense.amount)}', style: const TextStyle(fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFFF6B6B))),
        ],
      ),
    );
  }
}

class _MonthYearPicker extends StatelessWidget {
  final int month;
  final int year;
  final Function(int month, int year) onChanged;

  const _MonthYearPicker({required this.month, required this.year, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Previous month
        IconButton(
          onPressed: () {
            if (month == 1) {
              onChanged(12, year - 1);
            } else {
              onChanged(month - 1, year);
            }
          },
          icon: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
            child: const Icon(Icons.chevron_left_rounded),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)]),
            child: Center(
              child: Text(
                'Tháng $month / $year',
                style: const TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: () {
            if (month == 12) {
              onChanged(1, year + 1);
            } else {
              onChanged(month + 1, year);
            }
          },
          icon: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
            child: const Icon(Icons.chevron_right_rounded),
          ),
        ),
      ],
    );
  }
}

Widget _exportButton({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  required bool isLoading,
}) {
  return GestureDetector(
    onTap: isLoading ? null : onTap,
    child: Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF006A65), Color(0xFF4ECDC4)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0xFF006A65).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: isLoading
          ? const SizedBox(
              width: 22, height: 22,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
              ],
            ),
    ),
  );
}
