import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../controllers/transaction_controller.dart';
import '../../../../controllers/user_controller.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/transaction.dart';
import '../transaction_constants.dart';
import '../atoms/type_icon.dart';
import '../atoms/status_badge.dart';
import 'approve_dialog.dart';
import 'reject_dialog.dart';

void showDetailSheet(BuildContext context, Transaction tx,
    TransactionController ctrl) {
  String? name = tx.userName;
  String? contact = tx.userPhone ?? tx.userEmail;
  if (tx.userId != null && Get.isRegistered<UserController>()) {
    final user = Get.find<UserController>().findUser(tx.userId!);
    if (user != null) {
      name = user.name ?? name;
      contact = user.phoneNumber ?? contact;
    }
  }
  Get.bottomSheet(
    Container(
      decoration: const BoxDecoration(
        color: sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            decoration: BoxDecoration(
                color: cardBorder, borderRadius: BorderRadius.circular(2)),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: Column(children: [
                // Header
                _headerCard(tx),
                const SizedBox(height: 10),

                // Grid of info cards
                LayoutBuilder(builder: (_, bc) {
                  const gap = 8.0;
                  const cardW = 160.0;
                  final cols = ((bc.maxWidth + gap) / (cardW + gap)).floor().clamp(2, 4);
                  final actualW = (bc.maxWidth - gap * (cols - 1)) / cols;

                  final items = <_CardData>[
                    if (name != null)
                      _CardData(Icons.person_outline_rounded, 'User', name, sub: contact),
                    _CardData(Icons.fingerprint_rounded, 'User ID', tx.userId ?? '—', mono: true),
                    _CardData(Icons.scale_rounded, 'Grams', Formatters.formatGrams(tx.grams),
                        valueColor: const Color(0xFFD32F2F)),
                    _CardData(Icons.payments_outlined, 'Amount', Formatters.formatCurrency(tx.amountBdt),
                        bold: true),
                    _CardData(Icons.receipt_long_outlined, 'Fee',
                        '${tx.feePercent}%  ·  ${Formatters.formatCurrency(tx.feeAmount)}',
                        valueColor: const Color(0xFFD32F2F)),
                    _CardData(Icons.calendar_today_rounded, 'Created', Formatters.formatDateTime(tx.createdAt)),
                    if (tx.code != null)
                      _CardData(Icons.qr_code_rounded, 'Code', tx.code!, mono: true),
                    if (tx.approvedAt != null)
                      _CardData(Icons.check_circle_outline_rounded, 'Approved',
                          Formatters.formatDateTime(tx.approvedAt!), valueColor: colApproved),
                    if (tx.rejectedAt != null)
                      _CardData(Icons.cancel_outlined, 'Rejected',
                          Formatters.formatDateTime(tx.rejectedAt!), valueColor: colRejected),
                    if (tx.adminNote != null && tx.adminNote!.isNotEmpty)
                      _CardData(Icons.note_alt_outlined, 'Note', tx.adminNote!),
                  ];

                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: items.map((d) => SizedBox(
                      width: actualW,
                      child: _infoCard(
                        icon: d.icon,
                        label: d.label,
                        value: d.value,
                        sub: d.sub,
                        valueColor: d.valueColor,
                        bold: d.bold,
                        mono: d.mono,
                      ),
                    )).toList(),
                  );
                }),

                // Action buttons
                if (tx.status.toLowerCase() == 'pending') ...[
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.back();
                          showApproveDialog(context, tx, ctrl);
                        },
                        icon: const Icon(Icons.check_rounded, size: 15),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colApproved,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Get.back();
                          showRejectDialog(context, tx, ctrl);
                        },
                        icon: const Icon(Icons.close_rounded, size: 15),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colRejected,
                          side: const BorderSide(color: colRejected),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ]),
                ],
              ]),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 6),
        ]),
      ),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _CardData {
  final IconData icon;
  final String label, value;
  final String? sub;
  final Color? valueColor;
  final bool bold, mono;
  _CardData(this.icon, this.label, this.value,
      {this.sub, this.valueColor, this.bold = false, this.mono = false});
}

Widget _headerCard(Transaction tx) => Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  decoration: BoxDecoration(
    color: cardBg,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: cardBorder),
  ),
  child: Row(children: [
    TypeIcon(type: tx.type, size: 36),
    const SizedBox(width: 10),
    Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(typeLabel(tx.type),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                color: typeColor(tx.type))),
        const SizedBox(height: 2),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: tx.id));
            Get.snackbar('Copied', 'ID copied', duration: const Duration(seconds: 1));
          },
          child: Text(tx.id,
              style: const TextStyle(fontSize: 10, color: textMuted, fontFamily: 'monospace'),
              overflow: TextOverflow.ellipsis),
        ),
      ]),
    ),
    StatusBadge(status: tx.status),
  ]),
);

Widget _infoCard({
  required IconData icon,
  required String label,
  required String value,
  String? sub,
  Color? valueColor,
  bool bold = false,
  bool mono = false,
}) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cardBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Icon(icon, size: 13, color: textSec),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(fontSize: 9, color: textSec,
                  fontWeight: FontWeight.w600, letterSpacing: 0.2)),
        ]),
        const SizedBox(height: 3),
        Text(value,
            style: TextStyle(fontSize: 11.5, color: valueColor ?? textPri,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                fontFamily: mono ? 'monospace' : null),
            overflow: TextOverflow.ellipsis,
            maxLines: 2),
        if (sub != null) ...[
          const SizedBox(height: 1),
          Text(sub,
              style: const TextStyle(fontSize: 10, color: textMuted),
              overflow: TextOverflow.ellipsis),
        ],
      ]),
    );
