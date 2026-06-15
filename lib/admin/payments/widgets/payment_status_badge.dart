import 'package:flutter/material.dart';

class PaymentStatusBadge extends StatelessWidget {
  final String status;
  const PaymentStatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'PENDING': Colors.amber,
      'PAID': Colors.green,
      'FAILED': Colors.red,
      'REJECTED': Colors.grey,
      'COMPLETED': Colors.blue,
      'APPROVED': Colors.teal,
    };
    final c = colors[status.toUpperCase()] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withOpacity(0.4)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: c,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
