import 'package:flutter/material.dart';
import '../../../../models/transaction.dart';
import '../../../../controllers/transaction_controller.dart';
import '../transaction_constants.dart';
import '../dialogs/approve_dialog.dart';
import '../dialogs/reject_dialog.dart';

class ActionButtons extends StatelessWidget {
  final Transaction tx;
  final TransactionController ctrl;
  const ActionButtons({super.key, required this.tx, required this.ctrl});

  @override
  Widget build(BuildContext context) =>
      Column(mainAxisSize: MainAxisSize.min, children: [
        _ActionBtn(
          label: 'Approve',
          icon: Icons.check_rounded,
          color: colApproved,
          onTap: () => showApproveDialog(context, tx, ctrl),
        ),
        const SizedBox(height: 4),
        _ActionBtn(
          label: 'Reject',
          icon: Icons.close_rounded,
          color: colRejected,
          filled: false,
          onTap: () => showRejectDialog(context, tx, ctrl),
        ),
      ]);
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11,
            color: filled ? Colors.white : color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 10,
                fontWeight: FontWeight.w700,
                color: filled ? Colors.white : color)),
      ]),
    ),
  );
}
