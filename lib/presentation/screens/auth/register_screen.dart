import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_cubit.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _picfiIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _picfiIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            context.pop();
                          },
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ).animate().fade(duration: 400.ms).slideX(begin: -0.2, end: 0),
                      
                      const SizedBox(height: 16),
                      const Text('Tạo tài khoản',
                        style: TextStyle(fontFamily: 'Manrope', fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Colors.black87),
                      ).animate().fade(delay: 100.ms).slideY(begin: 0.2, end: 0),
                      
                      const SizedBox(height: 8),
                      Text('Điền thông tin để tham gia PicFi',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: Colors.black87.withValues(alpha: 0.7)),
                      ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
                      
                      const SizedBox(height: 36),
                      
                      _buildGlassTextField(
                        controller: _nameController,
                        labelText: 'Họ và tên',
                        hintText: 'Nguyễn Văn A',
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập tên' : null,
                      ).animate().fade(delay: 300.ms).slideX(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 16),
                      
                      _buildGlassTextField(
                        controller: _picfiIdController,
                        labelText: 'PicFi ID',
                        hintText: 'tung.nguyen',
                        prefixIcon: Icons.alternate_email_rounded,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập PicFi ID' : null,
                      ).animate().fade(delay: 400.ms).slideX(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 16),
                      
                      _buildGlassTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        hintText: 'example@email.com',
                        prefixIcon: Icons.email_outlined,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
                          if (!v.contains('@')) return 'Email không hợp lệ';
                          return null;
                        },
                      ).animate().fade(delay: 500.ms).slideX(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 16),
                      
                      _buildGlassTextField(
                        controller: _passwordController,
                        labelText: 'Mật khẩu',
                        hintText: 'Tối thiểu 6 ký tự',
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
                          if (v.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
                          return null;
                        },
                      ).animate().fade(delay: 600.ms).slideX(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 32),
                      
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
                                  context.read<AuthCubit>().signUp(
                                    _nameController.text.trim(),
                                    _emailController.text.trim(),
                                    _passwordController.text,
                                    _picfiIdController.text.trim(),
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
                                : const Text('Đăng ký ngay',
                                    style: TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                          );
                        },
                      ).animate().fade(delay: 700.ms).scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack),
                      
                      const SizedBox(height: 24),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Đã có tài khoản?',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: Colors.black87.withValues(alpha: 0.7), fontWeight: FontWeight.w500)),
                          TextButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              context.go('/login');
                            },
                            child: const Text('Đăng nhập',
                              style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary)),
                          ),
                        ],
                      ).animate().fade(delay: 800.ms),
                      const SizedBox(height: 40),
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
