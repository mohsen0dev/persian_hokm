import 'package:flutter/material.dart';

/// ویجت آیتم لیست کارت
/// این ویجت برای نمایش یک آیتم لیست با قابلیت انیمیشن و آیکون استفاده می‌شود.
/// [text] متن آیتم
/// [onTap] تابع اجرا شونده هنگام کلیک
/// [icon] آیکون اختیاری
/// [color] رنگ اصلی
/// [dark] حالت تیره
class CardListItem extends StatelessWidget {
  final String text;
  final Function? onTap;
  final IconData? icon;
  final Color color;
  final bool dark;

  const CardListItem({
    super.key,
    required this.text,
    this.onTap,
    this.icon,
    required this.color,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        width: (MediaQuery.of(context).size.width * 0.03) + 220,
        height: 60,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: dark
              ? const Color(0xFF232526).withOpacity(0.92)
              : Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: color,
            width: 1.2,
          ),
        ),
        child: CustomBTN(color: color, onTap: onTap, icon: icon, text: text),
      ),
    );
  }
}

class CustomBTN extends StatelessWidget {
  const CustomBTN({
    super.key,
    required this.color,
    required this.onTap,
    required this.icon,
    required this.text,
  });

  final Color color;
  final Function? onTap;
  final IconData? icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        splashColor: color.withOpacity(0.3),
        highlightColor: color.withOpacity(0.1),
        onTap: onTap != null ? () => onTap!() : null,
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              icon == null
                  ? const SizedBox()
                  : Icon(Icons.arrow_back_ios_new_rounded,
                      size: 16, color: color),
              Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontFamily: 'Vazirmatn',
                ),
              ),
              icon == null
                  ? const SizedBox()
                  : Icon(icon, color: color, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}
