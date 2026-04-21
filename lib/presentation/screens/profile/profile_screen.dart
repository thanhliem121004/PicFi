import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../blocs/theme/theme_cubit.dart';
import '../../blocs/auth/auth_cubit.dart';
import '../../blocs/expense/expense_cubit.dart';
import '../../blocs/friends/friends_cubit.dart';
import '../../../core/utils/currency_formatter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _headerSlide;
  late Animation<double> _headerOpacity;
  late Animation<double> _bodySlide;
  late Animation<double> _bodyOpacity;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1000),
    );
    _headerSlide = Tween<double>(begin: -30, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0, 0.5, curve: Curves.easeOutCubic)),
    );
    _headerOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0, 0.3)),
    );
    _bodySlide = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic)),
    );
    _bodyOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.2, 0.6)),
    );
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF0F0),
              Color(0xFFF0FBF9),
              Color(0xFFF5F0FF),
              Color(0xFFEFF5F3),
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, _) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // ═══ Header with gradient card ═══
                    Opacity(
                      opacity: _headerOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _headerSlide.value),
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFF6B6B),
                                Color(0xFFF0B27A),
                                Color(0xFF4ECDC4),
                              ],
                              stops: [0.0, 0.5, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6B6B).withValues(alpha: 0.25),
                                blurRadius: 25,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Decorative circles
                              Positioned(
                                top: -15, right: -15,
                                child: Container(
                                  width: 80, height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -10, left: 30,
                                child: Container(
                                  width: 50, height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.06),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  // Avatar
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                                    ),
                                    child: Container(
                                      width: 72, height: 72,
                                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(36),
                                        child: Image.asset(
                                          'assets/images/auth_illustration.png',
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded, size: 36, color: Color(0xFFFF6B6B)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Info
                                  Expanded(
                                    child: BlocBuilder<AuthCubit, AuthState>(
                                      builder: (context, authState) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              authState.displayName ?? 'Người dùng PicFi',
                                              style: const TextStyle(
                                                fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800,
                                                color: Colors.white, letterSpacing: -0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              authState.email ?? 'picfi@app.com',
                                              style: TextStyle(
                                                fontFamily: 'Inter', fontSize: 14,
                                                color: Colors.white.withValues(alpha: 0.8),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                // PicFi ID badge
                                                GestureDetector(
                                                  onTap: () {
                                                    Clipboard.setData(ClipboardData(text: authState.picfiId ?? ''));
                                                    HapticFeedback.mediumImpact();
                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                      content: const Text('Đã copy PicFi ID! 📋', style: TextStyle(fontFamily: 'Inter')),
                                                      backgroundColor: const Color(0xFF4ECDC4),
                                                      behavior: SnackBarBehavior.floating,
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                      duration: const Duration(seconds: 2),
                                                    ));
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withValues(alpha: 0.25),
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Icon(Icons.fingerprint_rounded, size: 14, color: Colors.white),
                                                        const SizedBox(width: 4),
                                                        Text(authState.picfiId ?? 'PF-...', style: const TextStyle(
                                                          fontFamily: 'Manrope', fontSize: 12,
                                                          fontWeight: FontWeight.w700, color: Colors.white,
                                                          letterSpacing: 0.5,
                                                        )),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                // Streak badge (real data)
                                                BlocBuilder<FriendsCubit, FriendsState>(
                                                  builder: (ctx, fState) {
                                                    final maxStreak = fState.friends.isEmpty ? 0
                                                        : fState.friends.map((f) => f.streak).reduce((a, b) => a > b ? a : b);
                                                    return Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withValues(alpha: 0.2),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          const Text('🔥', style: TextStyle(fontSize: 12)),
                                                          const SizedBox(width: 4),
                                                          Text('$maxStreak ngày', style: const TextStyle(
                                                            fontFamily: 'Inter', fontSize: 12,
                                                            fontWeight: FontWeight.w600, color: Colors.white,
                                                          )),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  // Edit
                                  Container(
                                    width: 36, height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.edit_rounded, size: 18, color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ═══ Stats Cards ═══
                    Opacity(
                      opacity: _bodyOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _bodySlide.value * 0.5),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: BlocBuilder<ExpenseCubit, ExpenseState>(
                            builder: (context, expState) {
                              return Row(
                                children: [
                                  Expanded(child: _StatCard(
                                    icon: Icons.receipt_long_rounded,
                                    value: '${expState.expenses.length}',
                                    label: 'Giao dịch',
                                    color: const Color(0xFF4ECDC4),
                                    bgColor: const Color(0xFFF0FBF9),
                                  )),
                                  const SizedBox(width: 10),
                                  Expanded(child: _StatCard(
                                    icon: Icons.trending_down_rounded,
                                    value: CurrencyFormatter.formatShort(expState.totalExpense),
                                    label: 'Chi tiêu',
                                    color: const Color(0xFFFF6B6B),
                                    bgColor: const Color(0xFFFFF5F5),
                                  )),
                                  const SizedBox(width: 10),
                                  Expanded(child: BlocBuilder<FriendsCubit, FriendsState>(
                                    builder: (ctx, fState) {
                                      return _StatCard(
                                        icon: Icons.people_rounded,
                                        value: '${fState.friends.length}',
                                        label: 'Bạn bè',
                                        color: const Color(0xFF9B59B6),
                                        bgColor: const Color(0xFFF5F0FF),
                                      );
                                    },
                                  )),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ═══ Settings Group 1 ═══
                    Opacity(
                      opacity: _bodyOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _bodySlide.value),
                        child: _SettingsGroup(
                          title: 'Tài khoản',
                          children: [
                            _VibrantTile(
                              icon: Icons.person_rounded,
                              color: const Color(0xFF006A65),
                              title: AppStrings.personalInfo,
                              onTap: () => _showEditNameDialog(context),
                            ),
                            _VibrantTile(
                              icon: Icons.notifications_rounded,
                              color: const Color(0xFF45B7D1),
                              title: AppStrings.notifications,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: const Text('Thông báo đã được bật ✅', style: TextStyle(fontFamily: 'Inter')),
                                  backgroundColor: const Color(0xFF45B7D1),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ));
                              },
                            ),
                            _VibrantTile(
                              icon: Icons.account_balance_wallet_rounded,
                              color: const Color(0xFF4ECDC4),
                              title: AppStrings.budget,
                              onTap: () => _showBudgetDialog(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ═══ Settings Group 2 ═══
                    Opacity(
                      opacity: _bodyOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _bodySlide.value * 1.2),
                        child: _SettingsGroup(
                          title: 'Ứng dụng',
                          children: [
                            _VibrantTile(
                              icon: Icons.description_rounded,
                              color: const Color(0xFFF0B27A),
                              title: AppStrings.exportReport,
                              onTap: () => _showExportDialog(context),
                            ),
                            BlocBuilder<ThemeCubit, ThemeMode>(
                              builder: (context, themeMode) {
                                return _VibrantTile(
                                  icon: Icons.brightness_6_rounded,
                                  color: const Color(0xFF9B59B6),
                                  title: AppStrings.darkMode,
                                  trailing: Switch(
                                    value: themeMode == ThemeMode.dark,
                                    activeTrackColor: const Color(0xFF9B59B6),
                                    onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
                                  ),
                                  onTap: () => context.read<ThemeCubit>().toggleTheme(),
                                );
                              },
                            ),
                            _VibrantTile(
                              icon: Icons.people_alt_rounded,
                              color: const Color(0xFFFF6B6B),
                              title: AppStrings.friends,
                              onTap: () => context.push('/friends'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ═══ Logout ═══
                    Opacity(
                      opacity: _bodyOpacity.value,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            context.read<AuthCubit>().signOut();
                            context.go('/login');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B).withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: const Color(0xFFFF6B6B).withValues(alpha: 0.15)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFFF6B6B)),
                                ),
                                const SizedBox(width: 12),
                                const Text(AppStrings.logout, style: TextStyle(
                                  fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600,
                                  color: Color(0xFFFF6B6B),
                                )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ═══ Edit Name Dialog ═══
  void _showEditNameDialog(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final controller = TextEditingController(text: authState.displayName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: AppColors.outlineVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            )),
            const SizedBox(height: 20),
            const Text('Chỉnh sửa tên', style: TextStyle(
              fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800,
            )),
            const SizedBox(height: 6),
            Text('PicFi ID: ${authState.picfiId ?? "N/A"}', style: TextStyle(
              fontFamily: 'Inter', fontSize: 14,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            )),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9F8),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF006A65).withValues(alpha: 0.15)),
              ),
              child: TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Nhập tên mới',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 10),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF006A65).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person_rounded, size: 20, color: Color(0xFF006A65)),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 60),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  final name = controller.text.trim();
                  if (name.isNotEmpty) {
                    context.read<AuthCubit>().updateProfile(displayName: name);
                    Navigator.pop(ctx);
                    HapticFeedback.mediumImpact();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Đã cập nhật tên! ✨', style: TextStyle(fontFamily: 'Inter')),
                      backgroundColor: const Color(0xFF4ECDC4),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF006A65), Color(0xFF4ECDC4)]),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF006A65).withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Center(child: Text('Lưu thay đổi', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white,
                  ))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══ Budget Dialog ═══
  void _showBudgetDialog(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: AppColors.outlineVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            )),
            const SizedBox(height: 20),
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [
                  const Color(0xFF4ECDC4).withValues(alpha: 0.15),
                  const Color(0xFF006A65).withValues(alpha: 0.1),
                ]),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded, size: 28, color: Color(0xFF4ECDC4)),
            ),
            const SizedBox(height: 16),
            const Text('Ngân sách hàng tháng', style: TextStyle(
              fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800,
            )),
            const SizedBox(height: 6),
            Text('Đặt ngân sách để theo dõi chi tiêu', style: TextStyle(
              fontFamily: 'Inter', fontSize: 14,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            )),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9F8),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF4ECDC4).withValues(alpha: 0.15)),
              ),
              child: TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Manrope', fontSize: 28, fontWeight: FontWeight.w800),
                decoration: InputDecoration(
                  hintText: '5,000,000 ₫',
                  hintStyle: TextStyle(
                    fontFamily: 'Manrope', fontSize: 28, fontWeight: FontWeight.w800,
                    color: AppColors.outline.withValues(alpha: 0.3),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  final budgetText = controller.text.replaceAll('.', '').replaceAll(',', '');
                  final budget = double.tryParse(budgetText);
                  if (budget != null && budget > 0) {
                    Navigator.pop(ctx);
                    HapticFeedback.mediumImpact();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Đã đặt ngân sách ${CurrencyFormatter.formatShort(budget)} 💰', style: const TextStyle(fontFamily: 'Inter')),
                      backgroundColor: const Color(0xFF4ECDC4),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF4ECDC4), Color(0xFF006A65)]),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF4ECDC4).withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Center(child: Text('Lưu ngân sách 💰', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white,
                  ))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══ Export Dialog ═══
  void _showExportDialog(BuildContext context) {
    final expState = context.read<ExpenseCubit>().state;
    final total = expState.totalExpense;
    final count = expState.expenses.length;

    // Group by category
    final catMap = <String, double>{};
    for (final e in expState.expenses) {
      catMap[e.category] = (catMap[e.category] ?? 0) + e.amount;
    }
    final sortedCats = catMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.6),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: AppColors.outlineVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            )),
            const SizedBox(height: 20),
            const Text('Báo cáo chi tiêu 📊', style: TextStyle(
              fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800,
            )),
            const SizedBox(height: 16),
            // Summary row
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF006A65), Color(0xFF4ECDC4)]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(child: Column(
                    children: [
                      Text('$count', style: const TextStyle(
                        fontFamily: 'Manrope', fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white,
                      )),
                      Text('Giao dịch', style: TextStyle(
                        fontFamily: 'Inter', fontSize: 12, color: Colors.white.withValues(alpha: 0.7),
                      )),
                    ],
                  )),
                  Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.2)),
                  Expanded(child: Column(
                    children: [
                      Text(CurrencyFormatter.formatShort(total), style: const TextStyle(
                        fontFamily: 'Manrope', fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white,
                      )),
                      Text('Tổng chi', style: TextStyle(
                        fontFamily: 'Inter', fontSize: 12, color: Colors.white.withValues(alpha: 0.7),
                      )),
                    ],
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Category breakdown
            if (sortedCats.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Theo danh mục', style: TextStyle(
                  fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                )),
              ),
              const SizedBox(height: 8),
              ...sortedCats.take(5).map((entry) {
                final pct = total > 0 ? (entry.value / total * 100).toStringAsFixed(0) : '0';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(entry.key, style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w500,
                      ))),
                      Text('$pct%', style: TextStyle(
                        fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                      )),
                      const SizedBox(width: 8),
                      Text(CurrencyFormatter.formatShort(entry.value), style: const TextStyle(
                        fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w700,
                      )),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Báo cáo đã được tạo! 📊', style: TextStyle(fontFamily: 'Inter')),
                    backgroundColor: const Color(0xFFF0B27A),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFF0B27A), Color(0xFFFF6B6B)]),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(child: Text('Đóng', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white,
                  ))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color, bgColor;

  const _StatCard({
    required this.icon, required this.value,
    required this.label, required this.color, required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(
            fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w800,
            color: color,
          )),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(
            fontFamily: 'Inter', fontSize: 12,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
          )),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24, bottom: 8),
          child: Text(title, style: TextStyle(
            fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
          )),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;
              return Column(
                children: [
                  child,
                  if (index < children.length - 1)
                    Divider(height: 1, indent: 64, endIndent: 16,
                      color: AppColors.outlineVariant.withValues(alpha: 0.15)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _VibrantTile extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _VibrantTile({
    required this.icon, required this.color,
    required this.title, this.trailing, required this.onTap,
  });

  @override
  State<_VibrantTile> createState() => _VibrantTileState();
}

class _VibrantTileState extends State<_VibrantTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _pressed ? widget.color.withValues(alpha: 0.04) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: widget.color.withValues(alpha: 0.1),
              ),
              child: Icon(widget.icon, size: 20, color: widget.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(widget.title, style: const TextStyle(
                fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
              )),
            ),
            if (widget.trailing != null) widget.trailing!
            else Icon(Icons.chevron_right_rounded, color: widget.color.withValues(alpha: 0.4), size: 22),
          ],
        ),
      ),
    );
  }
}
