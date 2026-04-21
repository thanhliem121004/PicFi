import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _floatController;
  late Animation<double> _floatAnim;

  final _pages = const [
    _OnboardingData(
      icon: Icons.auto_stories_rounded,
      title: AppStrings.onboardingTitle1,
      description: AppStrings.onboardingDesc1,
      gradient: [Color(0xFF006A65), Color(0xFF4ECDC4)],
      secondaryIcon: Icons.camera_alt_rounded,
      accentColor: AppColors.primaryContainer,
      imagePath: 'assets/images/onboarding_1.png',
    ),
    _OnboardingData(
      icon: Icons.bar_chart_rounded,
      title: AppStrings.onboardingTitle2,
      description: AppStrings.onboardingDesc2,
      gradient: [Color(0xFF4ECDC4), Color(0xFF45B7D1)],
      secondaryIcon: Icons.pie_chart_rounded,
      accentColor: Color(0xFF45B7D1),
      imagePath: 'assets/images/onboarding_2.png',
    ),
    _OnboardingData(
      icon: Icons.people_alt_rounded,
      title: AppStrings.onboardingTitle3,
      description: AppStrings.onboardingDesc3,
      gradient: [Color(0xFFF0B27A), Color(0xFFFF6B6B)],
      secondaryIcon: Icons.local_fire_department_rounded,
      accentColor: Color(0xFFFF6B6B),
      imagePath: 'assets/images/onboarding_3.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5FBF9), Color(0xFFEFF5F3)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        AppStrings.skip,
                        style: TextStyle(
                          fontFamily: 'Inter', fontSize: 15,
                          fontWeight: FontWeight.w500, color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return AnimatedBuilder(
                      animation: _floatController,
                      builder: (context, _) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Illustration area with glassmorphism
                              Transform.translate(
                                offset: Offset(0, _floatAnim.value),
                                child: Container(
                                  width: double.infinity,
                                  height: 360,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        page.gradient[0].withValues(alpha: 0.08),
                                        page.gradient[1].withValues(alpha: 0.04),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: page.gradient[0].withValues(alpha: 0.12),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: page.gradient[0].withValues(alpha: 0.06),
                                        blurRadius: 40,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 20),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Background orbs
                                      Positioned(
                                        top: 30,
                                        right: 40,
                                        child: Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                page.gradient[1].withValues(alpha: 0.15),
                                                page.gradient[1].withValues(alpha: 0),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 50,
                                        left: 30,
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                page.gradient[0].withValues(alpha: 0.12),
                                                page.gradient[0].withValues(alpha: 0),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Main icon - AI illustration
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.asset(
                                          page.imagePath,
                                          width: 180,
                                          height: 180,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 96, height: 96,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: page.gradient,
                                              ),
                                            ),
                                            child: Icon(page.icon, size: 44, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      // Floating mini cards
                                      if (index == 0) ...[
                                        Positioned(
                                          bottom: 40,
                                          right: 28,
                                          child: _FloatingCard(
                                            icon: Icons.coffee_rounded,
                                            label: 'CÀ PHÊ',
                                            value: '45.000đ',
                                            color: AppColors.catCoffee,
                                          ),
                                        ),
                                        Positioned(
                                          top: 50,
                                          left: 20,
                                          child: _FloatingCard(
                                            icon: Icons.restaurant_rounded,
                                            label: 'ĂN UỐNG',
                                            value: '85.000đ',
                                            color: AppColors.catFood,
                                          ),
                                        ),
                                      ],
                                      if (index == 2) ...[
                                        Positioned(
                                          top: 40,
                                          right: 30,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.06),
                                                  blurRadius: 12,
                                                ),
                                              ],
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text('🔥', style: TextStyle(fontSize: 18)),
                                                SizedBox(width: 6),
                                                Text('7 ngày', style: TextStyle(
                                                  fontFamily: 'Manrope', fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                )),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 48),

                              // Title
                              Text(
                                page.title,
                                style: const TextStyle(
                                  fontFamily: 'Manrope', fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.onSurface,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  page.description,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Inter', fontSize: 16,
                                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.85),
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Indicators + Button
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
                child: Column(
                  children: [
                    // Animated indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) {
                        final isActive = _currentPage == i;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 32 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: isActive
                                ? LinearGradient(colors: _pages[_currentPage].gradient)
                                : null,
                            color: isActive ? null : AppColors.outlineVariant.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),
                    // CTA Button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _pages[_currentPage].gradient,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _pages[_currentPage].gradient[0].withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage < _pages.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOutCubic,
                              );
                            } else {
                              context.go('/login');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage < _pages.length - 1
                                    ? AppStrings.next : AppStrings.getStarted,
                                style: const TextStyle(
                                  fontFamily: 'Manrope', fontSize: 18,
                                  fontWeight: FontWeight.w700, color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _FloatingCard({
    required this.icon, required this.label,
    required this.value, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          )),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(
            fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w800,
          )),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;
  final IconData secondaryIcon;
  final Color accentColor;
  final String imagePath;

  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
    required this.secondaryIcon,
    required this.accentColor,
    required this.imagePath,
  });
}
