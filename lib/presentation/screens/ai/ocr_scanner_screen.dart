import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../blocs/ai/ai_cubit.dart';
import '../../blocs/premium/premium_cubit.dart';
import '../../blocs/expense/expense_cubit.dart';
import '../../../domain/entities/expense_entity.dart';

class OcrScannerScreen extends StatefulWidget {
  const OcrScannerScreen({super.key});

  @override
  State<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends State<OcrScannerScreen>
    with SingleTickerProviderStateMixin {
  File? _image;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final isPremium = context.read<PremiumCubit>().state.isPremium;
    if (!isPremium) {
      _showPremiumRequired();
      return;
    }

    final aiCubit = context.read<AICubit>();

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
    );

    if (picked != null) {
      setState(() => _image = File(picked.path));
      HapticFeedback.mediumImpact();
      aiCubit.scanReceipt(picked.path);
    }
  }

  void _showPremiumRequired() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(
        children: [
          Icon(Icons.star_rounded, color: Color(0xFFFFD700)),
          SizedBox(width: 8),
          Expanded(child: Text('Quét hóa đơn yêu cầu gói Premium', style: TextStyle(color: Colors.white))),
        ],
      ),
      backgroundColor: const Color(0xFF006A65),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      action: SnackBarAction(
        label: 'Nâng cấp',
        textColor: const Color(0xFFFFD700),
        onPressed: () => context.push('/premium'),
      ),
    ));
  }

  void _createExpenseFromOcr(OcrResult result) {
    final now = DateTime.now();
    final expense = ExpenseEntity(
      id: '',
      userId: '',
      amount: result.amount,
      category: result.category.name,
      note: 'Quét từ hóa đơn - ${result.store}',
      date: result.date,
      createdAt: now,
      updatedAt: now,
    );
    context.read<ExpenseCubit>().addExpense(expense);
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.white),
          SizedBox(width: 8),
          Expanded(child: Text('Đã thêm chi tiêu từ hóa đơn!', style: TextStyle(color: Colors.white))),
        ],
      ),
      backgroundColor: const Color(0xFF2ECC71),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    ));
    context.read<AICubit>().clearOcrResult();
    setState(() => _image = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét hóa đơn OCR'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_image == null)
              _buildImagePicker()
            else
              _buildImagePreview(),
            const SizedBox(height: 24),
            BlocBuilder<AICubit, AIState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return _buildScanningAnimation();
                }
                if (state.ocrResult != null) {
                  return _buildResultCard(state.ocrResult!);
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        const SizedBox(height: 40),
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, _) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4ECDC4), Color(0xFF006A65)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.document_scanner_rounded, size: 80, color: Colors.white),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        const Text('Quét hóa đơn của bạn', style: TextStyle(
          fontFamily: 'Manrope', fontSize: 24, fontWeight: FontWeight.w800,
        )),
        const SizedBox(height: 8),
        Text(
          'Chụp ảnh hóa đơn để tự động trích xuất\nsố tiền, ngày tháng và danh mục',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter', fontSize: 15,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _pickImage(ImageSource.camera),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ECDC4).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF4ECDC4).withValues(alpha: 0.15)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.camera_alt_rounded, size: 40, color: Color(0xFF4ECDC4)),
                      SizedBox(height: 12),
                      Text('Máy ảnh', style: TextStyle(
                        fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600,
                      )),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => _pickImage(ImageSource.gallery),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9B59B6).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF9B59B6).withValues(alpha: 0.15)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.photo_library_rounded, size: 40, color: Color(0xFF9B59B6)),
                      SizedBox(height: 12),
                      Text('Thư viện', style: TextStyle(
                        fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600,
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(
            _image!,
            height: 300,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            setState(() => _image = null);
            context.read<AICubit>().clearOcrResult();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.errorContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh_rounded, size: 16, color: Color(0xFFFF6B6B)),
                SizedBox(width: 6),
                Text('Chọn ảnh khác', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFFF6B6B),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanningAnimation() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 60, height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text('Đang quét hóa đơn...', style: TextStyle(
            fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600,
          )),
          const SizedBox(height: 4),
          Text(
            'AI đang phân tích và trích xuất thông tin',
            style: TextStyle(
              fontFamily: 'Inter', fontSize: 14,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(OcrResult result) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF2ECC71), size: 24),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kết quả quét', style: TextStyle(
                    fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w800,
                  )),
                  Text('Độ chính xác cao', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500,
                    color: Color(0xFF2ECC71),
                  )),
                ],
              ),
            ],
          ),
          const Divider(height: 32),
          _buildResultRow(Icons.monetization_on_rounded, 'Số tiền',
              CurrencyFormatter.format(result.amount), AppColors.primary),
          _buildResultRow(Icons.category_rounded, 'Danh mục', result.category.label, result.category.color),
          _buildResultRow(Icons.store_rounded, 'Cửa hàng', result.store, const Color(0xFF9B59B6)),
          _buildResultRow(Icons.calendar_today_rounded, 'Ngày',
              '${result.date.day}/${result.date.month}/${result.date.year}', const Color(0xFF45B7D1)),
          _buildResultRow(Icons.analytics_rounded, 'Độ chính xác',
              '${(result.confidence * 100).toStringAsFixed(0)}%', const Color(0xFFF1C40F)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () => _createExpenseFromOcr(result),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF006A65), Color(0xFF4ECDC4)]),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(child: Text('Thêm chi tiêu', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white,
                ))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: TextStyle(
              fontFamily: 'Inter', fontSize: 14,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            )),
          ),
          Text(value, style: TextStyle(
            fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w700,
            color: color,
          )),
        ],
      ),
    );
  }
}
