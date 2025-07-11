import 'package:flutter/material.dart';

/// ویجت محافظ سایز صفحه
/// اگر سایز صفحه کوچکتر از مقدار تعیین‌شده باشد، پیام خطا نمایش می‌دهد
/// مقادیر برای حالت عمودی و افقی جداگانه قابل تنظیم هستند
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
          child: Text(
            'این سایز از صفحه پشتیبانی نمی‌شود',
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    }
    return child;
  }
}
