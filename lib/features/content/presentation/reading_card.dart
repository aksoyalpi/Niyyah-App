import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../settings/domain/display_settings.dart';
import '../domain/content_item.dart';

class ReadingCard extends StatelessWidget {
  final ContentItem item;
  final ContentStyle style;

  const ReadingCard({
    super.key,
    required this.item,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (style != ContentStyle.englishOnly && item.arabic.isNotEmpty) ...[
              Text(
                item.arabic,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 24,
                  height: 2.0,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (style != ContentStyle.arabicOnly && item.translationEn.isNotEmpty) ...[
              Text(
                item.translationEn,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              item.source,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
