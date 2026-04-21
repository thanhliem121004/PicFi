import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

enum ExpenseCategory {
  food(AppStrings.catFood, Icons.restaurant, AppColors.catFood, 'assets/images/icon_food.png'),
  coffee(AppStrings.catCoffee, Icons.coffee, AppColors.catCoffee, 'assets/images/icon_coffee.png'),
  shopping(AppStrings.catShopping, Icons.shopping_bag, AppColors.catShopping, 'assets/images/icon_shopping.png'),
  transport(AppStrings.catTransport, Icons.directions_car, AppColors.catTransport, 'assets/images/icon_transport.png'),
  entertainment(AppStrings.catEntertain, Icons.sports_esports, AppColors.catEntertain, 'assets/images/icon_entertainment.png'),
  education(AppStrings.catEducation, Icons.menu_book, AppColors.catEducation, 'assets/images/icon_education.png'),
  health(AppStrings.catHealth, Icons.local_hospital, AppColors.catHealth, 'assets/images/icon_health.png'),
  gift(AppStrings.catGift, Icons.card_giftcard, AppColors.catGift, 'assets/images/icon_gift.png'),
  tech(AppStrings.catTech, Icons.phone_android, AppColors.catTech, 'assets/images/icon_tech.png'),
  housing(AppStrings.catHousing, Icons.home, AppColors.catHousing, null),
  bills(AppStrings.catBills, Icons.receipt_long, AppColors.catBills, null),
  other(AppStrings.catOther, Icons.grid_view, AppColors.catOther, null);

  const ExpenseCategory(this.label, this.icon, this.color, this.imagePath);

  final String label;
  final IconData icon;
  final Color color;
  final String? imagePath;

  /// Returns an Image widget if AI icon exists, otherwise falls back to Icon widget.
  Widget buildIcon({double size = 24, Color? iconColor}) {
    if (imagePath != null) {
      return ClipOval(
        child: Image.asset(
          imagePath!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(icon, size: size, color: iconColor ?? color),
        ),
      );
    }
    return Icon(icon, size: size, color: iconColor ?? color);
  }
}
