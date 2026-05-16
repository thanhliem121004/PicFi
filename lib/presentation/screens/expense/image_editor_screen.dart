import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/entities/expense_entity.dart';

class ImageEditorScreen extends StatefulWidget {
  final String imagePath;
  final String? emoji;

  const ImageEditorScreen({
    super.key,
    required this.imagePath,
    this.emoji,
  });

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  late ExpenseOverlayConfig _config;
  Offset _chipPosition = const Offset(0.1, 0.7); // % position
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _showBottomSheet = true;
  final FocusNode _textFocus = FocusNode();

  static const List<int> _colorOptions = [
    0xFFFFFFFF,
    0xFF000000,
    0xFFFF6B6B,
    0xFF4ECDC4,
    0xFFFFD93D,
    0xFF6BCB77,
    0xFF9B59B6,
    0xFFFF9F43,
    0xFF74B9FF,
    0xFFFF6B9D,
  ];

  @override
  void initState() {
    super.initState();
    _config = const ExpenseOverlayConfig();
    _textController.text = '';
  }

  @override
  void dispose() {
    _textController.dispose();
    _amountController.dispose();
    _textFocus.dispose();
    super.dispose();
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: _textController.text);
        return AlertDialog(
          title: const Text('Ghi chú', style: TextStyle(
            fontFamily: 'Manrope', fontWeight: FontWeight.w800,
          )),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 16, height: 1.5),
            decoration: InputDecoration(
              hintText: 'Viết gì đó...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _textController.text = controller.text.trim());
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006A65),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Lưu', style: TextStyle(color: Colors.white)),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        );
      },
    );
  }

  void _saveAndReturn() {
    Navigator.pop(context, {
      'overlayConfig': _config,
      'note': _textController.text.trim().isEmpty ? null : _textController.text.trim(),
      'amount': _amountController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background photo ──
          Image.file(
            File(widget.imagePath),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[900],
              child: const Center(
                child: Icon(Icons.broken_image_rounded, color: Colors.white54, size: 64),
              ),
            ),
          ),

          // ── Draggable text chip ──
          _DraggableTextChip(
            position: _chipPosition,
            text: _textController.text,
            config: _config,
            emoji: widget.emoji,
            onPositionChanged: (newPos) {
              setState(() => _chipPosition = newPos);
              _config = _config.copyWith(
                left: newPos.dx,
                top: newPos.dy,
              );
            },
            onTap: _showEditDialog,
          ),

          // ── Tap to add text hint (if no text) ──
          if (_textController.text.isEmpty)
            Positioned(
              bottom: 120,
              left: 0, right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _showEditDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_rounded, size: 18, color: Colors.white70),
                        SizedBox(width: 8),
                        Text('Nhấn để viết ghi chú', style: TextStyle(
                          fontFamily: 'Inter', fontSize: 14,
                          fontWeight: FontWeight.w600, color: Colors.white70,
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ── Top bar ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12, right: 12,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _saveAndReturn,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF006A65), Color(0xFF4ECDC4)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text('Xong', style: TextStyle(
                          fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w700,
                          color: Colors.white,
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom toolbar ──
          if (_showBottomSheet)
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: _EditorBottomSheet(
                config: _config,
                colorOptions: _colorOptions,
                amountController: _amountController,
                onConfigChanged: (newConfig) {
                  setState(() => _config = newConfig);
                },
              ),
            ),

          // ── Toggle toolbar button ──
          Positioned(
            right: 12,
            bottom: _showBottomSheet
                ? MediaQuery.of(context).padding.bottom + 160
                : MediaQuery.of(context).padding.bottom + 20,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _showBottomSheet = !_showBottomSheet);
              },
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _showBottomSheet
                      ? Colors.white
                      : Colors.black.withValues(alpha: 0.6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Icon(
                  _showBottomSheet
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.tune_rounded,
                  color: _showBottomSheet ? Colors.black : Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
class _DraggableTextChip extends StatefulWidget {
  final Offset position;
  final String text;
  final ExpenseOverlayConfig config;
  final String? emoji;
  final Function(Offset) onPositionChanged;
  final VoidCallback onTap;

  const _DraggableTextChip({
    required this.position,
    required this.text,
    required this.config,
    this.emoji,
    required this.onPositionChanged,
    required this.onTap,
  });

  @override
  State<_DraggableTextChip> createState() => _DraggableTextChipState();
}

class _DraggableTextChipState extends State<_DraggableTextChip> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const chipWidth = 200.0;
        const chipHeight = 60.0;

        final absoluteX = widget.position.dx * constraints.maxWidth;
        final absoluteY = widget.position.dy * constraints.maxHeight;

        final clampedX = absoluteX.clamp(0.0, constraints.maxWidth - chipWidth);
        final clampedY = absoluteY.clamp(0.0, constraints.maxHeight - chipHeight);

        return Positioned(
          left: clampedX,
          top: clampedY,
          child: GestureDetector(
            onPanUpdate: (details) {
              final newX = (clampedX + details.delta.dx) / constraints.maxWidth;
              final newY = (clampedY + details.delta.dy) / constraints.maxHeight;
              widget.onPositionChanged(
                Offset(
                  newX.clamp(0.0, 1.0),
                  newY.clamp(0.0, 1.0),
                ),
              );
            },
            onPanEnd: (_) {
              HapticFeedback.lightImpact();
            },
            onTap: widget.onTap,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.emoji != null && widget.emoji!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(widget.emoji!, style: TextStyle(fontSize: widget.config.fontSize * 1.2)),
                    ),
                  if (widget.text.isNotEmpty)
                    Text(
                      widget.text,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: widget.config.fontSize * 0.8,
                        fontWeight: FontWeight.w600,
                        color: widget.config.color,
                        shadows: widget.config.shadow
                            ? [const Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 1))]
                            : null,
                      ),
                      maxLines: 3,
                    )
                  else
                    Text(
                      'Nhấn để viết...',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: widget.config.fontSize * 0.6,
                        fontStyle: FontStyle.italic,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════
class _EditorBottomSheet extends StatelessWidget {
  final ExpenseOverlayConfig config;
  final List<int> colorOptions;
  final TextEditingController amountController;
  final Function(ExpenseOverlayConfig) onConfigChanged;

  const _EditorBottomSheet({
    required this.config,
    required this.colorOptions,
    required this.amountController,
    required this.onConfigChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // ── Amount input ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: 'Nhập số tiền',
                hintStyle: TextStyle(
                  fontFamily: 'Inter', fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 6),
                  child: Text('₫', style: TextStyle(
                    fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.6),
                  )),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text('Màu chữ', style: TextStyle(
            fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600,
            color: Colors.white60,
          )),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: colorOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final colorVal = colorOptions[index];
                final isSelected = config.colorValue == colorVal;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onConfigChanged(config.copyWith(colorValue: colorVal));
                  },
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Color(colorVal),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.white30,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: Color(colorVal).withValues(alpha: 0.5), blurRadius: 8)]
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 18,
                            color: colorVal == 0xFFFFFFFF ? Colors.black : Colors.white,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              const Text('Cỡ chữ', style: TextStyle(
                fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600,
                color: Colors.white60,
              )),
              const SizedBox(width: 8),
              Text('${config.fontSize.toInt()}', style: const TextStyle(
                fontFamily: 'Manrope', fontSize: 12, fontWeight: FontWeight.w700,
                color: Colors.white,
              )),
              const Spacer(),
              _ToggleChip(
                label: 'Bold',
                icon: Icons.format_bold_rounded,
                isActive: config.bold,
                onTap: () => onConfigChanged(config.copyWith(bold: !config.bold)),
              ),
              const SizedBox(width: 8),
              _ToggleChip(
                label: 'Shadow',
                icon: Icons.blur_on_rounded,
                isActive: config.shadow,
                onTap: () => onConfigChanged(config.copyWith(shadow: !config.shadow)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF4ECDC4),
              inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
              thumbColor: const Color(0xFF4ECDC4),
              overlayColor: const Color(0xFF4ECDC4).withValues(alpha: 0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: config.fontSize,
              min: 14,
              max: 48,
              onChanged: (v) => onConfigChanged(config.copyWith(fontSize: v)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4ECDC4).withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? const Color(0xFF4ECDC4) : Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isActive ? const Color(0xFF4ECDC4) : Colors.white54),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(
              fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600,
              color: isActive ? const Color(0xFF4ECDC4) : Colors.white54,
            )),
          ],
        ),
      ),
    );
  }
}
