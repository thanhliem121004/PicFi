import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../blocs/auth/auth_cubit.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _picfiIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animController;
  late AnimationController _floatController;
  late Animation<double> _headerSlide;
  late Animation<double> _headerOpacity;
  late Animation<double> _formSlide;
  late Animation<double> _formOpacity;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400),
    );
    _floatController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _headerSlide = Tween<double>(begin: -40, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0, 0.4, curve: Curves.easeOutCubic)),
    );
    _headerOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0, 0.3, curve: Curves.easeOut)),
    );
    _formSlide = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic)),
    );
    _formOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.2, 0.6, curve: Curves.easeOut)),
    );
    _float = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _picfiIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    _floatController.dispose();
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
        body: AnimatedBuilder(
          animation: Listenable.merge([_animController, _floatController]),
          builder: (context, _) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFFFFF0F0),
                    Color(0xFFF0FBF9),
                    Color(0xFFF5F0FF),
                    Color(0xFFEFF5F3),
                  ],
                  stops: [0.0, 0.35, 0.65, 1.0],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      // ═══ Top bar with back button ═══
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                                  ],
                                ),
                                child: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface, size: 22),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ═══ Floating illustration area ═══
                      Opacity(
                        opacity: _headerOpacity.value,
                        child: Transform.translate(
                          offset: Offset(0, _headerSlide.value + _float.value),
                          child: Column(
                            children: [
                              // Floating decorative cards
                              SizedBox(
                                height: 140,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Main illustration
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: Image.asset(
                                        'assets/images/auth_illustration.png',
                                        width: 140, height: 140,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 140, height: 140,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(24),
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFFFF6B6B), Color(0xFFF0B27A)],
                                            ),
                                          ),
                                          child: const Icon(Icons.person_add_rounded, size: 60, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    // Floating badge - camera
                                    Positioned(
                                      top: 5,
                                      right: 80,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10),
                                          ],
                                        ),
                                        child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF4ECDC4), size: 18),
                                      ),
                                    ),
                                    // Floating badge - fire
                                    Positioned(
                                      bottom: 5,
                                      left: 80,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10),
                                          ],
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('🔥', style: TextStyle(fontSize: 14)),
                                            SizedBox(width: 4),
                                            Text('Streak', style: TextStyle(
                                              fontFamily: 'Inter', fontSize: 12,
                                              fontWeight: FontWeight.w700, color: AppColors.onSurface,
                                            )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Color(0xFFFF6B6B), Color(0xFF006A65), Color(0xFF4ECDC4)],
                                ).createShader(bounds),
                                child: const Text(
                                  'Tham gia PicFi!',
                                  style: TextStyle(
                                    fontFamily: 'Manrope', fontSize: 32,
                                    fontWeight: FontWeight.w800, color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                AppStrings.registerWelcome,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter', fontSize: 15,
                                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ═══ Form Card ═══
                      Opacity(
                        opacity: _formOpacity.value,
                        child: Transform.translate(
                          offset: Offset(0, _formSlide.value),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.06),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Name field
                                _VibrantField(
                                  controller: _nameController,
                                  hint: AppStrings.fullName,
                                  icon: Icons.person_outline_rounded,
                                  iconColor: const Color(0xFFFF6B6B),
                                ),
                                const SizedBox(height: 14),
                                // PicFi ID field
                                _VibrantField(
                                  controller: _picfiIdController,
                                  hint: 'PicFi ID (vd: tung.nguyen)',
                                  icon: Icons.fingerprint_rounded,
                                  iconColor: const Color(0xFF006A65),
                                ),
                                const SizedBox(height: 14),
                                // Email field
                                _VibrantField(
                                  controller: _emailController,
                                  hint: AppStrings.email,
                                  icon: Icons.mail_outline_rounded,
                                  iconColor: const Color(0xFF4ECDC4),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 14),
                                // Password field
                                _VibrantField(
                                  controller: _passwordController,
                                  hint: AppStrings.password,
                                  icon: Icons.lock_outline_rounded,
                                  iconColor: const Color(0xFF9B59B6),
                                  obscure: _obscurePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                      color: AppColors.outline, size: 22,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Register button
                                BlocBuilder<AuthCubit, AuthState>(
                                  builder: (context, state) {
                                    return _CoralButton(
                                      label: 'Tạo tài khoản',
                                      isLoading: state.isLoading,
                                      onTap: () {
                                        HapticFeedback.mediumImpact();
                                        context.read<AuthCubit>().signUp(
                                          _nameController.text.trim(),
                                          _emailController.text.trim(),
                                          _passwordController.text,
                                          _picfiIdController.text.trim(),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ═══ Login link ═══
                      Opacity(
                        opacity: _formOpacity.value,
                        child: GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(AppStrings.hasAccount, style: TextStyle(
                                  fontFamily: 'Inter', fontSize: 15,
                                  color: AppColors.onSurfaceVariant,
                                )),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFF6B6B), Color(0xFFF0B27A)],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(AppStrings.login, style: TextStyle(
                                    fontFamily: 'Inter', fontSize: 14,
                                    fontWeight: FontWeight.w700, color: Colors.white,
                                  )),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
class _VibrantField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color iconColor;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffixIcon;

  const _VibrantField({
    required this.controller, required this.hint,
    required this.icon, required this.iconColor,
    this.keyboardType, this.obscure = false, this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        style: const TextStyle(fontFamily: 'Inter', fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 60),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: iconColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          hintStyle: TextStyle(
            fontFamily: 'Inter', fontSize: 15,
            color: AppColors.outline.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

class _CoralButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;
  const _CoralButton({required this.label, required this.isLoading, required this.onTap});
  @override
  State<_CoralButton> createState() => _CoralButtonState();
}

class _CoralButtonState extends State<_CoralButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedBuilder(
          animation: _shimmer,
          builder: (context, _) => Container(
            width: double.infinity, height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFF0B27A)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0),
                        Colors.white.withValues(alpha: 0.15),
                        Colors.white.withValues(alpha: 0),
                      ],
                      stops: [
                        (_shimmer.value - 0.3).clamp(0.0, 1.0),
                        _shimmer.value.clamp(0.0, 1.0),
                        (_shimmer.value + 0.3).clamp(0.0, 1.0),
                      ],
                    ).createShader(bounds),
                    blendMode: BlendMode.srcATop,
                    child: Container(color: Colors.transparent, width: double.infinity, height: 58),
                  ),
                ),
                Center(
                  child: widget.isLoading
                      ? const SizedBox(width: 24, height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(widget.label, style: const TextStyle(
                              fontFamily: 'Manrope', fontSize: 18,
                              fontWeight: FontWeight.w700, color: Colors.white,
                            )),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
