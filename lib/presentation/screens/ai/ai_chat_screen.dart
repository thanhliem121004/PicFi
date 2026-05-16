import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/expense_categories.dart';
import '../../../core/constants/app_strings.dart';
import '../../blocs/ai/ai_cubit.dart';
import '../../blocs/premium/premium_cubit.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    context.read<AICubit>().sendMessage(text);
    _scrollToBottom();
  }

  void _showPremiumRequired() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Tính năng này yêu cầu gói Premium'),
      backgroundColor: const Color(0xFFFF6B6B),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      action: SnackBarAction(
        label: 'Nâng cấp',
        textColor: Colors.white,
        onPressed: () => context.push('/premium'),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<PremiumCubit>().state.isPremium;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF4ECDC4), Color(0xFF006A65)],
                ),
              ),
              child: const Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text('AI Trợ lý'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<AICubit>().clearMessages(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!isPremium)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Nâng cấp Premium để dùng AI không giới hạn!', style: TextStyle(
                      fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white,
                    )),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/premium'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Xem', style: TextStyle(
                        fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white,
                      )),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: BlocBuilder<AICubit, AIState>(
              builder: (context, state) {
                if (state.messages.isEmpty) {
                  return _buildWelcome();
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  physics: const BouncingScrollPhysics(),
                  itemCount: state.messages.length + (state.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.messages.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 60),
                        child: LinearProgressIndicator(color: AppColors.primary),
                      );
                    }
                    final msg = state.messages[index];
                    return _buildMessageBubble(msg);
                  },
                );
              },
            ),
          ),
          if (isPremium) _buildQuickActions(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFF4ECDC4), Color(0xFF006A65)]),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
                  blurRadius: 20, offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.chat_rounded, size: 36, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text('Trợ lý tài chính AI', style: TextStyle(
            fontFamily: 'Manrope', fontSize: 24, fontWeight: FontWeight.w800,
          )),
          const SizedBox(height: 8),
          Text(
            'Hỏi tôi về chi tiêu, tiết kiệm,\nngân sách và nhiều hơn nữa!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter', fontSize: 15,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          _buildSuggestionChip('Tôi đã tiêu bao nhiêu tháng này?'),
          const SizedBox(height: 8),
          _buildSuggestionChip('Làm sao để tiết kiệm tiền?'),
          const SizedBox(height: 8),
          _buildSuggestionChip('Phân tích chi tiêu ăn uống'),
          const SizedBox(height: 8),
          _buildSuggestionChip('Tự động phân loại chi tiêu'),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        final cubit = context.read<AICubit>();
        if (text.contains('Tự động phân loại')) {
          _showAutoCategorizeDialog();
          return;
        }
        cubit.sendMessage(text.replaceAll('Tự động phân loại', 'Phân loại chi tiêu'));
        _scrollToBottom();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: const TextStyle(
              fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500,
            ))),
            Icon(Icons.arrow_upward_rounded, size: 16, color: AppColors.primary.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: msg.isUser
              ? AppColors.primary
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: msg.isUser ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight: msg.isUser ? const Radius.circular(4) : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: (msg.isUser ? AppColors.primary : AppColors.outlineVariant).withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(msg.text, style: TextStyle(
              fontFamily: 'Inter', fontSize: 15,
              fontWeight: FontWeight.w400,
              color: msg.isUser ? Colors.white : AppColors.onSurface,
              height: 1.4,
            )),
            const SizedBox(height: 4),
            Text(
              '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontFamily: 'Inter', fontSize: 11,
                color: msg.isUser ? Colors.white.withValues(alpha: 0.6) : AppColors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _QuickActionButton(
            icon: Icons.auto_awesome_rounded,
            label: 'Phân loại',
            onTap: () {
              HapticFeedback.lightImpact();
              _showAutoCategorizeDialog();
            },
          ),
          const SizedBox(width: 8),
          _QuickActionButton(
            icon: Icons.insights_rounded,
            label: 'Phân tích',
            onTap: () {
              HapticFeedback.lightImpact();
              context.read<AICubit>().getInsights('');
              _scrollToBottom();
            },
          ),
        ],
      ),
    );
  }

  void _showAutoCategorizeDialog() {
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
            const Text('Phân loại chi tiêu tự động', style: TextStyle(
              fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w800,
            )),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Nhập ghi chú...',
                prefixIcon: Icon(Icons.notes_rounded, color: AppColors.primary.withValues(alpha: 0.5)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Số tiền (₫)',
                prefixIcon: Icon(Icons.monetization_on_rounded, color: AppColors.primary.withValues(alpha: 0.5)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  final note = _noteController.text.trim();
                  final amount = double.tryParse(_amountController.text.replaceAll(',', '').replaceAll('.', ''));
                  if (note.isNotEmpty && amount != null) {
                    context.read<AICubit>().autoCategorize(note, amount);
                    Navigator.pop(ctx);
                    _noteController.clear();
                    _amountController.clear();
                    _scrollToBottom();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF006A65), Color(0xFF4ECDC4)]),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(child: Text('Phân loại', style: TextStyle(
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

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, MediaQuery.of(context).viewInsets.bottom + 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
              ),
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFF006A65), Color(0xFF4ECDC4)]),
              ),
              child: const Icon(Icons.send_rounded, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon, required this.label, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(
              fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
            )),
          ],
        ),
      ),
    );
  }
}
