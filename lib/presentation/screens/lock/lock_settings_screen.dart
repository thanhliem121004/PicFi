import 'package:flutter/material.dart' hide LockState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import '../../blocs/lock/lock_cubit.dart';

class LockSettingsScreen extends StatefulWidget {
  const LockSettingsScreen({super.key});

  @override
  State<LockSettingsScreen> createState() => _LockSettingsScreenState();
}

class _LockSettingsScreenState extends State<LockSettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;
  bool _canCheckBiometrics = false;

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
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final can = await LocalAuthentication().canCheckBiometrics;
    if (mounted) setState(() => _canCheckBiometrics = can);
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
                    const Text('Bảo mật', style: TextStyle(
                      fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800,
                    )),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: BlocBuilder<LockCubit, LockState>(
                  builder: (context, state) {
                    final s = state;
                    return Opacity(
                      opacity: _fadeIn.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideUp.value),
                        child: Column(
                          children: [
                            Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF4ECDC4).withValues(alpha: 0.1),
                              ),
                              child: const Icon(Icons.lock_outline_rounded, size: 36, color: Color(0xFF4ECDC4)),
                            ),
                            const SizedBox(height: 16),
                            const Text('Khóa ứng dụng', style: TextStyle(
                              fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700,
                            )),
                            const SizedBox(height: 8),
                            Text('Bảo vệ dữ liệu tài chính của bạn',
                              style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.grey.shade500)),
                            const SizedBox(height: 32),

                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Column(
                                children: [
                                  SwitchListTile(
                                    title: const Text('Bật khóa ứng dụng', style: TextStyle(fontFamily: 'Inter', fontSize: 16)),
                                    value: s.isEnabled,
                                    activeThumbColor: const Color(0xFF006A65),
                                    onChanged: (val) {
                                      if (val) {
                                        context.push('/lock-setup');
                                      } else {
                                        context.read<LockCubit>().removePin();
                                      }
                                    },
                                  ),
                                  if (s.isEnabled && _canCheckBiometrics)
                                    SwitchListTile(
                                      title: const Text('Face ID / Vân tay', style: TextStyle(fontFamily: 'Inter', fontSize: 16)),
                                      subtitle: const Text('Mở khóa nhanh bằng sinh trắc học'),
                                      value: s.useBiometric,
                                      activeThumbColor: const Color(0xFF006A65),
                                      onChanged: (val) {
                                        context.read<LockCubit>().toggleBiometric(val);
                                      },
                                    ),
                                  if (s.isEnabled)
                                    ListTile(
                                      leading: const Icon(Icons.lock_reset_rounded, color: Color(0xFF006A65)),
                                      title: const Text('Đổi mã PIN', style: TextStyle(fontFamily: 'Inter', fontSize: 16)),
                                      trailing: const Icon(Icons.chevron_right_rounded),
                                      onTap: () => context.push('/lock-setup'),
                                    ),
                                ],
                              ),
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
    );
  }
}
