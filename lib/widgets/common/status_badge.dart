import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final IconData? icon;
  final bool outlined;
  final double? fontSize;

  const StatusBadge({
    Key? key,
    required this.text,
    this.color,
    this.icon,
    this.outlined = false,
    this.fontSize,
  }) : super(key: key);

  const StatusBadge.success({
    Key? key,
    required String text,
    IconData? icon,
    bool outlined = false,
  }) : this(
          key: key,
          text: text,
          color: AppColors.success,
          icon: icon,
          outlined: outlined,
        );

  const StatusBadge.warning({
    Key? key,
    required String text,
    IconData? icon,
    bool outlined = false,
  }) : this(
          key: key,
          text: text,
          color: AppColors.warning,
          icon: icon,
          outlined: outlined,
        );

  const StatusBadge.error({
    Key? key,
    required String text,
    IconData? icon,
    bool outlined = false,
  }) : this(
          key: key,
          text: text,
          color: AppColors.error,
          icon: icon,
          outlined: outlined,
        );

  const StatusBadge.info({
    Key? key,
    required String text,
    IconData? icon,
    bool outlined = false,
  }) : this(
          key: key,
          text: text,
          color: AppColors.info,
          icon: icon,
          outlined: outlined,
        );

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? AppColors.grey600;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: outlined ? Border.all(color: badgeColor, width: 1.5) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: badgeColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}

class CountBadge extends StatelessWidget {
  final int count;
  final Color? backgroundColor;
  final Color? textColor;
  final double size;

  const CountBadge({
    Key? key,
    required this.count,
    this.backgroundColor,
    this.textColor,
    this.size = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.error,
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? AppColors.error).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: TextStyle(
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
            color: textColor ?? Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }
}
