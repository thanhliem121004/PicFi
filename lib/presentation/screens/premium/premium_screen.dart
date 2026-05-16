import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/premium/premium_cubit.dart';
import '../../../domain/entities/premium_entity.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.1, 0.6, curve: Curves.easeOutCubic),
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF003734),
              Color(0xFF006A65),
              Color(0xFF0F1513),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildFeatureComparison(),
                    const SizedBox(height: 24),
                    _buildPricingCards(),
                    const SizedBox(height: 20),
                    _buildRestoreButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.star_rounded, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nâng cấp Premium',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mở khóa tất cả tính năng thông minh\nđể quản lý tài chính tốt hơn',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureComparison() {
    final features = [
      _FeatureItem('AI Trò chuyện', 'Trò chuyện với AI về tài chính', true, false),
      _FeatureItem('Tự động phân loại', 'Phân loại chi tiêu tự động', true, false),
      _FeatureItem('Quét hóa đơn OCR', 'Quét hóa đơn tự động', true, false),
      _FeatureItem('Phân tích nâng cao', 'Biểu đồ và dự đoán chi tiêu', true, false),
      _FeatureItem('Giao diện tùy chỉnh', 'Theme và màu sắc riêng', true, false),
      _FeatureItem('Không quảng cáo', 'Trải nghiệm không quảng cáo', true, false),
      _FeatureItem('Xuất báo cáo', 'Xuất CSV/PDF', true, false),
      _FeatureItem('Thông báo thông minh', 'Nhắc nhở ngân sách thông minh', true, true),
      _FeatureItem('Thống kê cơ bản', 'Biểu đồ chi tiêu cơ bản', true, true),
      _FeatureItem('Nhật ký chi tiêu', 'Ghi chép chi tiêu', true, true),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('', style: TextStyle(fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
              SizedBox(
                width: 72,
                child: Text('Free', textAlign: TextAlign.center, style: TextStyle(
                  fontFamily: 'Manrope', fontSize: 13, fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.5),
                )),
              ),
              SizedBox(
                width: 72,
                child: Text('Premium', textAlign: TextAlign.center, style: const TextStyle(
                  fontFamily: 'Manrope', fontSize: 13, fontWeight: FontWeight.w700,
                  color: Color(0xFFFFD700),
                )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(f.isPremium ? Icons.star_rounded : Icons.check_circle_rounded,
                  size: 16, color: f.isPremium ? const Color(0xFFFFD700) : AppColors.primaryContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(f.name, style: TextStyle(
                    fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                  )),
                ),
                SizedBox(
                  width: 72,
                  child: Icon(
                    f.free ? Icons.check_circle_rounded : Icons.horizontal_rule_rounded,
                    size: 20,
                    color: f.free ? AppColors.primaryContainer : Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                SizedBox(
                  width: 72,
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: const Color(0xFFFFD700),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPricingCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildPricingCard(
            plan: PremiumPlan.monthly,
            price: '49.000',
            period: '/tháng',
            savings: null,
            color: const Color(0xFF4ECDC4),
          ),
          const SizedBox(height: 12),
          _buildPricingCard(
            plan: PremiumPlan.yearly,
            price: '399.000',
            period: '/năm',
            savings: 'Tiết kiệm 32%',
            color: const Color(0xFFFFD700),
            isPopular: true,
          ),
          const SizedBox(height: 12),
          _buildPricingCard(
            plan: PremiumPlan.lifetime,
            price: '999.000',
            period: 'trọn đời',
            savings: 'Thanh toán một lần',
            color: const Color(0xFFFF6B6B),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard({
    required PremiumPlan plan,
    required String price,
    required String period,
    String? savings,
    required Color color,
    bool isPopular = false,
  }) {
    return BlocBuilder<PremiumCubit, PremiumState>(
      builder: (context, state) {
        final isCurrent = state.plan == plan && state.isPremium;
        return GestureDetector(
          onTap: state.isLoading
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  context.read<PremiumCubit>().purchase(plan.name);
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: isCurrent
                  ? LinearGradient(
                      colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)],
                    )
                  : isPopular
                      ? LinearGradient(
                          colors: [color.withValues(alpha: 0.15), Colors.white.withValues(alpha: 0.05)],
                        )
                      : null,
              color: isCurrent || isPopular ? null : Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                color: isCurrent
                    ? color
                    : isPopular
                        ? color.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.1),
                width: isCurrent ? 2 : 1,
              ),
            ),
            child: Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isPopular)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('Phổ biến nhất', style: TextStyle(
                                fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700,
                                color: color,
                              )),
                            ),
                          Text(plan.label, style: const TextStyle(
                            fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700,
                            color: Colors.white,
                          )),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text('$price₫', style: TextStyle(
                                fontFamily: 'Manrope', fontSize: 28, fontWeight: FontWeight.w800,
                                color: color,
                              )),
                              const SizedBox(width: 4),
                              Text(period, style: TextStyle(
                                fontFamily: 'Inter', fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.5),
                              )),
                            ],
                          ),
                          if (savings != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2ECC71).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(savings, style: const TextStyle(
                                fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600,
                                color: Color(0xFF2ECC71),
                              )),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2ECC71).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Đã kích hoạt', style: TextStyle(
                          fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700,
                          color: Color(0xFF2ECC71),
                        )),
                      )
                    else
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: 0.15),
                        ),
                        child: Icon(Icons.arrow_forward_rounded, color: color, size: 24),
                      ),
                  ],
                ),
                if (state.isLoading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRestoreButton() {
    return TextButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        context.read<PremiumCubit>().restore();
      },
      child: Text(
        'Khôi phục giao dịch',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _FeatureItem {
  final String name;
  final String description;
  final bool free;
  final bool isPremium;

  const _FeatureItem(this.name, this.description, this.free, this.isPremium);
}
