import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../blocs/auth/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _bubbleSlide;
  late Animation<double> _bubbleOpacity;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200),
    );

    _bubbleSlide = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _bubbleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.isAuthenticated) context.go('/main');
        if (state.error != null) {
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!, style: const TextStyle(fontFamily: 'Inter')),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFD4C5A9),
                Color(0xFFE8DCC8),
                Color(0xFF8FBAB5),
                Color(0xFF5D9E97),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, _) {
                    return Column(
                      children: [
                        _ChatBubble(
                          message: 'Chào mừng bạn quay lại! 👋',
                          isSent: false,
                          opacity: _bubbleOpacity.value,
                          slide: _bubbleSlide.value,
                        ),
                        const SizedBox(height: 8),
                        _ChatBubble(
                          message: 'Email của bạn là gì?',
                          isSent: true,
                          opacity: _bubbleOpacity.value,
                          slide: _bubbleSlide.value + 10,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, _) {
                    return Opacity(
                      opacity: _bubbleOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _bubbleSlide.value + 20),
                        child: _ChatTextField(
                          controller: _emailController,
                          hint: 'PicFi ID hoặc Email',
                          isEmail: true,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, _) {
                    return Opacity(
                      opacity: _bubbleOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _bubbleSlide.value + 30),
                        child: Column(
                          children: [
                            _ChatBubble(
                              message: 'Mật khẩu của bạn? 🔐',
                              isSent: true,
                              opacity: 1,
                              slide: 0,
                            ),
                            const SizedBox(height: 12),
                            _ChatTextField(
                              controller: _passwordController,
                              hint: AppStrings.password,
                              obscure: _obscurePassword,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  color: AppColors.outline, size: 20,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, _) {
                    return Opacity(
                      opacity: _bubbleOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _bubbleSlide.value + 40),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 32),
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(AppStrings.forgotPassword, style: TextStyle(
                                fontFamily: 'Inter', fontSize: 13,
                                fontWeight: FontWeight.w600, color: Colors.white70,
                              )),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, _) {
                    return Opacity(
                      opacity: _bubbleOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _bubbleSlide.value + 50),
                        child: BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                            return _SendButton(
                              label: AppStrings.login,
                              isLoading: state.isLoading,
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                context.read<AuthCubit>().signInSmart(
                                  _emailController.text.trim(),
                                  _passwordController.text,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, _) {
                    return Opacity(
                      opacity: _bubbleOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _bubbleSlide.value + 60),
                        child: GestureDetector(
                          onTap: () => context.go('/register'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(AppStrings.noAccount, style: const TextStyle(
                                  fontFamily: 'Inter', fontSize: 14,
                                  color: Colors.white70,
                                )),
                                const SizedBox(width: 6),
                                const Text(AppStrings.register, style: TextStyle(
                                  fontFamily: 'Inter', fontSize: 14,
                                  fontWeight: FontWeight.w700, color: Colors.white,
                                )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String message;
  final bool isSent;
  final double opacity;
  final double slide;

  const _ChatBubble({
    required this.message,
    required this.isSent,
    required this.opacity,
    required this.slide,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, slide),
        child: Padding(
          padding: EdgeInsets.only(
            left: isSent ? 60 : 24,
            right: isSent ? 24 : 60,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: isSent
                  ? const Color(0xFF006A65).withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(22),
                topRight: const Radius.circular(22),
                bottomLeft: Radius.circular(isSent ? 22 : 6),
                bottomRight: Radius.circular(isSent ? 6 : 22),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: isSent ? FontWeight.w500 : FontWeight.w400,
                color: isSent ? Colors.white : Colors.white.withValues(alpha: 0.9),
                height: 1.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final Widget? suffix;
  final bool isEmail;

  const _ChatTextField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.suffix,
    this.isEmail = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          keyboardType: isEmail ? TextInputType.emailAddress : null,
          obscureText: obscure,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 16, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Inter', fontSize: 15,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            suffixIcon: suffix != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: suffix,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
          cursorColor: Colors.white,
        ),
      ),
    );
  }
}

class _SendButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _SendButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          if (!widget.isLoading) widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(29),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(width: 24, height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 22),
                        const SizedBox(width: 8),
                        Text(widget.label, style: const TextStyle(
                          fontFamily: 'Manrope', fontSize: 17,
                          fontWeight: FontWeight.w700, color: Colors.white,
                        )),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
