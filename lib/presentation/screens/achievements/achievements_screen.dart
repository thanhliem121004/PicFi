import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/gamification/gamification_cubit.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _slideUp = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
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
            colors: [Color(0xFFF0FBF9), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white,
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                      ),
                    ),
                    const Spacer(),
                    const Text('Thành tựu', style: TextStyle(
                      fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800,
                    )),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              BlocBuilder<GamificationCubit, GamificationState>(
                builder: (context, state) {
                  return Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Opacity(
                            opacity: _fadeIn.value,
                            child: Transform.translate(
                              offset: Offset(0, _slideUp.value * 0.5),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF006A65), Color(0xFF4ECDC4)],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  children: [
                                    const Text('🏆', style: TextStyle(fontSize: 36)),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${state.unlockedCount}/${state.totalCount}', style: const TextStyle(
                                          fontFamily: 'Manrope', fontSize: 28, fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        )),
                                        Text('Thành tựu đã đạt được', style: TextStyle(
                                          fontFamily: 'Inter', fontSize: 13,
                                          color: Colors.white.withValues(alpha: 0.8),
                                        )),
                                      ],
                                    ),
                                    const Spacer(),
                                    SizedBox(
                                      width: 60, height: 60,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          SizedBox(
                                            width: 60, height: 60,
                                            child: CircularProgressIndicator(
                                              value: state.totalCount > 0
                                                  ? state.unlockedCount / state.totalCount
                                                  : 0,
                                              strokeWidth: 5,
                                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          ),
                                          Text(
                                            '${(state.totalCount > 0 ? (state.unlockedCount / state.totalCount * 100).round() : 0)}%',
                                            style: const TextStyle(
                                              fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w800,
                                              color: Colors.white,
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
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),

                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final ach = state.achievements[index];
                                final delay = index * 0.05;
                                return Opacity(
                                  opacity: _fadeIn.value,
                                  child: Transform.translate(
                                    offset: Offset(0, _slideUp.value * (1 + delay)),
                                    child: _AchievementCard(achievement: ach),
                                  ),
                                );
                              },
                              childCount: state.achievements.length,
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 40)),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final dynamic achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final ach = achievement;
    final unlocked = ach.unlocked as bool;
    final progress = ach.progress as int;
    final maxProgress = ach.maxProgress as int;
    final pct = maxProgress > 0 ? progress / maxProgress : 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked
            ? const Color(0xFFF0FBF9)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: unlocked
              ? const Color(0xFF4ECDC4).withValues(alpha: 0.3)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(ach.icon as String, style: TextStyle(
            fontSize: 32,
            color: unlocked ? null : Colors.grey,
          )),
          const SizedBox(height: 8),
          Text(ach.title as String, style: TextStyle(
            fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
            color: unlocked ? const Color(0xFF006A65) : Colors.grey.shade600,
          ), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(ach.description as String, style: TextStyle(
            fontFamily: 'Inter', fontSize: 10,
            color: Colors.grey.shade500,
          ), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          if (!unlocked)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 4,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4ECDC4)),
              ),
            ),
          if (!unlocked)
            const SizedBox(height: 4),
          Text(
            unlocked ? 'Đã đạt được! 🎉' : '$progress/$maxProgress',
            style: TextStyle(
              fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600,
              color: unlocked ? const Color(0xFF006A65) : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
