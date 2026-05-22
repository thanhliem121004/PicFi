import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../home/home_screen.dart';
import '../feed/feed_screen.dart';
import '../stats/statistics_screen.dart';
import '../profile/profile_screen.dart';
import '../../blocs/connectivity/connectivity_cubit.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final List<Widget> _screens;
  late AnimationController _fabController;
  late AnimationController _fabPulse;
  late Animation<double> _fabScale;
  late Animation<double> _pulse;

  static const _navColors = [
    Color(0xFF006A65), // Home - teal
    Color(0xFF4ECDC4), // History - cyan
    Color(0xFF006A65), // FAB
    Color(0xFF9B59B6), // Stats - purple
    Color(0xFFFF6B6B), // Profile - coral
  ];

  @override
  void initState() {
    super.initState();
    _screens = const [
      HomeScreen(),
      FeedScreen(),
      SizedBox(),
      StatisticsScreen(),
      ProfileScreen(),
    ];
    _fabController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    );
    _fabPulse = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fabScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
    _pulse = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _fabPulse, curve: Curves.easeInOut),
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _fabPulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, connState) {
        return Scaffold(
          body: Column(
            children: [
              if (!connState.isOnline)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF8C1520), const Color(0xFF733600)]
                          : [const Color(0xFFFF6B6B), const Color(0xFFF0B27A)],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        const Icon(Icons.wifi_off_rounded, size: 16, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppStrings.offlineMode,
                            style: const TextStyle(
                              fontFamily: 'Inter', fontSize: 13,
                              fontWeight: FontWeight.w600, color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          AppStrings.offlineHint,
                          style: TextStyle(
                            fontFamily: 'Inter', fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.02),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey<int>(_currentIndex),
                    child: _screens[_currentIndex],
                  ),
                ),
              ),
            ],
          ),
          extendBody: true,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F1413).withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: (isDark ? Colors.white : const Color(0xFF006A65))
                        .withValues(alpha: 0.12),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _VibrantNavItem(
                      icon: Icons.home_rounded,
                      label: AppStrings.home,
                      color: _navColors[0],
                      isActive: _currentIndex == 0,
                      onTap: () => _switchTab(0),
                    ),
                    _VibrantNavItem(
                      icon: Icons.dynamic_feed_rounded,
                      label: 'Bảng tin',
                      color: _navColors[1],
                      isActive: _currentIndex == 1,
                      onTap: () => _switchTab(1),
                    ),
                    // Center FAB
                    AnimatedBuilder(
                      animation: Listenable.merge([_fabController, _fabPulse]),
                      builder: (context, _) {
                        return Transform.scale(
                          scale: _fabScale.value,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              context.push('/add-expense');
                            },
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF006A65), Color(0xFF4ECDC4)],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF006A65).withValues(alpha: 0.35),
                                    blurRadius: 14 * _pulse.value,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                            ),
                          ),
                        );
                      },
                    ),
                    _VibrantNavItem(
                      icon: Icons.bar_chart_rounded,
                      label: AppStrings.charts,
                      color: _navColors[3],
                      isActive: _currentIndex == 3,
                      onTap: () => _switchTab(3),
                    ),
                    _VibrantNavItem(
                      icon: Icons.person_rounded,
                      label: AppStrings.profile,
                      color: _navColors[4],
                      isActive: _currentIndex == 4,
                      onTap: () => _switchTab(4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
        },
    );
  }

  void _switchTab(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }
}

class _VibrantNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _VibrantNavItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isActive ? 1.12 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: isActive ? 14 : 0,
                  vertical: isActive ? 5 : 3,
                ),
                decoration: BoxDecoration(
                  color: isActive ? color.withValues(alpha: 0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: isActive ? 24 : 22,
                  color: isActive ? color : AppColors.outline,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isActive ? 11 : 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? color : AppColors.outline,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
