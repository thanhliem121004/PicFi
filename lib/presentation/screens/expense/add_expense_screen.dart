import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/expense_categories.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../blocs/expense/expense_cubit.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen>
    with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController(text: '0');
  final _noteController = TextEditingController();
  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  DateTime _selectedDate = DateTime.now();
  bool _shareToFeed = true;
  String _selectedEmoji = '💸';
  File? _pickedImage;
  bool _isUploading = false;
  late AnimationController _entryController;
  late Animation<double> _slideUp;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800),
    );
    _slideUp = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0, 0.6, curve: Curves.easeOut)),
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _showImagePicker() {
    showModalBottomSheet(
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
            const Text('Chọn ảnh', style: TextStyle(
              fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800,
            )),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      final picked = await ImagePicker().pickImage(
                        source: ImageSource.camera,
                        imageQuality: 70,
                        maxWidth: 1200,
                      );
                      if (picked != null) setState(() => _pickedImage = File(picked.path));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ECDC4).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF4ECDC4).withValues(alpha: 0.15)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.camera_alt_rounded, size: 32, color: Color(0xFF4ECDC4)),
                          SizedBox(height: 8),
                          Text('Máy ảnh', style: TextStyle(
                            fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      final picked = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 70,
                        maxWidth: 1200,
                      );
                      if (picked != null) setState(() => _pickedImage = File(picked.path));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9B59B6).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF9B59B6).withValues(alpha: 0.15)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.photo_library_rounded, size: 32, color: Color(0xFF9B59B6)),
                          SizedBox(height: 8),
                          Text('Thư viện', style: TextStyle(
                            fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPremiumToast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.2)),
          child: Icon(isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(msg, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white))),
      ]),
      backgroundColor: isError ? const Color(0xFFFF6B6B) : const Color(0xFF006A65),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8, duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0FBF9), Color(0xFFFFF8F0), Colors.white],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _entryController,
            builder: (context, _) {
              return Stack(
                children: [
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 100),
                    child: Column(
                      children: [
                        // ═══ Header ═══
                        Opacity(
                          opacity: _fadeIn.value,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () => context.pop(),
                                  icon: Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                                    ),
                                    child: const Icon(Icons.close_rounded, size: 20),
                                  ),
                                ),
                                const Spacer(),
                                ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [Color(0xFF006A65), Color(0xFF4ECDC4)],
                                  ).createShader(bounds),
                                  child: const Text('Thêm Chi Tiêu', style: TextStyle(
                                    fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  )),
                                ),
                                const Spacer(),
                                const SizedBox(width: 48),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ═══ Photo Section (Locket-style) ═══
                        Opacity(
                          opacity: _fadeIn.value,
                          child: Transform.translate(
                            offset: Offset(0, _slideUp.value * 0.5),
                            child: GestureDetector(
                              onTap: _showImagePicker,
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 24),
                                height: 280,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _pickedImage != null
                                          ? const Color(0xFF4ECDC4).withValues(alpha: 0.2)
                                          : Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 25,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: _pickedImage != null
                                      ? Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.file(_pickedImage!, fit: BoxFit.cover),
                                            // Gradient overlay bottom
                                            Positioned(
                                              bottom: 0, left: 0, right: 0,
                                              child: Container(
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.5)],
                                                  ),
                                                ),
                                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    const Text('📸 Ảnh đã chọn', style: TextStyle(
                                                      fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
                                                      color: Colors.white,
                                                    )),
                                                    GestureDetector(
                                                      onTap: () => setState(() => _pickedImage = null),
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white.withValues(alpha: 0.2),
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: const Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                                                            SizedBox(width: 4),
                                                            Text('Đổi', style: TextStyle(
                                                              fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
                                                              color: Colors.white,
                                                            )),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                const Color(0xFF4ECDC4).withValues(alpha: 0.06),
                                                const Color(0xFF9B59B6).withValues(alpha: 0.04),
                                              ],
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFF4ECDC4).withValues(alpha: 0.15),
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(28),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 72, height: 72,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      const Color(0xFF4ECDC4).withValues(alpha: 0.15),
                                                      const Color(0xFF006A65).withValues(alpha: 0.08),
                                                    ],
                                                  ),
                                                ),
                                                child: const Icon(Icons.camera_alt_rounded, size: 32, color: Color(0xFF4ECDC4)),
                                              ),
                                              const SizedBox(height: 16),
                                              const Text('Chụp ảnh khoảnh khắc', style: TextStyle(
                                                fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w800,
                                                color: Color(0xFF2D3436),
                                              )),
                                              const SizedBox(height: 6),
                                              Text('Lưu giữ biên lai hoặc hình ảnh món đồ bạn vừa mua.', textAlign: TextAlign.center, style: TextStyle(
                                                fontFamily: 'Inter', fontSize: 13,
                                                color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                                                height: 1.4,
                                              )),
                                              const SizedBox(height: 16),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(14),
                                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.photo_library_outlined, size: 16, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
                                                    const SizedBox(width: 6),
                                                    Text('Thư viện', style: TextStyle(
                                                      fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
                                                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                                                    )),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ═══ Amount Input ═══
                        Opacity(
                          opacity: _fadeIn.value,
                          child: Transform.translate(
                            offset: Offset(0, _slideUp.value * 0.7),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 24),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 4))],
                              ),
                              child: Row(
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: [Color(0xFF4ECDC4), Color(0xFF006A65)],
                                    ).createShader(bounds),
                                    child: const Text('đ', style: TextStyle(
                                      fontFamily: 'Manrope', fontSize: 28, fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    )),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _amountController,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'Manrope', fontSize: 40, fontWeight: FontWeight.w800,
                                        color: Color(0xFF2D3436), letterSpacing: -1,
                                      ),
                                      decoration: const InputDecoration(border: InputBorder.none),
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      onTap: () {
                                        if (_amountController.text == '0') _amountController.clear();
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text('VNĐ', style: TextStyle(
                                    fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700,
                                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                                  )),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ═══ Categories ═══
                        Opacity(
                          opacity: _fadeIn.value,
                          child: Transform.translate(
                            offset: Offset(0, _slideUp.value * 0.9),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 28),
                                  child: Text('Danh mục', style: TextStyle(
                                    fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w800,
                                    color: const Color(0xFF2D3436).withValues(alpha: 0.8),
                                  )),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 90,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    itemCount: ExpenseCategory.values.length,
                                    itemBuilder: (context, index) {
                                      final cat = ExpenseCategory.values[index];
                                      final isSelected = cat == _selectedCategory;
                                      return GestureDetector(
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          setState(() => _selectedCategory = cat);
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          width: 76,
                                          margin: const EdgeInsets.only(right: 10),
                                          decoration: BoxDecoration(
                                            color: isSelected ? cat.color.withValues(alpha: 0.12) : Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: isSelected ? cat.color : Colors.transparent,
                                              width: 2,
                                            ),
                                            boxShadow: isSelected ? [
                                              BoxShadow(color: cat.color.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4)),
                                            ] : [
                                              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(cat.icon, size: 26, color: isSelected ? cat.color : AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                                              const SizedBox(height: 6),
                                              Text(cat.label, style: TextStyle(
                                                fontFamily: 'Inter', fontSize: 11,
                                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                                color: isSelected ? cat.color : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                                              ), overflow: TextOverflow.ellipsis),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ═══ Note + Date Row ═══
                        Opacity(
                          opacity: _fadeIn.value,
                          child: Transform.translate(
                            offset: Offset(0, _slideUp.value * 1.1),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 24),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12)],
                              ),
                              child: Column(
                                children: [
                                  // Note
                                  Row(
                                    children: [
                                      Icon(Icons.edit_note_rounded, size: 22, color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller: _noteController,
                                          decoration: InputDecoration(
                                            hintText: 'Ghi chú (tuỳ chọn)',
                                            border: InputBorder.none,
                                            hintStyle: TextStyle(
                                              fontFamily: 'Inter', fontSize: 15,
                                              color: AppColors.outline.withValues(alpha: 0.4),
                                            ),
                                          ),
                                          style: const TextStyle(fontFamily: 'Inter', fontSize: 15, height: 1.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.15), height: 1),
                                  const SizedBox(height: 8),
                                  // Date
                                  GestureDetector(
                                    onTap: () async {
                                      HapticFeedback.selectionClick();
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: _selectedDate,
                                        firstDate: DateTime(2020), lastDate: DateTime.now(),
                                        builder: (context, child) => Theme(
                                          data: ThemeData.light().copyWith(
                                            colorScheme: const ColorScheme.light(primary: Color(0xFF4ECDC4)),
                                          ),
                                          child: child!,
                                        ),
                                      );
                                      if (picked != null) setState(() => _selectedDate = picked);
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today_rounded, size: 20, color: const Color(0xFF4ECDC4).withValues(alpha: 0.7)),
                                        const SizedBox(width: 10),
                                        Text(
                                          _selectedDate.day == DateTime.now().day &&
                                              _selectedDate.month == DateTime.now().month &&
                                              _selectedDate.year == DateTime.now().year
                                              ? 'Hôm nay, ${_selectedDate.day} Thg ${_selectedDate.month}'
                                              : '${_selectedDate.day} Thg ${_selectedDate.month}, ${_selectedDate.year}',
                                          style: TextStyle(
                                            fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500,
                                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.onSurfaceVariant.withValues(alpha: 0.3)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ═══ Share to Feed Toggle ═══
                        Opacity(
                          opacity: _fadeIn.value,
                          child: Transform.translate(
                            offset: Offset(0, _slideUp.value * 1.3),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 24),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: _shareToFeed
                                    ? const LinearGradient(colors: [Color(0xFFFFF5F5), Color(0xFFFFF8F0)])
                                    : null,
                                color: _shareToFeed ? null : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _shareToFeed
                                      ? const Color(0xFFFF6B6B).withValues(alpha: 0.2)
                                      : AppColors.outlineVariant.withValues(alpha: 0.15),
                                ),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8)],
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      final emojis = ['💸', '😋', '🍕', '☕', '🛒', '🎉', '🚗', '🏠', '🎮', '📚'];
                                      final idx = emojis.indexOf(_selectedEmoji);
                                      setState(() => _selectedEmoji = emojis[(idx + 1) % emojis.length]);
                                    },
                                    child: Container(
                                      width: 40, height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                                      ),
                                      child: Center(child: Text(_selectedEmoji, style: const TextStyle(fontSize: 20))),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Chia sẻ bảng tin', style: TextStyle(
                                          fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
                                        )),
                                        Text('Bạn bè sẽ thấy chi tiêu này', style: TextStyle(
                                          fontFamily: 'Inter', fontSize: 11,
                                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                                        )),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: _shareToFeed,
                                    activeColor: const Color(0xFFFF6B6B),
                                    onChanged: (v) {
                                      HapticFeedback.selectionClick();
                                      setState(() => _shareToFeed = v);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),

                  // ═══ Sticky Bottom Save Button ═══
                  Positioned(
                    left: 0, right: 0, bottom: 0,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).padding.bottom + 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        border: Border(top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.1))),
                      ),
                      child: _isUploading
                          ? Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF006A65), Color(0xFF4ECDC4)]),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Center(child: SizedBox(
                                width: 24, height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                              )),
                            )
                          : GestureDetector(
                              onTap: () async {
                                final amount = double.tryParse(
                                  _amountController.text.replaceAll('.', '').replaceAll(',', ''),
                                );
                                if (amount == null || amount <= 0) {
                                  _showPremiumToast('Nhập số tiền hợp lệ nhé!', isError: true);
                                  return;
                                }
                                HapticFeedback.heavyImpact();

                                // Capture cubit before async gap
                                final expenseCubit = context.read<ExpenseCubit>();
                                final noteText = _noteController.text;

                                String? imageUrl;
                                if (_pickedImage != null) {
                                  setState(() => _isUploading = true);
                                  try {
                                    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
                                    final ref = FirebaseStorage.instance
                                        .ref('expenses/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg');
                                    await ref.putFile(_pickedImage!);
                                    imageUrl = await ref.getDownloadURL();
                                  } catch (e) {
                                    // Continue without image
                                  }
                                  if (mounted) setState(() => _isUploading = false);
                                }

                                if (!mounted) return;
                                expenseCubit.addExpense(
                                  ExpenseEntity(
                                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                                    userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                                    amount: amount,
                                    category: _selectedCategory.name,
                                    note: noteText.isNotEmpty ? noteText : null,
                                    date: _selectedDate,
                                    imageUrl: imageUrl,
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                  ),
                                );
                                if (_shareToFeed) {
                                  expenseCubit.shareToFeed(
                                    amount: amount,
                                    category: _selectedCategory.name,
                                    note: noteText.isNotEmpty ? noteText : null,
                                    emoji: _selectedEmoji,
                                    imageUrl: imageUrl,
                                  );
                                }
                                _showPremiumToast('Đã lưu chi tiêu! 🎉');
                                await Future.delayed(const Duration(milliseconds: 500));
                                if (mounted) context.pop();
                              },
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF006A65), Color(0xFF4ECDC4)],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(color: const Color(0xFF006A65).withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                                    SizedBox(width: 10),
                                    Text('Lưu Giao Dịch', style: TextStyle(
                                      fontFamily: 'Manrope', fontSize: 17, fontWeight: FontWeight.w800,
                                      color: Colors.white, letterSpacing: 0.5,
                                    )),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
