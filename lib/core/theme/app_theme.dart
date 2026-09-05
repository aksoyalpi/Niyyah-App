import 'package:flutter/material.dart';

final class AppColors {
  static const accent = Color(0xFF2F6B4F);
  static const accentSoft = Color(0xFFE7F0EA);
  static const background = Color(0xFFFCFBF7);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF211F1C);
  static const textSecondary = Color(0xFF6F6A63);
  static const divider = Color(0xFFECE8E0);
}

final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
    ).copyWith(
      surface: AppColors.surface,
      primary: AppColors.accent,
      onSurface: AppColors.textPrimary,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.background,
        indicatorColor: AppColors.accentSoft,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        iconTheme: const WidgetStatePropertyAll(
          IconThemeData(color: AppColors.accent),
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.divider),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.textSecondary,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.accent
              : AppColors.divider,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    );
  }
}
