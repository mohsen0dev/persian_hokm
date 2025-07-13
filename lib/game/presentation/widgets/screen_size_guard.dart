import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ویجت محافظ سایز صفحه
/// اگر سایز صفحه کوچکتر از مقدار تعیین‌شده باشد، پیام خطا نمایش می‌دهد
/// مقادیر برای حالت عمودی و افقی جداگانه قابل تنظیم هستند
/// در موبایل این کنترل نادیده گرفته می‌شود
class ScreenSizeGuard extends StatelessWidget {
  final Widget child;

  /// حداقل عرض و ارتفاع در حالت عمودی
  final double minPortraitWidth;
  final double minPortraitHeight;

  /// حداقل عرض و ارتفاع در حالت افقی
  final double minLandscapeWidth;
  final double minLandscapeHeight;

  const ScreenSizeGuard({
    super.key,
    required this.child,
    this.minPortraitWidth = 400,
    this.minPortraitHeight = 500,
    this.minLandscapeWidth = 500,
    this.minLandscapeHeight = 400,
  });

  @override
  Widget build(BuildContext context) {
    // اگر پلتفرم موبایل باشد، کنترل سایز را نادیده بگیر
    if (GetPlatform.isMobile) {
      return child;
    }

    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    final minWidth = orientation == Orientation.portrait
        ? minPortraitWidth
        : minLandscapeWidth;
    final minHeight = orientation == Orientation.portrait
        ? minPortraitHeight
        : minLandscapeHeight;

    if (size.width < minWidth || size.height < minHeight) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.screen_lock_rotation,
                  size: 64,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 16),
                Text(
                  'این سایز از صفحه پشتیبانی نمی‌شود',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'حداقل سایز مورد نیاز: ${minWidth.toInt()} × ${minHeight.toInt()}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return child;
  }
}
