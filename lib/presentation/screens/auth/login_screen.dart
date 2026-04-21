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
  late AnimationController _pulseController;
  late Animation<double> _illustrationScale;
  late Animation<double> _illustrationOpacity;
  late Animation<double> _formSlide;
  late Animation<double> _formOpacity;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400),
    );
    _pulseController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _illustrationScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0, 0.5, curve: Curves.elasticOut)),
    );
    _illustrationOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0, 0.3, curve: Curves.easeOut)),
    );
    _formSlide = Tween<double>(begin: 80, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.25, 0.7, curve: Curves.easeOutCubic)),
    );
    _formOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.25, 0.6, curve: Curves.easeOut)),
    );
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    _pulseController.dispose();
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
          animation: Listenable.merge([_animController, _pulseController]),
          builder: (context, _) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF0FBF9),
                    Color(0xFFFFF8F0),
                    Color(0xFFF5F0FF),
                    Color(0xFFEFF5F3),
                  ],
                  stops: [0.0, 0.3, 0.6, 1.0],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // ═══ Animated Illustration ═══
                      Opacity(
                        opacity: _illustrationOpacity.value,
                        child: Transform.scale(
                          scale: _illustrationScale.value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Glowing background
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, _) => Container(
                                  width: 220 * _pulse.value,
                                  height: 220 * _pulse.value,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        AppColors.primary.withValues(alpha: 0.08),
                                        AppColors.primary.withValues(alpha: 0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Illustration
                              ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.asset(
                                  'assets/images/auth_illustration.png',
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 200, height: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF006A65), Color(0xFF4ECDC4)],
                                      ),
                                    ),
                                    child: const Icon(Icons.photo_camera_rounded, size: 80, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ═══ Welcome Text ═══
                      Opacity(
                        opacity: _illustrationOpacity.value,
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFF006A65), Color(0xFF4ECDC4), Color(0xFFFF6B6B)],
                              ).createShader(bounds),
                              child: const Text(
                                AppStrings.appName,
                                style: TextStyle(
                                  fontFamily: 'Manrope', fontSize: 38,
                                  fontWeight: FontWeight.w800, color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppStrings.loginWelcome,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter', fontSize: 15,
                                color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

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
                                  color: AppColors.primary.withValues(alpha: 0.06),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Email
                                _VibrantTextField(
                                  controller: _emailController,
                                  hint: 'PicFi ID hoặc Email',
                                  icon: Icons.alternate_email_rounded,
                                  iconColor: const Color(0xFF4ECDC4),
                                ),
                                const SizedBox(height: 14),
                                // Password
                                _VibrantTextField(
                                  controller: _passwordController,
                                  hint: AppStrings.password,
                                  icon: Icons.lock_outline_rounded,
                                  iconColor: const Color(0xFFFF6B6B),
                                  obscure: _obscurePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                      color: AppColors.outline, size: 22,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: const Text(AppStrings.forgotPassword, style: TextStyle(
                                      fontFamily: 'Inter', fontSize: 14,
                                      fontWeight: FontWeight.w600, color: AppColors.primary,
                                    )),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Login button
                                BlocBuilder<AuthCubit, AuthState>(
                                  builder: (context, state) {
                                    return _EnergyButton(
                                      label: AppStrings.login,
                                      isLoading: state.isLoading,
                                      gradient: const [Color(0xFF006A65), Color(0xFF4ECDC4)],
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
                                const SizedBox(height: 18),
                                // Divider
                                Row(
                                  children: [
                                    Expanded(child: Container(height: 1, color: AppColors.outlineVariant.withValues(alpha: 0.3))),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF7F9F8),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(AppStrings.or, style: TextStyle(
                                          fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500,
                                          color: AppColors.outline,
                                        )),
                                      ),
                                    ),
                                    Expanded(child: Container(height: 1, color: AppColors.outlineVariant.withValues(alpha: 0.3))),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                // Google button
                                _SocialButton(
                                  label: AppStrings.googleSignIn,
                                  icon: Icons.g_mobiledata_rounded,
                                  iconBgColor: const Color(0xFFFF6B6B),
                                  onTap: () => context.read<AuthCubit>().signInWithGoogle(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ═══ Register link ═══
                      Opacity(
                        opacity: _formOpacity.value,
                        child: GestureDetector(
                          onTap: () => context.go('/register'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(AppStrings.noAccount, style: TextStyle(
                                  fontFamily: 'Inter', fontSize: 15,
                                  color: AppColors.onSurfaceVariant,
                                )),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF006A65), Color(0xFF4ECDC4)],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(AppStrings.register, style: TextStyle(
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
// VIBRANT REUSABLE WIDGETS
// ═══════════════════════════════════════════════════════
class _VibrantTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color iconColor;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffixIcon;

  const _VibrantTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.iconColor,
    this.keyboardType,
    this.obscure = false,
    this.suffixIcon,
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

class _EnergyButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _EnergyButton({
    required this.label,
    required this.isLoading,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_EnergyButton> createState() => _EnergyButtonState();
}

class _EnergyButtonState extends State<_EnergyButton>
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
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.gradient,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: widget.gradient[0].withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Shimmer overlay
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
                            Text(widget.label, style: const TextStyle(
                              fontFamily: 'Manrope', fontSize: 18,
                              fontWeight: FontWeight.w700, color: Colors.white,
                            )),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
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

class _SocialButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color iconBgColor;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.iconBgColor,
    required this.onTap,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: widget.iconBgColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, size: 24, color: widget.iconBgColor),
              ),
              const SizedBox(width: 12),
              Text(widget.label, style: const TextStyle(
                fontFamily: 'Inter', fontSize: 16,
                fontWeight: FontWeight.w600, color: AppColors.onSurface,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
