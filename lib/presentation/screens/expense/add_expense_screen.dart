import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      // ═══ Sticky Header ═══
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Center(
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainerLow,
              ),
              child: const Icon(Icons.close_rounded, color: AppColors.onSurface, size: 22),
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          AppStrings.addExpense,
          style: TextStyle(
            fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _entryController,
        builder: (context, _) {
          return Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // ═══ Amount Input ═══
                    Opacity(
                      opacity: _fadeIn.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideUp.value * 0.5),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                                  child: const Text('₫', style: TextStyle(
                                    fontFamily: 'Manrope', fontSize: 28, fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  )),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 200,
                                  child: TextField(
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Manrope', fontSize: 42, fontWeight: FontWeight.w800,
                                      color: AppColors.primary, letterSpacing: -1,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Animated underline
                            Container(
                              width: 120, height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0),
                                    AppColors.primary.withValues(alpha: 0.3),
                                    AppColors.primary.withValues(alpha: 0),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ═══ Photo Upload (Locket-style) ═══
                    Opacity(
                      opacity: _fadeIn.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideUp.value * 0.8),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          height: MediaQuery.of(context).size.width - 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Inner dashed border
                              Positioned.fill(
                                child: Container(
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: AppColors.outlineVariant.withValues(alpha: 0.4),
                                      width: 2,
                                      strokeAlign: BorderSide.strokeAlignInside,
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 68, height: 68,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppColors.primaryContainer.withValues(alpha: 0.3),
                                            AppColors.primaryContainer.withValues(alpha: 0.15),
                                          ],
                                        ),
                                      ),
                                      child: const Icon(Icons.photo_camera_rounded, size: 32, color: AppColors.primary),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(AppStrings.capturePhoto, style: TextStyle(
                                      fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                    )),
                                    const SizedBox(height: 6),
                                    Text(AppStrings.capturePhotoHint, textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Inter', fontSize: 14,
                                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.75),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Gallery chip
                              Positioned(
                                bottom: 16, right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainer,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add_photo_alternate_rounded, size: 16, color: AppColors.onSurfaceVariant),
                                      const SizedBox(width: 6),
                                      Text(AppStrings.gallery, style: TextStyle(
                                        fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3, color: AppColors.onSurfaceVariant,
                                      )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ═══ Category Selector ═══
                    Opacity(
                      opacity: _fadeIn.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideUp.value),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Text(AppStrings.category, style: TextStyle(
                                fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w700,
                              )),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 92,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: ExpenseCategory.values.length,
                                itemBuilder: (context, index) {
                                  final cat = ExpenseCategory.values[index];
                                  final isSelected = _selectedCategory == cat;
                                  return GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() => _selectedCategory = cat);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeOutCubic,
                                      width: 72,
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      child: Column(
                                        children: [
                                          AnimatedContainer(
                                            duration: const Duration(milliseconds: 250),
                                            curve: Curves.easeOutCubic,
                                            width: 56, height: 56,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isSelected ? cat.color : AppColors.surfaceContainerHigh,
                                              border: isSelected
                                                  ? Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2)
                                                  : Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                                              boxShadow: isSelected ? [
                                                BoxShadow(
                                                  color: cat.color.withValues(alpha: 0.35),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ] : null,
                                            ),
                                            child: Icon(
                                              cat.icon, size: 24,
                                              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            cat.label,
                                            style: TextStyle(
                                              fontFamily: 'Inter', fontSize: 11,
                                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                              letterSpacing: 0.3,
                                              color: isSelected ? cat.color : AppColors.onSurfaceVariant,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
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
                    const SizedBox(height: 20),

                    // ═══ Date & Note Card ═══
                    Opacity(
                      opacity: _fadeIn.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideUp.value * 1.2),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Column(
                              children: [
                                // Date row
                                GestureDetector(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                    );
                                    if (picked != null) setState(() => _selectedDate = picked);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 42, height: 42,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.primaryContainer.withValues(alpha: 0.2),
                                          ),
                                          child: const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.primary),
                                        ),
                                        const SizedBox(width: 14),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(AppStrings.transactionDate, style: TextStyle(
                                              fontFamily: 'Inter', fontSize: 13,
                                              color: AppColors.onSurfaceVariant,
                                            )),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Hôm nay, ${_selectedDate.day} Thg ${_selectedDate.month}',
                                              style: const TextStyle(
                                                fontFamily: 'Inter', fontSize: 16,
                                                fontWeight: FontWeight.w600, color: AppColors.onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        const Icon(Icons.chevron_right_rounded, color: AppColors.outlineVariant),
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(height: 1, indent: 20, endIndent: 20,
                                  color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                                // Note row
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 42, height: 42,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.tertiaryContainer.withValues(alpha: 0.2),
                                        ),
                                        child: const Icon(Icons.edit_note_rounded, size: 20, color: AppColors.tertiary),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: TextField(
                                          controller: _noteController,
                                          maxLines: 3,
                                          decoration: InputDecoration(
                                            hintText: AppStrings.addNote,
                                            border: InputBorder.none,
                                            hintStyle: TextStyle(
                                              fontFamily: 'Inter', fontSize: 15,
                                              color: AppColors.outline.withValues(alpha: 0.5),
                                            ),
                                            contentPadding: const EdgeInsets.only(top: 10),
                                          ),
                                          style: const TextStyle(
                                            fontFamily: 'Inter', fontSize: 15,
                                            color: AppColors.onSurface, height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ═══ Share to Feed Toggle ═══
                    Opacity(
                      opacity: _fadeIn.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideUp.value * 1.4),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: _shareToFeed
                                ? const LinearGradient(
                                    colors: [Color(0xFFFFF0F0), Color(0xFFFFF8F0)],
                                  )
                                : null,
                            color: _shareToFeed ? null : AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: _shareToFeed
                                  ? const Color(0xFFFF6B6B).withValues(alpha: 0.2)
                                  : AppColors.outlineVariant.withValues(alpha: 0.2),
                            ),
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
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                                  ),
                                  child: Center(child: Text(_selectedEmoji, style: const TextStyle(fontSize: 22))),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Chia sẻ lên bảng tin', style: TextStyle(
                                      fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600,
                                    )),
                                    Text('Bạn bè sẽ thấy chi tiêu của bạn', style: TextStyle(
                                      fontFamily: 'Inter', fontSize: 12,
                                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                                    )),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _shareToFeed,
                                activeTrackColor: const Color(0xFFFF6B6B),
                                onChanged: (val) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _shareToFeed = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),

              // ═══ Sticky Bottom Save Button ═══
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.85),
                    border: Border(top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.2))),
                  ),
                  child: _SaveButton(
                    onTap: () {
                      final amount = double.tryParse(
                        _amountController.text.replaceAll('.', '').replaceAll(',', ''),
                      );
                      if (amount == null || amount <= 0) return;
                      HapticFeedback.heavyImpact();
                      context.read<ExpenseCubit>().addExpense(
                        ExpenseEntity(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          userId: FirebaseAuth.instance.currentUser?.uid ?? '', amount: amount,
                          category: _selectedCategory.name,
                          note: _noteController.text.isNotEmpty ? _noteController.text : null,
                          date: _selectedDate,
                          createdAt: DateTime.now(), updatedAt: DateTime.now(),
                        ),
                      );
                      // Share to feed if toggled on
                      if (_shareToFeed) {
                        context.read<ExpenseCubit>().shareToFeed(
                          amount: amount,
                          category: _selectedCategory.name,
                          note: _noteController.text.isNotEmpty ? _noteController.text : null,
                          emoji: _selectedEmoji,
                        );
                      }
                      context.pop();
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SaveButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SaveButton({required this.onTap});

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(AppStrings.saveTransaction, style: TextStyle(
                fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700,
                color: Colors.white,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
