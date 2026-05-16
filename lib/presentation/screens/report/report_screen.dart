import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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
  bool _isGeneratingPdf = false;

  String _generateCsv(List<ExpenseEntity> expenses, List<ExpenseEntity> incomes) {
    final rows = <List<String>>[
      ['Ngày', 'Danh mục', 'Loại', 'Ghi chú', 'Số tiền'],
    ];
    for (final e in [...expenses, ...incomes]) {
      final cat = ExpenseCategory.values.firstWhere(
        (c) => c.name == e.category,
        orElse: () => ExpenseCategory.other,
      );
      rows.add([
        DateFormat('dd/MM/yyyy').format(e.date),
        cat.label,
        e.type == TransactionType.income ? 'Thu nhập' : 'Chi tiêu',
        e.note ?? '-',
        '${e.type == TransactionType.income ? '+' : '-'}${CurrencyFormatter.format(e.amount)}',
      ]);
    }
    return const ListToCsvConverter().convert(rows);
  }

  Future<File> _generateExcel(List<ExpenseEntity> expenses, List<ExpenseEntity> incomes) async {
    final excel = Excel.createExcel();
    final sheet = excel['Báo cáo'];

    sheet.appendRow([
      TextCellValue('Ngày'),
      TextCellValue('Danh mục'),
      TextCellValue('Loại'),
      TextCellValue('Ghi chú'),
      TextCellValue('Số tiền'),
    ]);
    for (final e in [...expenses, ...incomes]) {
      final cat = ExpenseCategory.values.firstWhere(
        (c) => c.name == e.category,
        orElse: () => ExpenseCategory.other,
      );
      sheet.appendRow([
        TextCellValue(DateFormat('dd/MM/yyyy').format(e.date)),
        TextCellValue(cat.label),
        TextCellValue(e.type == TransactionType.income ? 'Thu nhập' : 'Chi tiêu'),
        TextCellValue(e.note ?? '-'),
        TextCellValue('${e.type == TransactionType.income ? '+' : '-'}${CurrencyFormatter.format(e.amount)}'),
      ]);
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/BaoCaoPicFi_$_selectedMonth$_selectedYear.xlsx');
    await file.writeAsBytes(excel.save()!);
    return file;
  }

  Future<void> _exportCsv(List<ExpenseEntity> expenses, List<ExpenseEntity> incomes) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isGeneratingPdf = true);
    await HapticFeedback.lightImpact();
    try {
      final csv = _generateCsv(expenses, incomes);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/BaoCaoPicFi_$_selectedMonth$_selectedYear.csv');
      await file.writeAsString(csv);
      await Share.shareXFiles([XFile(file.path)]);
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('Lỗi xuất CSV: $e', style: const TextStyle(fontFamily: 'Inter')),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  Future<void> _exportExcel(List<ExpenseEntity> expenses, List<ExpenseEntity> incomes) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isGeneratingPdf = true);
    await HapticFeedback.lightImpact();
    try {
      final file = await _generateExcel(expenses, incomes);
      await Share.shareXFiles([XFile(file.path)]);
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('Lỗi xuất Excel: $e', style: const TextStyle(fontFamily: 'Inter')),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  Future<pw.Document> _generatePdf(List<ExpenseEntity> expenses, List<ExpenseEntity> incomes) async {
    final pdf = pw.Document();

    final totalIncome = incomes.fold<double>(0, (s, e) => s + e.amount);
    final totalExpense = expenses.fold<double>(0, (s, e) => s + e.amount);
    final balance = totalIncome - totalExpense;
    final monthName = DateFormat('MMMM yyyy', 'vi').format(DateTime(_selectedYear, _selectedMonth));

    final categoryStats = <String, double>{};
    for (final e in expenses) {
      categoryStats[e.category] = (categoryStats[e.category] ?? 0) + e.amount;
    }
    final sortedCategories = categoryStats.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Center(
          child: pw.Text(
            'Báo cáo chi tiêu PicFi — $monthName',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#006A65')),
          ),
        ),
        footer: (context) => pw.Center(
          child: pw.Text(
            'Tạo bởi PicFi — ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
          ),
        ),
        build: (context) => [
          // Tổng quan
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F0FBF9'),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _pdfStatBox('Tổng thu', totalIncome, PdfColor.fromHex('#4ECDC4')),
                _pdfStatBox('Tổng chi', totalExpense, PdfColor.fromHex('#FF6B6B')),
                _pdfStatBox('Số dư', balance, balance >= 0 ? PdfColor.fromHex('#006A65') : PdfColor.fromHex('#FF6B6B')),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Biểu đồ danh mục
          pw.Text('Chi tiêu theo danh mục', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          ...sortedCategories.map((entry) {
            final cat = ExpenseCategory.values.firstWhere(
              (c) => c.name == entry.key,
              orElse: () => ExpenseCategory.other,
            );
            final pct = totalExpense > 0 ? (entry.value / totalExpense * 100).toStringAsFixed(1) : '0';
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 12, height: 12,
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromInt(cat.color.toARGB32()),
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(cat.label, style: const pw.TextStyle(fontSize: 11)),
                  pw.Spacer(),
                  pw.Text('$pct%', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                  pw.SizedBox(width: 8),
                  pw.Text(CurrencyFormatter.format(entry.value), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            );
          }),
          pw.SizedBox(height: 16),

          // Chi tiết giao dịch
          pw.Text('Chi tiết giao dịch', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#006A65')),
            headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerHeight: 25,
            cellHeight: 22,
            headers: ['Ngày', 'Danh mục', 'Ghi chú', 'Số tiền'],
            data: expenses.map((e) {
              final cat = ExpenseCategory.values.firstWhere(
                (c) => c.name == e.category,
                orElse: () => ExpenseCategory.other,
              );
              return [
                DateFormat('dd/MM').format(e.date),
                cat.label,
                e.note ?? '-',
                '-${CurrencyFormatter.format(e.amount)}',
              ];
            }).toList(),
          ),
          if (incomes.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Text('Chi tiết thu nhập', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#4ECDC4')),
              headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerHeight: 25,
              cellHeight: 22,
              headers: ['Ngày', 'Danh mục', 'Ghi chú', 'Số tiền'],
              data: incomes.map((e) {
                final cat = ExpenseCategory.values.firstWhere(
                  (c) => c.name == e.category,
                  orElse: () => ExpenseCategory.other,
                );
                return [
                  DateFormat('dd/MM').format(e.date),
                  cat.label,
                  e.note ?? '-',
                  '+${CurrencyFormatter.format(e.amount)}',
                ];
              }).toList(),
            ),
          ],
        ],
      ),
    );

    return pdf;
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

  pw.Widget _pdfStatBox(String label, double value, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
        pw.SizedBox(height: 4),
        pw.Text(
          CurrencyFormatter.format(value),
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: color),
        ),
      ],
    );
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
                        e.type == TransactionType.expense &&
                        e.date.month == _selectedMonth &&
                        e.date.year == _selectedYear).toList();

                    final incomes = state.expenses.where((e) =>
                        e.type == TransactionType.income &&
                        e.date.month == _selectedMonth &&
                        e.date.year == _selectedYear).toList();

                    final totalExpense = expenses.fold<double>(0, (s, e) => s + e.amount);
                    final totalIncome = incomes.fold<double>(0, (s, e) => s + e.amount);

                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _SummaryCard(label: 'Tổng thu', value: totalIncome, color: const Color(0xFF4ECDC4)),
                        const SizedBox(height: 12),
                        _SummaryCard(label: 'Tổng chi', value: totalExpense, color: const Color(0xFFFF6B6B)),
                        const SizedBox(height: 12),
                        _SummaryCard(label: 'Số dư', value: totalIncome - totalExpense, color: const Color(0xFF006A65)),
                        const SizedBox(height: 20),

                        const Text('Giao dịch trong tháng', style: TextStyle(
                          fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w700,
                        )),
                        const SizedBox(height: 8),
                        if (expenses.isEmpty && incomes.isEmpty)
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
                        e.type == TransactionType.expense &&
                        e.date.month == _selectedMonth &&
                        e.date.year == _selectedYear).toList();
                    final incomes = state.expenses.where((e) =>
                        e.type == TransactionType.income &&
                        e.date.month == _selectedMonth &&
                        e.date.year == _selectedYear).toList();

                    if (expenses.isEmpty && incomes.isEmpty) {
                      return Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(child: Text('Không có dữ liệu', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700, color: Colors.grey))),
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: _exportButton(
                          icon: Icons.table_chart_outlined,
                          label: 'CSV',
                          onTap: () => _exportCsv(expenses, incomes),
                          isLoading: _isGeneratingPdf,
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _exportButton(
                          icon: Icons.grid_on_rounded,
                          label: 'Excel',
                          onTap: () => _exportExcel(expenses, incomes),
                          isLoading: _isGeneratingPdf,
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _exportButton(
                          icon: Icons.picture_as_pdf_rounded,
                          label: 'PDF',
                          onTap: () async {
                            if (_isGeneratingPdf) return;
                            setState(() => _isGeneratingPdf = true);
                            await HapticFeedback.lightImpact();
                            try {
                              final pdf = await _generatePdf(expenses, incomes);
                              await Printing.layoutPdf(
                                onLayout: (format) async => pdf.save(),
                                name: 'BaoCaoPicFi_$_selectedMonth$_selectedYear.pdf',
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Lỗi xuất PDF: $e', style: const TextStyle(fontFamily: 'Inter')),
                                backgroundColor: const Color(0xFFFF6B6B),
                                behavior: SnackBarBehavior.floating,
                              ));
                            } finally {
                              if (mounted) setState(() => _isGeneratingPdf = false);
                            }
                          },
                          isLoading: _isGeneratingPdf,
                        )),
                      ],
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
