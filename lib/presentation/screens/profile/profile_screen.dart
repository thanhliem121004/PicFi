import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../blocs/auth/auth_cubit.dart';
import '../../blocs/theme/theme_cubit.dart';
import '../../blocs/locale/locale_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cá nhân'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar & Name
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    (user?.displayName ?? user?.email ?? '?')[0].toUpperCase(),
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Text(user?.displayName ?? 'Người dùng', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                if (user?.email != null) Text(user!.email!, style: const TextStyle(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Menu items
          _buildMenuItem(Icons.repeat, 'Chi tiêu định kỳ', () => context.push('/recurring')),
          _buildMenuItem(Icons.savings, 'Mục tiêu tiết kiệm', () => context.push('/savings')),
          _buildMenuItem(Icons.backup, 'Sao lưu & Khôi phục', () => context.push('/backup')),
          const Divider(height: 32),
          _buildMenuItem(Icons.friends, 'Bạn bè', () => context.push('/friends')),
          _buildMenuItem(Icons.bar_chart, 'Thống kê', () => context.push('/stats')),
          const Divider(height: 32),
          _buildLanguagePicker(),
          const Divider(height: 32),
          _buildMenuItem(Icons.dark_mode, 'Chế độ tối', null, trailing: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) => Switch(
              value: mode == ThemeMode.dark,
              onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
            ),
          )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.read<AuthCubit>().signOut(),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400, padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback? onTap, {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }

  Widget _buildLanguagePicker() {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return ListTile(
          leading: const Icon(Icons.language, color: AppColors.primary),
          title: const Text('Ngôn ngữ', style: TextStyle(fontWeight: FontWeight.w600)),
          trailing: DropdownButton<String>(
            value: localeState.localeCode,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (code) {
              if (code != null) context.read<LocaleCubit>().setLocale(code);
            },
          ),
        );
      },
    );
  }
}
