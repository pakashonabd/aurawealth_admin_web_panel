import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../controllers/transaction_controller.dart';
import '../../../../controllers/user_controller.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/transaction.dart';
import './transaction_constants.dart';
import 'atoms/type_icon.dart';
import 'atoms/status_badge.dart';
import 'atoms/action_buttons.dart';
import 'dialogs/detail_sheet.dart';

class DesktopTable extends StatelessWidget {
  final List<Transaction> transactions;
  final TransactionController ctrl;
  const DesktopTable(
      {super.key, required this.transactions, required this.ctrl});

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (_, bc) {
        final w = bc.maxWidth - 32;
        const fTx = 17, fUser = 16, fStatus = 11, fGrams = 9;
        const fAmt = 13, fFee = 10, fDate = 12, fAct = 12;
        const totalFlex = fTx + fUser + fStatus + fGrams + fAmt + fFee + fDate + fAct;
        flex(int f) => (w * f / totalFlex).floor();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              color: bg,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              child: Row(children: [
                SizedBox(width: flex(fTx).toDouble(), child: const _TH('TRANSACTION')),
                SizedBox(width: flex(fUser).toDouble(), child: const _TH('USER')),
                SizedBox(width: flex(fStatus).toDouble(), child: const _TH('STATUS')),
                SizedBox(width: flex(fGrams).toDouble(), child: const _TH('GRAMS')),
                SizedBox(width: flex(fAmt).toDouble(), child: const _TH('AMOUNT')),
                SizedBox(width: flex(fFee).toDouble(), child: const _TH('FEE')),
                SizedBox(width: flex(fDate).toDouble(), child: const _TH('DATE')),
                SizedBox(width: flex(fAct).toDouble(), child: const _TH('ACTIONS')),
              ]),
            ),
            const Divider(height: 1, color: border),
            Expanded(
              child: Obx(() {
                final loading = ctrl.isLoading.value && transactions.isEmpty;
                if (loading) {
                  return _ShimmerList(
                    flexTx: flex(fTx),
                    flexUser: flex(fUser),
                    flexStatus: flex(fStatus),
                    flexGrams: flex(fGrams),
                    flexAmt: flex(fAmt),
                    flexFee: flex(fFee),
                    flexDate: flex(fDate),
                    flexAct: flex(fAct),
                  );
                }
                return ListView.builder(
                  itemCount: transactions.length,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: true,
                  itemBuilder: (_, i) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (i > 0) const Divider(height: 1, color: border),
                      _TableRow(
                        tx: transactions[i],
                        odd: i.isOdd,
                        ctrl: ctrl,
                        flexTx: flex(fTx),
                        flexUser: flex(fUser),
                        flexStatus: flex(fStatus),
                        flexGrams: flex(fGrams),
                        flexAmt: flex(fAmt),
                        flexFee: flex(fFee),
                        flexDate: flex(fDate),
                        flexAct: flex(fAct),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        );
      });
}

// ── Shimmer loading skeleton ──────────────────────────────────────────

class _ShimmerList extends StatefulWidget {
  final int flexTx, flexUser, flexStatus, flexGrams, flexAmt, flexFee, flexDate, flexAct;
  const _ShimmerList({
    required this.flexTx, required this.flexUser, required this.flexStatus,
    required this.flexGrams, required this.flexAmt, required this.flexFee,
    required this.flexDate, required this.flexAct,
  });

  @override
  State<_ShimmerList> createState() => _ShimmerListState();
}

class _ShimmerListState extends State<_ShimmerList>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ac,
    builder: (_, __) => Column(
      children: List.generate(12, (i) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (i > 0) const Divider(height: 1, color: border),
          _ShimmerRow(
            odd: i.isOdd,
            ac: _ac,
            flexTx: widget.flexTx,
            flexUser: widget.flexUser,
            flexStatus: widget.flexStatus,
            flexGrams: widget.flexGrams,
            flexAmt: widget.flexAmt,
            flexFee: widget.flexFee,
            flexDate: widget.flexDate,
            flexAct: widget.flexAct,
          ),
        ],
      )),
    ),
  );
}

class _ShimmerRow extends StatelessWidget {
  final bool odd;
  final AnimationController ac;
  final int flexTx, flexUser, flexStatus, flexGrams, flexAmt, flexFee, flexDate, flexAct;

  const _ShimmerRow({
    required this.odd,
    required this.ac,
    required this.flexTx, required this.flexUser, required this.flexStatus,
    required this.flexGrams, required this.flexAmt, required this.flexFee,
    required this.flexDate, required this.flexAct,
  });

  @override
  Widget build(BuildContext context) {
    final progress = ac.value;
    final base = const Color(0xFFE8EBF0);
    final highlight = const Color(0xFFF5F7FA);
    final color = Color.lerp(base, highlight, (progress * 2).clamp(0, 1).toDouble()) ??
        base;

    return Container(
      color: odd ? const Color(0xFFFAFBFD) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        _bar(flexTx, color, 28),
        _bar(flexUser, color, 28),
        _bar(flexStatus, color, 18),
        _bar(flexGrams, color, 18),
        _bar(flexAmt, color, 18),
        _bar(flexFee, color, 18),
        _bar(flexDate, color, 18),
        _bar(flexAct, color, 18),
      ]),
    );
  }

  Widget _bar(int flex, Color color, double height) => SizedBox(
    width: flex.toDouble(),
    child: Container(
      height: height,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );
}

// ── Table header ──────────────────────────────────────────────────────

class _TH extends StatelessWidget {
  final String label;
  const _TH(this.label);

  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: textSec,
          letterSpacing: 0.7));
}

// ── Table row ─────────────────────────────────────────────────────────

class _TableRow extends StatelessWidget {
  final Transaction tx;
  final bool odd;
  final TransactionController ctrl;
  final int flexTx, flexUser, flexStatus, flexGrams, flexAmt, flexFee, flexDate, flexAct;

  const _TableRow({
    required this.tx,
    required this.odd,
    required this.ctrl,
    required this.flexTx, required this.flexUser, required this.flexStatus,
    required this.flexGrams, required this.flexAmt, required this.flexFee,
    required this.flexDate, required this.flexAct,
  });

  @override
  Widget build(BuildContext context) {
    final tc = typeColor(tx.type);
    return InkWell(
      onTap: () => showDetailSheet(context, tx, ctrl),
      hoverColor: const Color(0xFFF0F4FF),
      child: Container(
        color: odd ? const Color(0xFFFAFBFD) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          // Transaction type + ID
          SizedBox(
            width: flexTx.toDouble(),
            child: Row(children: [
              TypeIcon(type: tx.type, size: 28),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(typeLabel(tx.type),
                          style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: tc),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 1),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: tx.id));
                          Get.snackbar('Copied', 'ID copied',
                              duration: const Duration(seconds: 1));
                        },
                        child: Text(
                          tx.id.length > 8
                              ? '${tx.id.substring(0, 8)}…'
                              : tx.id,
                          style: const TextStyle(
                              fontSize: 9,
                              color: textMuted,
                              fontFamily: 'monospace'),
                        ),
                      ),
                    ]),
              ),
            ]),
          ),

          // User — name + phone from UserController lookup
          SizedBox(
            width: flexUser.toDouble(),
            child: Obx(() {
              String? name = tx.userName;
              String? phone = tx.userPhone ?? tx.userEmail;
              if (tx.userId != null &&
                  Get.isRegistered<UserController>()) {
                final user =
                    Get.find<UserController>().findUser(tx.userId!);
                if (user != null) {
                  name = user.name ?? name;
                  phone = user.phoneNumber ?? phone;
                }
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(name ?? '—',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: textPri),
                      overflow: TextOverflow.ellipsis),
                  if (phone != null) ...[
                    const SizedBox(height: 1),
                    Text(phone,
                        style: const TextStyle(
                            fontSize: 9.5, color: textMuted),
                        overflow: TextOverflow.ellipsis),
                  ],
                ],
              );
            }),
          ),

          // Status
          SizedBox(
            width: flexStatus.toDouble(),
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(status: tx.status),
            ),
          ),

          // Grams
          SizedBox(
            width: flexGrams.toDouble(),
            child: Text(Formatters.formatGrams(tx.grams),
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD32F2F))),
          ),

          // Amount
          SizedBox(
            width: flexAmt.toDouble(),
            child: Text(Formatters.formatCurrency(tx.amountBdt),
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: textPri)),
          ),

          // Fee
          SizedBox(
            width: flexFee.toDouble(),
            child: Text(Formatters.formatCurrency(tx.feeAmount),
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD32F2F))),
          ),

          // Date
          SizedBox(
            width: flexDate.toDouble(),
            child: Text(Formatters.formatDate(tx.createdAt),
                style: const TextStyle(fontSize: 10, color: textSec)),
          ),

          // Actions
          SizedBox(
            width: flexAct.toDouble(),
            child: tx.status.toLowerCase() == 'pending'
                ? ActionButtons(tx: tx, ctrl: ctrl)
                : const SizedBox.shrink(),
          ),
        ]),
      ),
    );
  }
}
