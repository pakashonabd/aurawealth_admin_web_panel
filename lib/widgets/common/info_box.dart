import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class InfoBox extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Color? color;
  final InfoBoxType type;

  const InfoBox({
    Key? key,
    required this.message,
    this.icon,
    this.color,
    this.type = InfoBoxType.info,
  }) : super(key: key);

  const InfoBox.info({
    Key? key,
    required String message,
    IconData? icon,
  }) : this(
          key: key,
          message: message,
          icon: icon ?? Icons.info_outline,
          type: InfoBoxType.info,
        );

  const InfoBox.success({
    Key? key,
    required String message,
    IconData? icon,
  }) : this(
          key: key,
          message: message,
          icon: icon ?? Icons.check_circle_outline,
          type: InfoBoxType.success,
        );

  const InfoBox.warning({
    Key? key,
    required String message,
    IconData? icon,
  }) : this(
          key: key,
          message: message,
          icon: icon ?? Icons.warning_amber_outlined,
          type: InfoBoxType.warning,
        );

  const InfoBox.error({
    Key? key,
    required String message,
    IconData? icon,
  }) : this(
          key: key,
          message: message,
          icon: icon ?? Icons.error_outline,
          type: InfoBoxType.error,
        );

  @override
  Widget build(BuildContext context) {
    final boxColor = color ?? _getColorForType();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: boxColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: boxColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? _getIconForType(),
            color: boxColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: boxColor.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForType() {
    switch (type) {
      case InfoBoxType.success:
        return AppColors.success;
      case InfoBoxType.warning:
        return AppColors.warning;
      case InfoBoxType.error:
        return AppColors.error;
      case InfoBoxType.info:
      default:
        return AppColors.info;
    }
  }

  IconData _getIconForType() {
    switch (type) {
      case InfoBoxType.success:
        return Icons.check_circle_outline;
      case InfoBoxType.warning:
        return Icons.warning_amber_outlined;
      case InfoBoxType.error:
        return Icons.error_outline;
      case InfoBoxType.info:
      default:
        return Icons.info_outline;
    }
  }
}

enum InfoBoxType {
  info,
  success,
  warning,
  error,
}
