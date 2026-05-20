import 'package:flutter/material.dart';
import '../transaction_constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final clr  = statusColor(status);
    final icon = statusIcon(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: clr.withOpacity(0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: clr.withOpacity(0.4), width: 0.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 8, color: clr),
        const SizedBox(width: 1),
        Text(status.toUpperCase(),
            style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700,
                color: clr, letterSpacing: 0.2)),
      ]),
    );
  }
}
