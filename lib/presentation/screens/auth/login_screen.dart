import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../blocs/auth/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showForgotPasswordDialog() {
    HapticFeedback.mediumImpact();
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Quên mật khẩu',
          style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 20)),
        content: TextField(
          controller: emailCtrl,
          decoration: InputDecoration(
            hintText: 'Nhập email của bạn',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            onPressed: () async {
              final email = emailCtrl.text.trim();
              if (email.isEmpty) return;
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(ctx);
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                navigator.pop();
                messenger.showSnackBar(SnackBar(
                  content: const Text('Đã gửi email đặt lại mật khẩu!'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ));
              } catch (e) {
                messenger.showSnackBar(SnackBar(
                  content: Text('Lỗi: $e'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ));
              }
            },
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword && _obscurePassword,
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: TextStyle(color: Colors.black87.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.black38),
              prefixIcon: Icon(prefixIcon, color: AppColors.primary.withValues(alpha: 0.8)),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.primary.withValues(alpha: 0.8),
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              errorStyle: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
            ),
            validator: validator,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String text, String iconPath, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // For placeholder, we use generic icons if image isn't available, but we assume assets exist
                // Or just use Icons for now to ensure it works
                Icon(iconPath == 'google' ? Icons.g_mobiledata_rounded : Icons.apple, size: 32, color: Colors.black87),
                const SizedBox(width: 8),
                Text(text, style: const TextStyle(fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
              ],
            ),
          ),
        ),
      ),
    );
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
              content: Text(state.error!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.loginGradient,
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset('assets/images/auth_illustration.png',
                          width: 260, height: 200, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 120, height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 60),
                          ),
                        ),
                      ).animate().fade(duration: 600.ms).scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
                      
                      const SizedBox(height: 24),
                      const Text('Chào mừng trở lại',
                        style: TextStyle(fontFamily: 'Manrope', fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Colors.black87),
                      ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
                      
                      const SizedBox(height: 8),
                      Text('Quản lý tài chính cá nhân thông minh',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: Colors.black87.withValues(alpha: 0.7)),
                      ).animate().fade(delay: 300.ms).slideY(begin: 0.2, end: 0),
                      
                      const SizedBox(height: 40),
                      
                      _buildGlassTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        hintText: 'example@email.com',
                        prefixIcon: Icons.email_outlined,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập email' : null,
                      ).animate().fade(delay: 400.ms).slideX(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 16),
                      
                      _buildGlassTextField(
                        controller: _passwordController,
                        labelText: 'Mật khẩu',
                        hintText: '••••••••',
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập mật khẩu' : null,
                      ).animate().fade(delay: 500.ms).slideX(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: Text(AppStrings.forgotPassword,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary.withValues(alpha: 0.9))),
                        ),
                      ).animate().fade(delay: 600.ms),
                      
                      const SizedBox(height: 20),
                      
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF006A65), Color(0xFF008B85)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                )
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: state.isLoading ? null : () {
                                if (_formKey.currentState!.validate()) {
                                  HapticFeedback.mediumImpact();
                                  context.read<AuthCubit>().signInSmart(
                                    _emailController.text.trim(),
                                    _passwordController.text,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: state.isLoading
                                ? const SizedBox(width: 24, height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                : const Text('Đăng nhập',
                                    style: TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                          );
                        },
                      ).animate().fade(delay: 700.ms).scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack),
                      
                      const SizedBox(height: 28),
                      
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.black87.withValues(alpha: 0.2))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Hoặc', style: TextStyle(color: Colors.black87.withValues(alpha: 0.6), fontWeight: FontWeight.w600)),
                          ),
                          Expanded(child: Divider(color: Colors.black87.withValues(alpha: 0.2))),
                        ],
                      ).animate().fade(delay: 800.ms),
                      
                      const SizedBox(height: 24),
                      
                      Row(
                        children: [
                          Expanded(child: _buildSocialButton('Google', 'google', () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng sắp ra mắt!')));
                          })),
                          const SizedBox(width: 16),
                          Expanded(child: _buildSocialButton('Apple', 'apple', () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng sắp ra mắt!')));
                          })),
                        ],
                      ).animate().fade(delay: 900.ms).slideY(begin: 0.2, end: 0),
                      
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Chưa có tài khoản?',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: Colors.black87.withValues(alpha: 0.7), fontWeight: FontWeight.w500)),
                          TextButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              context.push('/register');
                            },
                            child: const Text('Đăng ký',
                              style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary)),
                          ),
                        ],
                      ).animate().fade(delay: 1000.ms),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
