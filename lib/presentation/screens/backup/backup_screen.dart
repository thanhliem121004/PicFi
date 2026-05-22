import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/backup/backup_cubit.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen>
    with SingleTickerProviderStateMixin {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          child: BlocConsumer<BackupCubit, BackupState>(
            listener: (context, state) {
              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.error!, style: const TextStyle(fontFamily: 'Inter')),
                  backgroundColor: const Color(0xFFFF6B6B),
                  behavior: SnackBarBehavior.floating,
                ));
              }
              if (state.successMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.successMessage!, style: const TextStyle(fontFamily: 'Inter')),
                  backgroundColor: const Color(0xFF006A65),
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
            builder: (context, state) {
              return Column(
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
                        const Text('Sao lưu dữ liệu', style: TextStyle(
                          fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800,
                        )),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Opacity(
                        opacity: _fadeIn.value,
                        child: Transform.translate(
                          offset: Offset(0, _slideUp.value),
                          child: Column(
                            children: [
                              Container(
                                width: 80, height: 80,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF006A65), Color(0xFF4ECDC4)],
                                  ),
                                ),
                                child: const Icon(Icons.cloud_upload_rounded, size: 36, color: Colors.white),
                              ),
                              const SizedBox(height: 16),
                              const Text('Mã hóa AES-256', style: TextStyle(
                                fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700,
                              )),
                              const SizedBox(height: 8),
                              Text(
                                'Dữ liệu được mã hóa trước khi tải lên đám mây',
                                style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.grey.shade500),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),

                              if (state.lastBackupDate != null)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4ECDC4).withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFF4ECDC4).withValues(alpha: 0.15)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, color: Color(0xFF4ECDC4), size: 22),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Lần sao lưu cuối: ${_formatDate(state.lastBackupDate!)}',
                                          style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF006A65)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (state.lastBackupDate != null) const SizedBox(height: 20),

                              TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Mật khẩu mã hóa',
                                  prefixIcon: const Icon(Icons.lock_rounded),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _confirmPasswordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Nhập lại mật khẩu',
                                  prefixIcon: const Icon(Icons.lock_rounded),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                child: GestureDetector(
                                  onTap: state.isLoading ? null : () => _doBackup(),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [Color(0xFF006A65), Color(0xFF4ECDC4)]),
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(color: const Color(0xFF006A65).withValues(alpha: 0.25), blurRadius: 12),
                                      ],
                                    ),
                                    child: state.isLoading
                                        ? const Center(child: SizedBox(
                                            width: 22, height: 22,
                                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                          ))
                                        : const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 22),
                                              SizedBox(width: 8),
                                              Text('Sao lưu', style: TextStyle(
                                                fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white,
                                              )),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              SizedBox(
                                width: double.infinity,
                                child: GestureDetector(
                                  onTap: state.isLoading ? null : () => _doRestore(),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: const Color(0xFF006A65).withValues(alpha: 0.2)),
                                    ),
                                    child: state.isLoading
                                        ? const Center(child: SizedBox(
                                            width: 22, height: 22,
                                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF006A65)),
                                          ))
                                        : const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.cloud_download_rounded, color: Color(0xFF006A65), size: 22),
                                              SizedBox(width: 8),
                                              Text('Khôi phục', style: TextStyle(
                                                fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF006A65),
                                              )),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              const Divider(height: 1, color: Color(0xFFE0E0E0)),
                              const SizedBox(height: 24),
                              
                              // Section for Database Reset & Mock Data Seeding
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF4D4D).withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFFF4D4D).withValues(alpha: 0.15)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.warning_amber_rounded, color: Color(0xFFFF4D4D), size: 24),
                                        SizedBox(width: 8),
                                        Text(
                                          'Khu vực nguy hiểm',
                                          style: TextStyle(
                                            fontFamily: 'Manrope',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFFFF4D4D),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Hành động này sẽ xóa toàn bộ giao dịch, ví, ngân sách, mục tiêu tích lũy hiện tại của bạn trên Firestore và thiết lập lại dữ liệu mẫu chất lượng cao.',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: GestureDetector(
                                        onTap: state.isLoading ? null : () => _confirmAndClearData(),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF4D4D),
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFFF4D4D).withValues(alpha: 0.25),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: state.isLoading
                                              ? const Center(
                                                  child: SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )
                                              : const Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Làm sạch & Cài dữ liệu mẫu',
                                                      style: TextStyle(
                                                        fontFamily: 'Manrope',
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w800,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ),
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
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _doBackup() {
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    if (password.isEmpty || confirm.isEmpty) {
      _showError('Vui lòng nhập mật khẩu');
      return;
    }
    if (password != confirm) {
      _showError('Mật khẩu không khớp');
      return;
    }
    if (password.length < 6) {
      _showError('Mật khẩu phải có ít nhất 6 ký tự');
      return;
    }
    HapticFeedback.mediumImpact();
    context.read<BackupCubit>().backup(password);
  }

  void _doRestore() {
    final password = _passwordController.text;
    if (password.isEmpty) {
      _showError('Vui lòng nhập mật khẩu');
      return;
    }
    HapticFeedback.mediumImpact();
    context.read<BackupCubit>().restore(password);
  }

  void _confirmAndClearData() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFFF4D4D), size: 28),
              SizedBox(width: 8),
              Text(
                'Xác nhận dọn dẹp',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: const Text(
            'Hành động này sẽ xoá sạch mọi dữ liệu ví, giao dịch, ngân sách, mục tiêu tích lũy của bạn trên Firestore và tạo lại dữ liệu mẫu chất lượng cao. Bạn có chắc chắn muốn tiếp tục không?',
            style: TextStyle(fontFamily: 'Inter', height: 1.4, fontSize: 14),
          ),
          actionsPadding: const EdgeInsets.only(right: 16, bottom: 16, left: 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Hủy',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                HapticFeedback.mediumImpact();
                context.read<BackupCubit>().clearAndSeedData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4D4D),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text(
                'Đồng ý xóa & tạo lại',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Inter')),
      backgroundColor: const Color(0xFFFF6B6B),
      behavior: SnackBarBehavior.floating,
    ));
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} ${dt.day}/${dt.month}/${dt.year}';
  }
}
