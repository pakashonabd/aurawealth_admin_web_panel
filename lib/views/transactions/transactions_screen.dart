import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/transaction_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import '../../models/transaction.dart';

// ── Lottie URLs ───────────────────────────────────────────────────────────────
const _lottieApproved = 'https://assets9.lottiefiles.com/packages/lf20_jbrw3hcz.json';
const _lottieRejected = 'https://assets7.lottiefiles.com/packages/lf20_qmfs6c3i.json';
const _lottieEmpty    = 'https://assets5.lottiefiles.com/packages/lf20_szlepvdh.json';
const _lottieLoading  = 'https://assets2.lottiefiles.com/packages/lf20_usmfx6bp.json';

// ── Distinct PNG per transaction type ─────────────────────────────────────────
const _pngBuyApp    = 'https://cdn-icons-png.flaticon.com/128/1170/1170678.png';
const _pngBuyStore  = 'https://cdn-icons-png.flaticon.com/128/869/869636.png';
const _pngSellBank  = 'https://cdn-icons-png.flaticon.com/128/2830/2830284.png';
const _pngSellStore = 'https://cdn-icons-png.flaticon.com/128/1198/1198385.png';
const _pngExchange  = 'https://cdn-icons-png.flaticon.com/128/1023/1023539.png';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _bg         = Color(0xFFF6F7FB);
const _surface    = Colors.white;
const _border     = Color(0xFFEDF0F7);
const _textPri    = Color(0xFF0F1828);
const _textSec    = Color(0xFF6B7A99);
const _textMuted  = Color(0xFFAAB4CC);
const _radius     = 14.0;
const _radiusSm   = 9.0;

// Per-type accent palette
const _colBuyApp    = Color(0xFF0288D1);
const _colBuyStore  = Color(0xFF00897B);
const _colSellBank  = Color(0xFF5C4033);
const _colSellStore = Color(0xFFE53935);
const _colExchange  = Color(0xFF7B1FA2);

// Status palette
const _colPending  = Color(0xFFF59E0B);
const _colApproved = Color(0xFF10B981);
const _colPaid     = Color(0xFF3B82F6);
const _colRejected = Color(0xFFEF4444);

// ── Pure helpers ──────────────────────────────────────────────────────────────

Color _statusColor(String s) {
  switch (s.toUpperCase()) {
    case 'PENDING':  return _colPending;
    case 'APPROVED': return _colApproved;
    case 'PAID':     return _colPaid;
    case 'REJECTED': return _colRejected;
    default:         return _textSec;
  }
}

IconData _statusIcon(String s) {
  switch (s.toUpperCase()) {
    case 'PENDING':  return Icons.schedule_rounded;
    case 'APPROVED': return Icons.check_circle_rounded;
    case 'PAID':     return Icons.payments_rounded;
    case 'REJECTED': return Icons.cancel_rounded;
    default:         return Icons.help_rounded;
  }
}

Color _typeColor(String t) {
  switch (t.toUpperCase()) {
    case 'BUY_IN_APP':            return _colBuyApp;
    case 'BUY_IN_STORE':          return _colBuyStore;
    case 'SELL_TO_BANK':          return _colSellBank;
    case 'SELL_TO_STORE':         return _colSellStore;
    case 'EXCHANGE_TO_JEWELLERY': return _colExchange;
    default:                      return _textSec;
  }
}

String _typeLabel(String t) {
  switch (t.toUpperCase()) {
    case 'BUY_IN_APP':            return 'Buy In App';
    case 'BUY_IN_STORE':          return 'Buy In Store';
    case 'SELL_TO_BANK':          return 'Sell to Bank';
    case 'SELL_TO_STORE':         return 'Sell to Store';
    case 'EXCHANGE_TO_JEWELLERY': return 'Exchange';
    default:
      return t.replaceAll('_', ' ').split(' ').map((w) =>
      w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
      ).join(' ');
  }
}

String _pngForType(String t) {
  switch (t.toUpperCase()) {
    case 'BUY_IN_APP':            return _pngBuyApp;
    case 'BUY_IN_STORE':          return _pngBuyStore;
    case 'SELL_TO_BANK':          return _pngSellBank;
    case 'SELL_TO_STORE':         return _pngSellStore;
    case 'EXCHANGE_TO_JEWELLERY': return _pngExchange;
    default:                      return _pngExchange;
  }
}

IconData _iconForType(String t) {
  switch (t.toUpperCase()) {
    case 'BUY_IN_APP':            return Icons.phone_android_rounded;
    case 'BUY_IN_STORE':          return Icons.shopping_bag_rounded;
    case 'SELL_TO_BANK':          return Icons.account_balance_rounded;
    case 'SELL_TO_STORE':         return Icons.storefront_rounded;
    case 'EXCHANGE_TO_JEWELLERY': return Icons.swap_horiz_rounded;
    default:                      return Icons.receipt_long_rounded;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ROOT SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TransactionController>();

    return Scaffold(
      backgroundColor: _bg,
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.transactions.isEmpty) {
          return const _LoadingView();
        }
        if (ctrl.errorMessage.value.isNotEmpty && ctrl.transactions.isEmpty) {
          return custom_error.CustomErrorWidget(
            message: ctrl.errorMessage.value,
            onRetry: ctrl.refresh,
          );
        }

        final all      = ctrl.transactions;
        final filtered = ctrl.filteredTransactions;
        final pending  = all.where((t) => t.status.toLowerCase() == 'pending').length;
        final approved = all.where((t) => t.status.toLowerCase() == 'approved').length;
        final rejected = all.where((t) => t.status.toLowerCase() == 'rejected').length;
        final paid     = all.where((t) => t.status.toLowerCase() == 'paid').length;

        if (Responsive.isMobile(context)) {
          return _MobileLayout(
            all: all,
            filtered: filtered,
            pending: pending,
            approved: approved,
            rejected: rejected,
            paid: paid,
            ctrl: ctrl,
          );
        }

        return _DesktopLayout(
          all: all,
          filtered: filtered,
          pending: pending,
          approved: approved,
          rejected: rejected,
          paid: paid,
          ctrl: ctrl,
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Desktop Layout  — Left panel (charts + stats) | Right panel (table)
// ─────────────────────────────────────────────────────────────────────────────

class _DesktopLayout extends StatelessWidget {
  final List<Transaction> all, filtered;
  final int pending, approved, rejected, paid;
  final TransactionController ctrl;

  const _DesktopLayout({
    required this.all,
    required this.filtered,
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.paid,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── LEFT SIDE PANEL (charts) ──────────────────────────────────────
        SizedBox(
          width: 300,
          child: Container(
            color: _surface,
            child: Column(
              children: [
                // Header
                _PanelHeader(
                  title: 'Transactions',
                  subtitle: '${all.length} total · ${filtered.length} shown',
                  onRefresh: ctrl.refresh,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Column(
                      children: [
                        // Status donut chart
                        _DonutCard(
                          pending: pending,
                          approved: approved,
                          rejected: rejected,
                          paid: paid,
                          total: all.length,
                        ),
                        const SizedBox(height: 10),
                        // Status stat tiles (2x2 grid)
                        _StatusGrid(
                          pending: pending,
                          approved: approved,
                          rejected: rejected,
                          paid: paid,
                        ),
                        const SizedBox(height: 10),
                        // Volume bar chart (by type)
                        _VolumeByTypeChart(transactions: all),
                        const SizedBox(height: 10),
                        // Recent activity sparkline
                        _ActivitySparkline(transactions: all),
                        const SizedBox(height: 10),
                        // Type breakdown list
                        _TypeBreakdownList(transactions: all),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const VerticalDivider(width: 1, color: _border),

        // ── RIGHT SIDE — Filter bar + Table ──────────────────────────────
        Expanded(
          child: Column(
            children: [
              _FilterBar(ctrl: ctrl),
              const Divider(height: 1, color: _border),
              Expanded(
                child: filtered.isEmpty
                    ? const _EmptyView()
                    : _DesktopTable(transactions: filtered, ctrl: ctrl),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Mobile Layout
// ─────────────────────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  final List<Transaction> all, filtered;
  final int pending, approved, rejected, paid;
  final TransactionController ctrl;

  const _MobileLayout({
    required this.all,
    required this.filtered,
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.paid,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // compact header
        Container(
          color: _surface,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Transactions',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                        color: _textPri)),
                Text('${filtered.length} of ${all.length}',
                    style: const TextStyle(fontSize: 11, color: _textSec)),
              ]),
            ),
            IconButton(
              onPressed: ctrl.refresh,
              icon: const Icon(Icons.refresh_rounded, size: 20, color: _textSec),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ]),
        ),
        // Horizontal status chips
        Container(
          color: _surface,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _MiniStatusChip('Pending',  pending,  _colPending),
              const SizedBox(width: 6),
              _MiniStatusChip('Approved', approved, _colApproved),
              const SizedBox(width: 6),
              _MiniStatusChip('Paid',     paid,     _colPaid),
              const SizedBox(width: 6),
              _MiniStatusChip('Rejected', rejected, _colRejected),
            ]),
          ),
        ),
        const Divider(height: 1, color: _border),
        _FilterBar(ctrl: ctrl),
        const Divider(height: 1, color: _border),
        Expanded(
          child: filtered.isEmpty
              ? const _EmptyView()
              : ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 7),
            itemBuilder: (_, i) =>
                _MobileCard(tx: filtered[i], ctrl: ctrl),
          ),
        ),
      ],
    );
  }
}

Widget _MiniStatusChip(String label, int count, Color color) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  decoration: BoxDecoration(
    color: color.withOpacity(0.08),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: color.withOpacity(0.3)),
  ),
  child: Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 6, height: 6,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 5),
    Text('$count $label',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
  ]),
);

// ─────────────────────────────────────────────────────────────────────────────
//  Panel header (left panel)
// ─────────────────────────────────────────────────────────────────────────────

class _PanelHeader extends StatelessWidget {
  final String title, subtitle;
  final VoidCallback onRefresh;
  const _PanelHeader(
      {required this.title, required this.subtitle, required this.onRefresh});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 16, 10, 12),
    child: Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: _textPri)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: const TextStyle(fontSize: 11, color: _textSec)),
        ]),
      ),
      GestureDetector(
        onTap: onRefresh,
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _border),
          ),
          child: const Icon(Icons.refresh_rounded, size: 15, color: _textSec),
        ),
      ),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Donut chart card
// ─────────────────────────────────────────────────────────────────────────────

class _DonutCard extends StatelessWidget {
  final int pending, approved, rejected, paid, total;
  const _DonutCard({
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.paid,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();
    return _Card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _CardLabel('Status Overview'),
        const SizedBox(height: 10),
        SizedBox(
          height: 140,
          child: Row(children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 38,
                  sections: [
                    if (pending > 0)
                      PieChartSectionData(
                        value: pending.toDouble(),
                        color: _colPending,
                        radius: 22,
                        title: '',
                      ),
                    if (approved > 0)
                      PieChartSectionData(
                        value: approved.toDouble(),
                        color: _colApproved,
                        radius: 22,
                        title: '',
                      ),
                    if (paid > 0)
                      PieChartSectionData(
                        value: paid.toDouble(),
                        color: _colPaid,
                        radius: 22,
                        title: '',
                      ),
                    if (rejected > 0)
                      PieChartSectionData(
                        value: rejected.toDouble(),
                        color: _colRejected,
                        radius: 22,
                        title: '',
                      ),
                  ],
                  pieTouchData: PieTouchData(enabled: false),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LegendDot('Pending',  pending,  _colPending,  total),
                const SizedBox(height: 7),
                _LegendDot('Approved', approved, _colApproved, total),
                const SizedBox(height: 7),
                _LegendDot('Paid',     paid,     _colPaid,     total),
                const SizedBox(height: 7),
                _LegendDot('Rejected', rejected, _colRejected, total),
              ],
            ),
          ]),
        ),
      ]),
    );
  }
}

Widget _LegendDot(String label, int count, Color color, int total) {
  final pct = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';
  return Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 8, height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 6),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(fontSize: 10, color: _textSec,
              fontWeight: FontWeight.w500)),
      Text('$count  ($pct%)',
          style: TextStyle(fontSize: 10, color: color,
              fontWeight: FontWeight.w700)),
    ]),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
//  Status 2x2 grid tiles
// ─────────────────────────────────────────────────────────────────────────────

class _StatusGrid extends StatelessWidget {
  final int pending, approved, rejected, paid;
  const _StatusGrid({
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.paid,
  });

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(
      child: Column(children: [
        _StatTile('Pending',  pending,  _colPending,  Icons.schedule_rounded),
        const SizedBox(height: 7),
        _StatTile('Rejected', rejected, _colRejected, Icons.cancel_rounded),
      ]),
    ),
    const SizedBox(width: 7),
    Expanded(
      child: Column(children: [
        _StatTile('Approved', approved, _colApproved, Icons.check_circle_rounded),
        const SizedBox(height: 7),
        _StatTile('Paid',     paid,     _colPaid,     Icons.payments_rounded),
      ]),
    ),
  ]);
}

Widget _StatTile(String label, int count, Color color, IconData icon) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(_radiusSm),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 13, color: color),
        ),
        const SizedBox(width: 7),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$count',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                  color: color, height: 1.1)),
          Text(label,
              style: const TextStyle(fontSize: 9, color: _textSec,
                  fontWeight: FontWeight.w500, letterSpacing: 0.3)),
        ]),
      ]),
    );

// ─────────────────────────────────────────────────────────────────────────────
//  Volume bar chart by type (using fl_chart BarChart)
// ─────────────────────────────────────────────────────────────────────────────

class _VolumeByTypeChart extends StatelessWidget {
  final List<Transaction> transactions;
  const _VolumeByTypeChart({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final types = [
      'BUY_IN_APP', 'BUY_IN_STORE',
      'SELL_TO_BANK', 'SELL_TO_STORE',
      'EXCHANGE_TO_JEWELLERY',
    ];
    final colors = [
      _colBuyApp, _colBuyStore, _colSellBank, _colSellStore, _colExchange,
    ];
    final labels = ['App', 'Store', 'Bank', 'Sell', 'Exch'];

    final counts = types
        .map((t) => transactions.where((tx) => tx.type.toUpperCase() == t).length)
        .toList();
    final maxC = counts.reduce((a, b) => a > b ? a : b);

    return _Card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _CardLabel('Volume by Type'),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (maxC + 1).toDouble(),
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, meta) {
                      final i = v.toInt();
                      if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(labels[i],
                            style: const TextStyle(fontSize: 8.5, color: _textSec)),
                      );
                    },
                    reservedSize: 20,
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (_) => FlLine(
                    color: _border, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(
                types.length,
                    (i) => BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: counts[i].toDouble(),
                      color: colors[i],
                      width: 18,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4)),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: (maxC + 1).toDouble(),
                        color: colors[i].withOpacity(0.06),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Activity sparkline — last 7 days count (fl_chart LineChart)
// ─────────────────────────────────────────────────────────────────────────────

class _ActivitySparkline extends StatelessWidget {
  final List<Transaction> transactions;
  const _ActivitySparkline({required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Build last-7-days bucketed counts
    final now = DateTime.now();
    final spots = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final cnt = transactions.where((tx) {
        final d = tx.createdAt;
        return d.year == day.year &&
            d.month == day.month &&
            d.day == day.day;
      }).length;
      return FlSpot(i.toDouble(), cnt.toDouble());
    });

    final maxY = spots.map((s) => s.y).fold(0.0, (a, b) => a > b ? a : b);

    return _Card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const _CardLabel('7-day Activity'),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: _colApproved.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 6, height: 6,
                  decoration: const BoxDecoration(
                      color: _colApproved, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              const Text('Live', style: TextStyle(fontSize: 9,
                  color: _colApproved, fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(enabled: false),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(show: false),
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: maxY == 0 ? 5 : maxY + 1,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: _colBuyApp,
                  barWidth: 2.5,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (s, _, __, ___) => FlDotCirclePainter(
                      radius: 3,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: _colBuyApp,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _colBuyApp.withOpacity(0.18),
                        _colBuyApp.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Type breakdown compact list
// ─────────────────────────────────────────────────────────────────────────────

class _TypeBreakdownList extends StatelessWidget {
  final List<Transaction> transactions;
  const _TypeBreakdownList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final types = [
      ('BUY_IN_APP', _colBuyApp),
      ('BUY_IN_STORE', _colBuyStore),
      ('SELL_TO_BANK', _colSellBank),
      ('SELL_TO_STORE', _colSellStore),
      ('EXCHANGE_TO_JEWELLERY', _colExchange),
    ];
    final total = transactions.length;

    return _Card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _CardLabel('By Type'),
        const SizedBox(height: 8),
        ...types.map((e) {
          final cnt = transactions
              .where((tx) => tx.type.toUpperCase() == e.$1)
              .length;
          final pct = total > 0 ? cnt / total : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(children: [
              Container(
                width: 6, height: 6,
                decoration: BoxDecoration(
                    color: e.$2, shape: BoxShape.circle),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(_typeLabel(e.$1),
                    style: const TextStyle(fontSize: 10, color: _textPri,
                        fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 6),
              // mini progress
              SizedBox(
                width: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 4,
                    backgroundColor: e.$2.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(e.$2),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 22,
                child: Text('$cnt',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 10,
                        fontWeight: FontWeight.w700, color: e.$2)),
              ),
            ]),
          );
        }),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Filter bar
// ─────────────────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final TransactionController ctrl;
  const _FilterBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final statusVal =
    ctrl.selectedStatus.value.isEmpty ? null : ctrl.selectedStatus.value;
    final typeVal =
    ctrl.selectedType.value.isEmpty ? null : ctrl.selectedType.value;
    final hasFilter = ctrl.selectedStatus.value.isNotEmpty ||
        ctrl.selectedType.value.isNotEmpty ||
        ctrl.searchQuery.value.isNotEmpty;

    return Container(
      color: _surface,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(children: [
        Expanded(
          child: SizedBox(
            height: 34,
            child: TextField(
              onChanged: ctrl.setSearchQuery,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Search ID, user, type…',
                hintStyle: const TextStyle(fontSize: 12, color: _textMuted),
                prefixIcon: const Icon(Icons.search_rounded,
                    size: 16, color: _textSec),
                filled: true,
                fillColor: _bg,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(_radiusSm),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _DropdownFilter(
          label: 'Status',
          value: statusVal,
          items: const ['pending', 'approved', 'paid', 'rejected'],
          onChanged: ctrl.setStatusFilter,
        ),
        const SizedBox(width: 6),
        _DropdownFilter(
          label: 'Type',
          value: typeVal,
          items: const [
            'BUY_IN_APP', 'BUY_IN_STORE',
            'SELL_TO_BANK', 'SELL_TO_STORE',
            'EXCHANGE_TO_JEWELLERY',
          ],
          itemLabels: const [
            'Buy In App', 'Buy In Store',
            'Sell to Bank', 'Sell to Store',
            'Exchange',
          ],
          onChanged: ctrl.setTypeFilter,
        ),
        if (hasFilter) ...[
          const SizedBox(width: 6),
          GestureDetector(
            onTap: ctrl.clearFilters,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: _colRejected.withOpacity(0.08),
                borderRadius: BorderRadius.circular(_radiusSm),
                border: Border.all(color: _colRejected.withOpacity(0.25)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: const [
                Icon(Icons.close_rounded, size: 12, color: _colRejected),
                SizedBox(width: 4),
                Text('Clear',
                    style: TextStyle(fontSize: 11, color: _colRejected,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ],
      ]),
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final List<String>? itemLabels;
  final void Function(String?) onChanged;

  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabels,
  });

  @override
  Widget build(BuildContext context) {
    final active = value != null;
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.primary.withOpacity(0.06) : _bg,
        borderRadius: BorderRadius.circular(_radiusSm),
        border: Border.all(
            color: active ? AppColors.primary.withOpacity(0.4) : _border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(label,
              style: const TextStyle(fontSize: 11, color: _textSec)),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              size: 14, color: _textSec),
          style: TextStyle(
              fontSize: 11,
              color: active ? AppColors.primary : _textPri,
              fontWeight: active ? FontWeight.w700 : FontWeight.normal),
          isDense: true,
          onChanged: onChanged,
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text('All $label',
                  style: const TextStyle(fontSize: 11, color: _textSec)),
            ),
            ...items.asMap().entries.map((e) => DropdownMenuItem<String>(
              value: e.value,
              child: Text(itemLabels?[e.key] ?? e.value,
                  style: const TextStyle(fontSize: 11)),
            )),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Desktop compact table
// ─────────────────────────────────────────────────────────────────────────────

class _DesktopTable extends StatelessWidget {
  final List<Transaction> transactions;
  final TransactionController ctrl;
  const _DesktopTable({required this.transactions, required this.ctrl});

  // col widths: type(170) user(130) status(100) grams(70) amt(110) fee(90) date(90) actions(150)
  static const double _w = 170+130+100+70+110+90+90+150 + 14*8.0 + 20+16;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: SizedBox(
      width: _w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TableHeader(),
          const Divider(height: 1, color: _border),
          Expanded(
            child: ListView.separated(
              itemCount: transactions.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1, color: _border),
              itemBuilder: (_, i) => _TableRow(
                tx: transactions[i],
                odd: i.isOdd,
                ctrl: ctrl,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    color: _bg,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: const [
        SizedBox(width: 170, child: _TH('TRANSACTION')),
        SizedBox(width: 14),
        SizedBox(width: 130, child: _TH('USER')),
        SizedBox(width: 14),
        SizedBox(width: 100, child: _TH('STATUS')),
        SizedBox(width: 14),
        SizedBox(width: 70,  child: _TH('GRAMS')),
        SizedBox(width: 14),
        SizedBox(width: 110, child: _TH('AMOUNT')),
        SizedBox(width: 14),
        SizedBox(width: 90,  child: _TH('FEE')),
        SizedBox(width: 14),
        SizedBox(width: 90,  child: _TH('DATE')),
        SizedBox(width: 14),
        SizedBox(width: 150, child: _TH('ACTIONS')),
        SizedBox(width: 16),
      ]),
    ),
  );
}

class _TH extends StatelessWidget {
  final String label;
  const _TH(this.label);

  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: _textSec,
          letterSpacing: 0.7));
}

class _TableRow extends StatelessWidget {
  final Transaction tx;
  final bool odd;
  final TransactionController ctrl;
  const _TableRow({required this.tx, required this.odd, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final tc = _typeColor(tx.type);
    return InkWell(
      onTap: () => _showDetailSheet(context, tx, ctrl),
      hoverColor: const Color(0xFFF0F4FF),
      child: Container(
        color: odd ? const Color(0xFFFAFBFD) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

          // TRANSACTION 170px
          SizedBox(
            width: 160,
            child: Row(children: [
              _TypeIcon(type: tx.type, size: 30),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_typeLabel(tx.type),
                          style: TextStyle(fontSize: 11,
                              fontWeight: FontWeight.w700, color: tc),
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
                          style: const TextStyle(fontSize: 9,
                              color: _textMuted, fontFamily: 'monospace'),
                        ),
                      ),
                    ]),
              ),
            ]),
          ),
          const SizedBox(width: 14),

          // USER 130px
          SizedBox(
            width: 130,
            child: Text(tx.userName ?? tx.userEmail ?? '—',
                style: const TextStyle(fontSize: 11, color: _textPri),
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 14),

          // STATUS 100px
          SizedBox(width: 100, child: _StatusBadge(status: tx.status)),
          const SizedBox(width: 14),

          // GRAMS 70px
          SizedBox(
            width: 70,
            child: Text(Formatters.formatGrams(tx.grams),
                style: const TextStyle(fontSize: 11,
                    fontWeight: FontWeight.w500, color: _textPri)),
          ),
          const SizedBox(width: 14),

          // AMOUNT 110px
          SizedBox(
            width: 110,
            child: Text(Formatters.formatCurrency(tx.amountBdt),
                style: const TextStyle(fontSize: 11,
                    fontWeight: FontWeight.w800, color: _textPri)),
          ),
          const SizedBox(width: 14),

          // FEE 90px
          SizedBox(
            width: 90,
            child: Text(Formatters.formatCurrency(tx.feeAmount),
                style: const TextStyle(fontSize: 11, color: _textSec)),
          ),
          const SizedBox(width: 14),

          // DATE 90px
          SizedBox(
            width: 90,
            child: Text(Formatters.formatDate(tx.createdAt),
                style: const TextStyle(fontSize: 10, color: _textSec)),
          ),
          const SizedBox(width: 14),

          // ACTIONS 150px
          SizedBox(
            width: 150,
            child: tx.status.toLowerCase() == 'pending'
                ? _ActionButtons(tx: tx, ctrl: ctrl)
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 16),
        ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Mobile card  (compact, no background)
// ─────────────────────────────────────────────────────────────────────────────

class _MobileCard extends StatelessWidget {
  final Transaction tx;
  final TransactionController ctrl;
  const _MobileCard({required this.tx, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final tc = _typeColor(tx.type);
    return GestureDetector(
      onTap: () => _showDetailSheet(context, tx, ctrl),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: _border),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _TypeIcon(type: tx.type, size: 34),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_typeLabel(tx.type),
                        style: TextStyle(fontSize: 12,
                            fontWeight: FontWeight.w700, color: tc)),
                    const SizedBox(height: 1),
                    Text(tx.userName ?? tx.userEmail ?? '—',
                        style: const TextStyle(fontSize: 11, color: _textSec),
                        overflow: TextOverflow.ellipsis),
                  ]),
            ),
            _StatusBadge(status: tx.status),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _MetricCell(label: 'Grams',
                value: Formatters.formatGrams(tx.grams)),
            _vDivider(),
            _MetricCell(label: 'Amount',
                value: Formatters.formatCurrency(tx.amountBdt), bold: true),
            _vDivider(),
            _MetricCell(label: 'Fee',
                value: Formatters.formatCurrency(tx.feeAmount)),
            _vDivider(),
            _MetricCell(label: 'Date',
                value: Formatters.formatDate(tx.createdAt)),
          ]),
          if (tx.status.toLowerCase() == 'pending') ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: _border),
            const SizedBox(height: 8),
            _ActionButtons(tx: tx, ctrl: ctrl),
          ],
        ]),
      ),
    );
  }

  Widget _vDivider() => Container(
      width: 1, height: 28, color: _border,
      margin: const EdgeInsets.symmetric(horizontal: 8));
}

class _MetricCell extends StatelessWidget {
  final String label, value;
  final bool bold;
  const _MetricCell(
      {required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontSize: 9, color: _textMuted,
              fontWeight: FontWeight.w600, letterSpacing: 0.3)),
      const SizedBox(height: 3),
      Text(value,
          style: TextStyle(
              fontSize: 11,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color: _textPri),
          overflow: TextOverflow.ellipsis),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shared atom widgets
// ─────────────────────────────────────────────────────────────────────────────

class _TypeIcon extends StatelessWidget {
  final String type;
  final double size;
  const _TypeIcon({required this.type, required this.size});

  @override
  Widget build(BuildContext context) {
    final clr = _typeColor(type);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: clr.withOpacity(0.08),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: clr.withOpacity(0.22), width: 1),
      ),
      padding: EdgeInsets.all(size * 0.18),
      child: CachedNetworkImage(
        imageUrl: _pngForType(type),
        fit: BoxFit.contain,
        errorWidget: (_, __, ___) =>
            Icon(_iconForType(type), color: clr, size: size * 0.52),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final clr  = _statusColor(status);
    final icon = _statusIcon(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: clr.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: clr.withOpacity(0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: clr),
        const SizedBox(width: 3),
        Text(status.toUpperCase(),
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                color: clr, letterSpacing: 0.4)),
      ]),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Transaction tx;
  final TransactionController ctrl;
  const _ActionButtons({required this.tx, required this.ctrl});

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        _ActionBtn(
          label: 'Approve',
          icon: Icons.check_rounded,
          color: _colApproved,
          onTap: () => _showApproveDialog(context, tx, ctrl),
        ),
        const SizedBox(width: 6),
        _ActionBtn(
          label: 'Reject',
          icon: Icons.close_rounded,
          color: _colRejected,
          filled: false,
          onTap: () => _showRejectDialog(context, tx, ctrl),
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

// ─────────────────────────────────────────────────────────────────────────────
//  Shared card / label atoms
// ─────────────────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(_radius),
      border: Border.all(color: _border),
    ),
    child: child,
  );
}

class _CardLabel extends StatelessWidget {
  final String text;
  const _CardLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: _textSec,
          letterSpacing: 0.4));
}

// ─────────────────────────────────────────────────────────────────────────────
//  Loading / Empty views
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Lottie.network(_lottieLoading, width: 120, height: 120,
          errorBuilder: (_, __, ___) =>
          const CircularProgressIndicator()),
      const SizedBox(height: 10),
      const Text('Loading transactions…',
          style: TextStyle(color: _textSec, fontSize: 13)),
    ]),
  );
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Lottie.network(_lottieEmpty, width: 140, height: 140,
          errorBuilder: (_, __, ___) => const Icon(
              Icons.receipt_long_outlined, size: 64, color: _textMuted)),
      const SizedBox(height: 12),
      const Text('No transactions found',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
              color: _textPri)),
      const SizedBox(height: 4),
      const Text('Adjust filters or refresh',
          style: TextStyle(fontSize: 12, color: _textSec)),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Detail bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

void _showDetailSheet(BuildContext context, Transaction tx,
    TransactionController ctrl) {
  Get.bottomSheet(
    Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 36, height: 4,
          margin: const EdgeInsets.only(top: 10, bottom: 6),
          decoration: BoxDecoration(
              color: _border, borderRadius: BorderRadius.circular(2)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(children: [
            _TypeIcon(type: tx.type, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_typeLabel(tx.type),
                        style: TextStyle(fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _typeColor(tx.type))),
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: tx.id));
                        Get.snackbar('Copied', 'ID copied',
                            duration: const Duration(seconds: 1));
                      },
                      child: Text(tx.id,
                          style: const TextStyle(fontSize: 10, color: _textMuted,
                              fontFamily: 'monospace'),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
            ),
            _StatusBadge(status: tx.status),
          ]),
        ),
        const Divider(height: 1, color: _border),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(children: [
              _dRow('User',       tx.userName ?? tx.userEmail ?? '—'),
              _dRow('User ID',    tx.userId ?? '—'),
              _dRow('Grams',      Formatters.formatGrams(tx.grams)),
              _dRow('Amount',     Formatters.formatCurrency(tx.amountBdt),
                  bold: true),
              _dRow('Fee %',      '${tx.feePercent}%'),
              _dRow('Fee Amount', Formatters.formatCurrency(tx.feeAmount)),
              if (tx.code != null) _dRow('Code', tx.code!),
              _dRow('Created',    Formatters.formatDateTime(tx.createdAt)),
              if (tx.approvedAt != null)
                _dRow('Approved', Formatters.formatDateTime(tx.approvedAt!)),
              if (tx.rejectedAt != null)
                _dRow('Rejected', Formatters.formatDateTime(tx.rejectedAt!)),
              if (tx.adminNote != null && tx.adminNote!.isNotEmpty)
                _dRow('Note', tx.adminNote!),
            ]),
          ),
        ),
        if (tx.status.toLowerCase() == 'pending') ...[
          const Divider(height: 1, color: _border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    _showApproveDialog(context, tx, ctrl);
                  },
                  icon: const Icon(Icons.check_rounded, size: 15),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _colApproved,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
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
                    _showRejectDialog(context, tx, ctrl);
                  },
                  icon: const Icon(Icons.close_rounded, size: 15),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _colRejected,
                    side: const BorderSide(color: _colRejected),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ]),
          ),
        ],
        SizedBox(height: MediaQuery.of(context).padding.bottom + 6),
      ]),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

Widget _dRow(String label, String value, {bool bold = false}) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 7),
  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SizedBox(
      width: 100,
      child: Text(label,
          style: const TextStyle(fontSize: 11, color: _textSec,
              fontWeight: FontWeight.w500)),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: Text(value,
          style: TextStyle(fontSize: 12, color: _textPri,
              fontWeight: bold ? FontWeight.w800 : FontWeight.normal)),
    ),
  ]),
);

// ─────────────────────────────────────────────────────────────────────────────
//  Approve / Reject dialogs
// ─────────────────────────────────────────────────────────────────────────────

void _showApproveDialog(BuildContext context, Transaction tx,
    TransactionController ctrl) {
  final noteCtrl = TextEditingController();
  Get.dialog(Dialog(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Lottie.network(_lottieApproved, width: 80, height: 80,
              repeat: false,
              errorBuilder: (_, __, ___) => const Icon(
                  Icons.check_circle_rounded, size: 56, color: _colApproved)),
          const SizedBox(height: 10),
          const Text('Approve Transaction',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                  color: _textPri)),
          const SizedBox(height: 4),
          Text(Formatters.formatCurrency(tx.amountBdt),
              style: const TextStyle(fontSize: 20,
                  fontWeight: FontWeight.w800, color: _colApproved)),
          const SizedBox(height: 2),
          Text(_typeLabel(tx.type),
              style: const TextStyle(fontSize: 12, color: _textSec)),
          const SizedBox(height: 16),
          const Divider(color: _border),
          const SizedBox(height: 12),
          TextField(
            controller: noteCtrl, maxLines: 2,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              labelText: 'Note (optional)',
              labelStyle: const TextStyle(fontSize: 12),
              filled: true, fillColor: _bg,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _border),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Cancel',
                    style: TextStyle(fontSize: 13, color: _textSec)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  ctrl.approveTransaction(tx.id,
                      note: noteCtrl.text.trim().isEmpty
                          ? null
                          : noteCtrl.text.trim());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _colApproved,
                  foregroundColor: Colors.white, elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Confirm',
                    style: TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ]),
      ),
    ),
  ));
}

void _showRejectDialog(BuildContext context, Transaction tx,
    TransactionController ctrl) {
  final noteCtrl = TextEditingController();
  Get.dialog(Dialog(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Lottie.network(_lottieRejected, width: 80, height: 80,
              repeat: false,
              errorBuilder: (_, __, ___) => const Icon(
                  Icons.cancel_rounded, size: 56, color: _colRejected)),
          const SizedBox(height: 10),
          const Text('Reject Transaction',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                  color: _textPri)),
          const SizedBox(height: 4),
          Text(Formatters.formatCurrency(tx.amountBdt),
              style: const TextStyle(fontSize: 20,
                  fontWeight: FontWeight.w800, color: _colRejected)),
          const SizedBox(height: 2),
          Text(_typeLabel(tx.type),
              style: const TextStyle(fontSize: 12, color: _textSec)),
          const SizedBox(height: 16),
          const Divider(color: _border),
          const SizedBox(height: 12),
          TextField(
            controller: noteCtrl, maxLines: 3,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              labelText: 'Reason (optional)',
              labelStyle: const TextStyle(fontSize: 12),
              filled: true, fillColor: _bg,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _border),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Cancel',
                    style: TextStyle(fontSize: 13, color: _textSec)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  ctrl.rejectTransaction(tx.id,
                      note: noteCtrl.text.trim().isEmpty
                          ? null
                          : noteCtrl.text.trim());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _colRejected,
                  foregroundColor: Colors.white, elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Confirm Reject',
                    style: TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ]),
      ),
    ),
  ));
}