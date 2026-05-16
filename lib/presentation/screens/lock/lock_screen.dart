import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/lock/lock_cubit.dart';

class LockScreen extends StatefulWidget {
  final bool isSetup;
  const LockScreen({super.key, this.isSetup = false});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _pinController = TextEditingController();
  String _pin = '';
  bool _showError = false;
  bool _isFirstStep = true;
  String _firstPin = '';

  @override
  void initState() {
    super.initState();
    if (!widget.isSetup) {
      _tryBiometric();
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _tryBiometric() async {
    final result = await context.read<LockCubit>().authenticate();
    if (result && mounted) Navigator.pop(context);
  }

  void _onPinDigit(String digit) {
    if (_pin.length >= 6) return;
    setState(() {
      _pin += digit;
      _showError = false;
    });

    if (_pin.length == 6) {
      if (widget.isSetup) {
        _handleSetupPin();
      } else {
        _verifyPin();
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  Future<void> _handleSetupPin() async {
    if (_isFirstStep) {
      _firstPin = _pin;
      setState(() {
        _pin = '';
        _isFirstStep = false;
      });
    } else {
      if (_pin == _firstPin) {
        final success = await context.read<LockCubit>().setPin(_pin);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Đã đặt mã PIN!'),
            backgroundColor: Color(0xFF006A65),
            behavior: SnackBarBehavior.floating,
          ));
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _showError = true;
          _pin = '';
          _isFirstStep = true;
          _firstPin = '';
        });
      }
    }
  }

  Future<void> _verifyPin() async {
    final valid = await context.read<LockCubit>().verifyPin(_pin);
    if (valid) {
      if (mounted) Navigator.pop(context);
    } else {
      setState(() {
        _showError = true;
        _pin = '';
        HapticFeedback.heavyImpact();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSetup = widget.isSetup;
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4ECDC4).withValues(alpha: 0.1),
              ),
              child: Icon(
                isSetup ? Icons.lock_outline_rounded : Icons.lock_rounded,
                size: 36, color: const Color(0xFF4ECDC4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSetup
                  ? (_isFirstStep ? 'Đặt mã PIN' : 'Nhập lại mã PIN')
                  : 'Nhập mã PIN',
              style: const TextStyle(
                fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            if (_showError)
              const Text('Sai mã PIN, thử lại!', style: TextStyle(
                fontFamily: 'Inter', fontSize: 14, color: Color(0xFFFF6B6B),
              )),
            if (!isSetup)
              TextButton(
                onPressed: _tryBiometric,
                child: const Text('Sử dụng Face ID / Vân tay',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF4ECDC4))),
              ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) {
                final filled = i < _pin.length;
                return Container(
                  width: 16, height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled
                        ? const Color(0xFF4ECDC4)
                        : Colors.white.withValues(alpha: 0.2),
                  ),
                );
              }),
            ),
            const Spacer(flex: 2),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Row(
                    children: List.generate(3, (i) => _PinButton(
                      digit: '${i + 1}',
                      onTap: () => _onPinDigit('${i + 1}'),
                    )),
                  ),
                  Row(
                    children: List.generate(3, (i) => _PinButton(
                      digit: '${i + 4}',
                      onTap: () => _onPinDigit('${i + 4}'),
                    )),
                  ),
                  Row(
                    children: List.generate(3, (i) => _PinButton(
                      digit: '${i + 7}',
                      onTap: () => _onPinDigit('${i + 7}'),
                    )),
                  ),
                  Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      _PinButton(digit: '0', onTap: () => _onPinDigit('0')),
                      Expanded(
                        child: GestureDetector(
                          onTap: _onDelete,
                          child: Container(
                            height: 64,
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                            child: const Icon(Icons.backspace_outlined, color: Colors.white54, size: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _PinButton extends StatelessWidget {
  final String digit;
  final VoidCallback onTap;

  const _PinButton({required this.digit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () { HapticFeedback.selectionClick(); onTap(); },
        child: Container(
          height: 64,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          child: Center(
            child: Text(digit, style: const TextStyle(
              fontFamily: 'Manrope', fontSize: 26, fontWeight: FontWeight.w600,
              color: Colors.white,
            )),
          ),
        ),
      ),
    );
  }
}
