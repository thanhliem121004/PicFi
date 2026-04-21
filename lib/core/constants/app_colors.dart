import 'package:flutter/material.dart';

/// PicFi Design System Colors
/// Based on Vivid Ledger design spec - Teal primary, Coral secondary
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════
  // PRIMARY - Teal (used for action states, progress, brand)
  // ═══════════════════════════════════════════════════════
  static const Color primary = Color(0xFF006A65);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF4ECDC4);
  static const Color onPrimaryContainer = Color(0xFF00544F);
  static const Color inversePrimary = Color(0xFF5DD9D0);
  static const Color primaryFixed = Color(0xFF7CF6EC);
  static const Color primaryFixedDim = Color(0xFF5DD9D0);

  // ═══════════════════════════════════════════════════════
  // SECONDARY - Coral/Salmon (expenses, "money out")
  // ═══════════════════════════════════════════════════════
  static const Color secondary = Color(0xFFAE2F34);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFF6B6B);
  static const Color onSecondaryContainer = Color(0xFF6D0010);

  // ═══════════════════════════════════════════════════════
  // TERTIARY - Orange/Amber
  // ═══════════════════════════════════════════════════════
  static const Color tertiary = Color(0xFF914C16);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFFA568);
  static const Color onTertiaryContainer = Color(0xFF783901);

  // ═══════════════════════════════════════════════════════
  // SURFACE & BACKGROUND (Light Mode)
  // ═══════════════════════════════════════════════════════
  static const Color surface = Color(0xFFF5FBF9);
  static const Color surfaceDim = Color(0xFFD5DBDA);
  static const Color surfaceBright = Color(0xFFF5FBF9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF5F3);
  static const Color surfaceContainer = Color(0xFFE9EFED);
  static const Color surfaceContainerHigh = Color(0xFFE4E9E8);
  static const Color surfaceContainerHighest = Color(0xFFDEE4E2);
  static const Color onSurface = Color(0xFF171D1C);
  static const Color onSurfaceVariant = Color(0xFF3D4948);
  static const Color inverseSurface = Color(0xFF2C3231);
  static const Color inverseOnSurface = Color(0xFFECF2F0);
  static const Color surfaceTint = Color(0xFF006A65);
  static const Color background = Color(0xFFF5FBF9);
  static const Color onBackground = Color(0xFF171D1C);

  // ═══════════════════════════════════════════════════════
  // OUTLINE
  // ═══════════════════════════════════════════════════════
  static const Color outline = Color(0xFF6C7A78);
  static const Color outlineVariant = Color(0xFFBCC9C7);

  // ═══════════════════════════════════════════════════════
  // ERROR
  // ═══════════════════════════════════════════════════════
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // ═══════════════════════════════════════════════════════
  // SEMANTIC COLORS
  // ═══════════════════════════════════════════════════════
  static const Color income = Color(0xFF2ECC71);       // Green - thu nhập
  static const Color expense = Color(0xFFFF6B6B);      // Coral - chi tiêu
  static const Color warning = Color(0xFFF1C40F);      // Yellow - cảnh báo
  static const Color success = Color(0xFF27AE60);      // Green - thành công

  // ═══════════════════════════════════════════════════════
  // CATEGORY COLORS
  // ═══════════════════════════════════════════════════════
  static const Color catFood = Color(0xFFFF6B6B);       // Ăn uống
  static const Color catTransport = Color(0xFF4ECDC4);   // Di chuyển
  static const Color catHousing = Color(0xFF45B7D1);     // Nhà cửa
  static const Color catShopping = Color(0xFFF7DC6F);    // Mua sắm
  static const Color catEntertain = Color(0xFFBB8FCE);   // Giải trí
  static const Color catEducation = Color(0xFF82E0AA);   // Học tập
  static const Color catHealth = Color(0xFFF1948A);      // Sức khỏe
  static const Color catGift = Color(0xFFF0B27A);        // Quà tặng
  static const Color catTech = Color(0xFF85C1E9);        // Công nghệ
  static const Color catCoffee = Color(0xFFA0522D);      // Cà phê
  static const Color catBills = Color(0xFF5DADE2);       // Hóa đơn
  static const Color catOther = Color(0xFFAEB6BF);       // Khác

  // ═══════════════════════════════════════════════════════
  // DARK MODE SURFACES
  // ═══════════════════════════════════════════════════════
  static const Color darkSurface = Color(0xFF0F1513);
  static const Color darkSurfaceContainer = Color(0xFF1A201F);
  static const Color darkSurfaceContainerHigh = Color(0xFF252B2A);
  static const Color darkSurfaceContainerHighest = Color(0xFF303635);
  static const Color darkOnSurface = Color(0xFFDEE4E2);
  static const Color darkOnSurfaceVariant = Color(0xFFBCC9C7);
  static const Color darkBackground = Color(0xFF0F1513);

  // ═══════════════════════════════════════════════════════
  // GRADIENT
  // ═══════════════════════════════════════════════════════
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF006A65), Color(0xFF4ECDC4)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF006A65), Color(0xFF008B85)],
  );

  static const LinearGradient loginGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD4C5A9),
      Color(0xFFE8DCC8),
      Color(0xFF8FBAB5),
      Color(0xFF5D9E97),
    ],
  );
}
