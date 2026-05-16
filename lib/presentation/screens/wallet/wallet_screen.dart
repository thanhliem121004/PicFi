import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/wallet_entity.dart';
import '../../blocs/wallet/wallet_cubit.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0, 0.6, curve: Curves.easeOut)),
    );
    _slideUp = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  void _showAddWalletSheet({WalletEntity? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final iconCtrl = TextEditingController(text: existing?.icon ?? '💳');
    var selectedColor = Color(existing?.colorValue ?? 0xFF006A65);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(existing != null ? 'Sửa ví' : 'Thêm ví mới', style: const TextStyle(
                  fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800,
                )),
                const SizedBox(height: 6),
                Text('Chọn biểu tượng và màu sắc cho ví', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 14,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                )),
                const SizedBox(height: 16),
                Text(iconCtrl.text, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 56,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: ['💳', '💰', '🏦', '👛', '💼', '🏠', '🎯', '✈️', '🛒', '📦'].map((emoji) {
                      final isSelected = iconCtrl.text == emoji;
                      return GestureDetector(
                        onTap: () {
                          iconCtrl.text = emoji;
                          iconCtrl.selection = TextSelection.fromPosition(TextPosition(offset: emoji.length));
                          setSheetState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? selectedColor.withValues(alpha: 0.12) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isSelected ? selectedColor : Colors.transparent, width: 2),
                          ),
                          child: Text(emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      const Color(0xFF006A65), const Color(0xFF4ECDC4), const Color(0xFFFF6B6B),
                      const Color(0xFF9B59B6), const Color(0xFFF0B27A), const Color(0xFF45B7D1),
                      const Color(0xFF2ECC71), const Color(0xFF3498DB), const Color(0xFFE74C3C),
                      const Color(0xFF1ABC9C),
                    ].map((c) {
                      final isSelected = selectedColor == c;
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedColor = c),
                        child: Container(
                          width: 36, height: 36,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c,
                            border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                            boxShadow: isSelected ? [
                              BoxShadow(color: c.withValues(alpha: 0.4), blurRadius: 8),
                            ] : null,
                          ),
                          child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9F8),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: selectedColor.withValues(alpha: 0.15)),
                    ),
                    child: TextField(
                      controller: nameCtrl,
                      autofocus: existing == null,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Tên ví (VD: Tiền mặt, Techcombank...)',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 14, right: 10),
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: selectedColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.wallet_rounded, size: 20, color: selectedColor),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 60),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () async {
                        if (nameCtrl.text.trim().isEmpty) {
                          unawaited(HapticFeedback.heavyImpact());
                          return;
                        }
                        unawaited(HapticFeedback.mediumImpact());
                        final cubit = context.read<WalletCubit>();
                        if (existing != null) {
                          await cubit.updateWallet(existing.id, {
                            'name': nameCtrl.text.trim(),
                            'icon': iconCtrl.text,
                            'colorValue': selectedColor.toARGB32(),

                          });
                        } else {
                          await cubit.addWallet(WalletEntity(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                            name: nameCtrl.text.trim(),
                            icon: iconCtrl.text,
                            colorValue: selectedColor.toARGB32(),
                            createdAt: DateTime.now(),
                          ));
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [selectedColor, selectedColor.withValues(alpha: 0.7)]),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(color: selectedColor.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Center(child: Text(
                          existing != null ? 'Cập nhật' : 'Tạo ví',
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                        )),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
            animation: _entryController,
            builder: (context, _) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF006A65).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_back_rounded, size: 22, color: Color(0xFF006A65)),
                          ),
                        ),
                        const Spacer(),
                        const Text('Quản lý ví', style: TextStyle(
                          fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        )),
                        const Spacer(),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: BlocBuilder<WalletCubit, WalletState>(
                      builder: (context, state) {
                        if (state.isLoading) {
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF006A65)));
                        }
                        if (state.wallets.isEmpty) {
                          return Opacity(
                            opacity: _fadeIn.value,
                            child: Transform.translate(
                              offset: Offset(0, _slideUp.value),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 80, height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF4ECDC4).withValues(alpha: 0.1),
                                      ),
                                      child: const Icon(Icons.wallet_rounded, size: 36, color: Color(0xFF4ECDC4)),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text('Chưa có ví nào', style: TextStyle(
                                      fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700,
                                      color: AppColors.onSurfaceVariant,
                                    )),
                                    const SizedBox(height: 8),
                                    Text('Nhấn + để tạo ví mới', style: TextStyle(
                                      fontFamily: 'Inter', fontSize: 14,
                                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        return Opacity(
                          opacity: _fadeIn.value,
                          child: Transform.translate(
                            offset: Offset(0, _slideUp.value),
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                              itemCount: state.wallets.length,
                              itemBuilder: (context, index) {
                                final wallet = state.wallets[index];
                                final color = Color(wallet.colorValue);
                                return Dismissible(
                                  key: Key(wallet.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF6B6B),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 24),
                                    child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
                                  ),
                                  onDismissed: (_) {
                                    unawaited(HapticFeedback.mediumImpact());
                                    unawaited(context.read<WalletCubit>().deleteWallet(wallet.id));
                                  },
                                  child: GestureDetector(
                                    onTap: () => _showAddWalletSheet(existing: wallet),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.03),
                                            blurRadius: 10, offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 52, height: 52,
                                            decoration: BoxDecoration(
                                              color: color.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Center(child: Text(wallet.icon, style: const TextStyle(fontSize: 24))),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(wallet.name, style: const TextStyle(
                                                      fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w700,
                                                    )),
                                                    if (wallet.isDefault) ...[
                                                      const SizedBox(width: 6),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: color.withValues(alpha: 0.12),
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: Text('Mặc định', style: TextStyle(
                                                          fontFamily: 'Inter', fontSize: 10,
                                                          fontWeight: FontWeight.w600, color: color,
                                                        )),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(CurrencyFormatter.formatShort(wallet.balance), style: TextStyle(
                                                  fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w800,
                                                  color: color,
                                                )),
                                              ],
                                            ),
                                          ),
                                          const Icon(Icons.edit_rounded, size: 18, color: AppColors.outline),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWalletSheet(),
        backgroundColor: const Color(0xFF006A65),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
