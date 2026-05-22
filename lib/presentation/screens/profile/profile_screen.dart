import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/expense_categories.dart';
import '../../blocs/theme/theme_cubit.dart';
import '../../blocs/auth/auth_cubit.dart';
import '../../blocs/budget/budget_cubit.dart';
import '../../blocs/expense/expense_cubit.dart';
import '../../blocs/friends/friends_cubit.dart';
import '../../blocs/premium/premium_cubit.dart';
import '../../blocs/lock/lock_cubit.dart' as lock;
import '../../../core/utils/currency_formatter.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({super.key, this.userId});

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

  Future<void> _changeAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
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
            const Text('Đổi ảnh đại diện', style: TextStyle(
              fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800,
            )),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: GestureDetector(
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ECDC4).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(children: [
                      Icon(Icons.camera_alt_rounded, size: 32, color: Color(0xFF4ECDC4)),
                      SizedBox(height: 8),
                      Text('Máy ảnh', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                )),
                const SizedBox(width: 16),
                Expanded(child: GestureDetector(
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9B59B6).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(children: [
                      Icon(Icons.photo_library_rounded, size: 32, color: Color(0xFF9B59B6)),
                      SizedBox(height: 8),
                      Text('Thư viện', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );

    if (source == null) return;
    final picked = await ImagePicker().pickImage(
      source: source, imageQuality: 70, maxWidth: 800,
    );
    if (picked == null || !mounted) return;

    HapticFeedback.lightImpact();
    _showPremiumToast('Đang tải ảnh lên... ⬆️');

    try {
      final uid = context.read<AuthCubit>().state.userId;
      final ref = FirebaseStorage.instance.ref('avatars/$uid.jpg');
      await ref.putFile(File(picked.path));
      final url = await ref.getDownloadURL();
      if (!mounted) return;
      context.read<AuthCubit>().updateProfile(photoUrl: url);
      _showPremiumToast('Đã cập nhật ảnh đại diện! ✨');
    } catch (e) {
      if (mounted) _showPremiumToast('Lỗi tải ảnh: $e', isError: true);
    }
  }

  void _showPremiumToast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: Colors.white, size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(msg, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500,
            color: Colors.white,
          ))),
        ],
      ),
      backgroundColor: isError ? const Color(0xFFFF6B6B) : const Color(0xFF006A65),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      duration: const Duration(seconds: 2),
    ));
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
                              if (Navigator.canPop(context))
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      context.pop();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
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
                                    child: GestureDetector(
                                      onTap: _changeAvatar,
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 72, height: 72,
                                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(36),
                                              child: BlocBuilder<AuthCubit, AuthState>(
                                                builder: (context, authState) {
                                                  if (authState.photoUrl != null && authState.photoUrl!.isNotEmpty) {
                                                    return CachedNetworkImage(
                                                      imageUrl: authState.photoUrl!,
                                                      width: 72, height: 72, fit: BoxFit.cover,
                                                      placeholder: (_, __) => const Center(
                                                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4ECDC4)),
                                                      ),
                                                      errorWidget: (_, __, ___) => _defaultAvatar(authState.displayName),
                                                    );
                                                  }
                                                  return _defaultAvatar(authState.displayName);
                                                },
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 0, right: 0,
                                            child: Container(
                                              width: 26, height: 26,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: const LinearGradient(colors: [Color(0xFF4ECDC4), Color(0xFF006A65)]),
                                                border: Border.all(color: Colors.white, width: 2),
                                              ),
                                              child: const Icon(Icons.camera_alt_rounded, size: 12, color: Colors.white),
                                            ),
                                          ),
                                        ],
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
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 4,
                                              children: [
                                                // PicFi ID badge
                                                GestureDetector(
                                                  onTap: () {
                                                    Clipboard.setData(ClipboardData(text: authState.picfiId ?? ''));
                                                    HapticFeedback.mediumImpact();
                                                    _showPremiumToast('Đã copy PicFi ID! 📋');
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
                                                        Text(
                                                          authState.picfiId != null && authState.picfiId!.isNotEmpty
                                                              ? authState.picfiId!
                                                              : 'Chưa có',
                                                          style: const TextStyle(
                                                          fontFamily: 'Manrope', fontSize: 12,
                                                          fontWeight: FontWeight.w700, color: Colors.white,
                                                          letterSpacing: 0.5,
                                                        )),
                                                      ],
                                                    ),
                                                  ),
                                                ),
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
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.mediumImpact();
                                      _showPremiumToast('Tính năng sửa hồ sơ đang phát triển 🛠️');
                                    },
                                    child: Container(
                                      width: 36, height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.edit_rounded, size: 18, color: Colors.white),
                                    ),
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
                                _showPremiumToast('Thông báo đã được bật ✅');
                              },
                            ),
                            _VibrantTile(
                              icon: Icons.account_balance_wallet_rounded,
                              color: const Color(0xFF4ECDC4),
                              title: AppStrings.budget,
                              onTap: () => _showBudgetDialog(context),
                            ),
                            _VibrantTile(
                              icon: Icons.monetization_on_rounded,
                              color: const Color(0xFF2ECC71),
                              title: 'Thu nhập hàng tháng',
                              onTap: () => _showIncomeDialog(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ═══ AI & Premium Group ═══
                    Opacity(
                      opacity: _bodyOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _bodySlide.value * 1.0),
                        child: _SettingsGroup(
                          title: 'AI & Premium',
                          children: [
                            BlocBuilder<PremiumCubit, PremiumState>(
                              builder: (context, state) {
                                return _VibrantTile(
                                  icon: Icons.star_rounded,
                                  color: const Color(0xFFFFD700),
                                  title: state.isPremium ? 'Premium ● Đã kích hoạt' : AppStrings.upgradePremium,
                                  trailing: state.isPremium
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text('Đã kích hoạt', style: TextStyle(
                                            fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2ECC71),
                                          )),
                                        )
                                      : null,
                                  onTap: () => context.push('/premium'),
                                );
                              },
                            ),
                            _VibrantTile(
                              icon: Icons.chat_rounded,
                              color: const Color(0xFF4ECDC4),
                              title: AppStrings.aiChat,
                              onTap: () => context.push('/ai-chat'),
                            ),
                            _VibrantTile(
                              icon: Icons.document_scanner_rounded,
                              color: const Color(0xFF45B7D1),
                              title: AppStrings.scanReceipt,
                              onTap: () => context.push('/ocr-scanner'),
                            ),
                            _VibrantTile(
                              icon: Icons.analytics_rounded,
                              color: const Color(0xFFBB8FCE),
                              title: AppStrings.advancedAnalytics,
                              onTap: () => context.push('/advanced-analytics'),
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
                            _VibrantTile(
                              icon: Icons.cloud_upload_rounded,
                              color: const Color(0xFF4ECDC4),
                              title: 'Sao lưu & Khôi phục',
                              onTap: () => context.push('/backup'),
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

                    // ═══ Security Group ═══
                    Opacity(
                      opacity: _bodyOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _bodySlide.value * 1.4),
                        child: _SettingsGroup(
                          title: AppStrings.security,
                          children: [
                            BlocBuilder<lock.LockCubit, lock.LockState>(
                              builder: (context, lockState) {
                                return _VibrantTile(
                                  icon: Icons.fingerprint_rounded,
                                  color: const Color(0xFF006A65),
                                  title: AppStrings.biometricAuth,
                                  trailing: Switch(
                                    value: lockState.useBiometric,
                                    activeTrackColor: const Color(0xFF006A65),
                                    onChanged: lockState.isEnabled
                                        ? (val) {
                                            HapticFeedback.lightImpact();
                                            context.read<lock.LockCubit>().toggleBiometric(val);
                                          }
                                        : null,
                                  ),
                                  onTap: lockState.isEnabled
                                      ? () {
                                          HapticFeedback.lightImpact();
                                          context.read<lock.LockCubit>().toggleBiometric(!lockState.useBiometric);
                                        }
                                      : () {
                                          _showPremiumToast('Vui lòng bật Khóa ứng dụng trước 🔒', isError: true);
                                        },
                                );
                              },
                            ),
                            BlocBuilder<lock.LockCubit, lock.LockState>(
                              builder: (context, lockState) {
                                return _VibrantTile(
                                  icon: Icons.lock_outline_rounded,
                                  color: const Color(0xFF45B7D1),
                                  title: AppStrings.pinCode,
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: lockState.isEnabled
                                          ? const Color(0xFF2ECC71).withValues(alpha: 0.1)
                                          : Colors.grey.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      lockState.isEnabled ? 'Đã bật' : 'Chưa bật',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: lockState.isEnabled ? const Color(0xFF2ECC71) : Colors.grey,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    context.push('/lock-settings');
                                  },
                                );
                              },
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

  Widget _defaultAvatar(String? name) {
    final initial = (name != null && name.isNotEmpty) ? name[0].toUpperCase() : '?';
    return Container(
      width: 72, height: 72,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFF0B27A)],
        ),
      ),
      child: Center(
        child: Text(initial, style: const TextStyle(
          fontFamily: 'Manrope', fontSize: 32, fontWeight: FontWeight.w800,
          color: Colors.white,
        )),
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
                    _showPremiumToast('Đã cập nhật tên! ✨');
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

  // ═══ Income Dialog ═══
  void _showIncomeDialog(BuildContext context) {
    final expenseCubit = context.read<ExpenseCubit>();
    final currentIncome = expenseCubit.state.totalIncome;
    final controller = TextEditingController(text: currentIncome > 0 ? currentIncome.toStringAsFixed(0) : '');

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
                  const Color(0xFF2ECC71).withValues(alpha: 0.15),
                  const Color(0xFF27AE60).withValues(alpha: 0.1),
                ]),
              ),
              child: const Icon(Icons.monetization_on_rounded, size: 28, color: Color(0xFF2ECC71)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Thu nhập hàng tháng',
              style: TextStyle(fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Thiết lập thu nhập hàng tháng để tính toán phân tích chi tiêu',
              style: TextStyle(
                fontFamily: 'Inter', fontSize: 14,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Amount field
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9F8),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF2ECC71).withValues(alpha: 0.15)),
              ),
              child: TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Manrope', fontSize: 28, fontWeight: FontWeight.w800),
                decoration: InputDecoration(
                  hintText: '20,000,000 ₫',
                  hintStyle: TextStyle(
                    fontFamily: 'Manrope', fontSize: 28, fontWeight: FontWeight.w800,
                    color: AppColors.outline.withValues(alpha: 0.3),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  final incomeText = controller.text.replaceAll('.', '').replaceAll(',', '');
                  final income = double.tryParse(incomeText);
                  if (income != null && income >= 0) {
                    Navigator.pop(ctx);
                    HapticFeedback.mediumImpact();
                    expenseCubit.setIncome(income);
                    _showPremiumToast('Đã cập nhật thu nhập: ${CurrencyFormatter.formatShort(income)} 💵');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF2ECC71), Color(0xFF27AE60)]),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF2ECC71).withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Center(child: Text(
                    'Lưu thu nhập 💵',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                  )),
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
    final budgetCubit = context.read<BudgetCubit>();
    final budgets = budgetCubit.state.budgets;
    final controller = TextEditingController();
    String? editingBudgetId;
    String? editingCategory = 'other';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
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
                Text(
                  editingBudgetId != null ? 'Chỉnh sửa ngân sách' : 'Ngân sách hàng tháng',
                  style: const TextStyle(fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(editingBudgetId != null ? 'Cập nhật hạn mức cho danh mục' : 'Đặt ngân sách để theo dõi chi tiêu', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 14,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                )),
                const SizedBox(height: 20),

                // Category selector
                if (!(editingBudgetId != null)) ...[
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: ExpenseCategory.values.map((cat) {
                        final selected = editingCategory == cat.name;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setSheetState(() => editingCategory = cat.name),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: selected ? cat.color.withValues(alpha: 0.12) : const Color(0xFFF7F9F8),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: selected ? cat.color : Colors.transparent),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(cat.icon, size: 16, color: selected ? cat.color : AppColors.onSurfaceVariant),
                                  const SizedBox(width: 6),
                                  Text(cat.label, style: TextStyle(
                                    fontFamily: 'Inter', fontSize: 13,
                                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                    color: selected ? cat.color : AppColors.onSurfaceVariant,
                                  )),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Amount field
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

                // Existing budgets list
                if (budgets.isNotEmpty && editingBudgetId == null) ...[
                  Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    child: ListView(
                      shrinkWrap: true,
                      children: budgets.map((b) {
                        final cat = ExpenseCategory.values.firstWhere(
                          (c) => c.name == b.category, orElse: () => ExpenseCategory.other,
                        );
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F9F8),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(cat.icon, size: 16, color: cat.color),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('${cat.label}: ${CurrencyFormatter.formatShort(b.monthlyLimit)}', style: const TextStyle(
                                  fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
                                )),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setSheetState(() {
                                    editingBudgetId = b.id;
                                    editingCategory = b.category;
                                    controller.text = b.monthlyLimit.toStringAsFixed(0);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4ECDC4).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.edit_rounded, size: 14, color: Color(0xFF4ECDC4)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(ctx);
                                  HapticFeedback.mediumImpact();
                                  context.read<BudgetCubit>().deleteBudget(b.id);
                                  _showPremiumToast('Đã xóa ngân sách ${cat.label} 🗑️');
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.delete_rounded, size: 14, color: Color(0xFFFF6B6B)),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Save/Update button
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () {
                      final budgetText = controller.text.replaceAll('.', '').replaceAll(',', '');
                      final budget = double.tryParse(budgetText);
                      if (budget != null && budget > 0) {
                        Navigator.pop(ctx);
                        HapticFeedback.mediumImpact();
                        if (editingBudgetId != null) {
                          context.read<BudgetCubit>().updateBudgetLimit(editingBudgetId!, budget);
                          _showPremiumToast('Đã cập nhật ngân sách! ✨');
                        } else {
                          context.read<BudgetCubit>().addBudget(editingCategory ?? 'other', budget);
                          _showPremiumToast('Đã đặt ngân sách ${CurrencyFormatter.formatShort(budget)} 💰');
                        }
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
                      child: Center(child: Text(
                        editingBudgetId != null ? 'Cập nhật ngân sách' : 'Lưu ngân sách 💰',
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                      )),
                    ),
                  ),
                ),
                if (editingBudgetId != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        HapticFeedback.mediumImpact();
                        context.read<BudgetCubit>().deleteBudget(editingBudgetId!);
                        _showPremiumToast('Đã xóa ngân sách 🗑️');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B).withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFFF6B6B).withValues(alpha: 0.2)),
                        ),
                        child: const Center(child: Text('Xóa ngân sách', style: TextStyle(
                          fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600,
                          color: Color(0xFFFF6B6B),
                        ))),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
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
                  _showPremiumToast('Báo cáo đã được tạo! 📊');
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF141A19).withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.4),
                  ),
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
            ),
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
