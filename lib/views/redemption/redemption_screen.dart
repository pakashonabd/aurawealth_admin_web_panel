import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/redemption.dart';
import '../../services/api_service.dart';

// ════════════════════════════════════════════════════════════════════════════
//  Soft palette
// ════════════════════════════════════════════════════════════════════════════

class _P {
  // Surfaces
  static const canvas = Color(0xFFFAFBFC);
  static const card = Color(0xFFFFFFFF);
  static const soft = Color(0xFFF3F4F6);
  static const softer = Color(0xFFFAFAFA);
  static const border = Color(0xFFEEF0F3);
  static const divider = Color(0xFFF1F3F5);

  // Text
  static const t1 = Color(0xFF111827);
  static const t2 = Color(0xFF4B5563);
  static const t3 = Color(0xFF9CA3AF);

  // Brand
  static const goldA = Color(0xFFE8B86D);
  static const goldB = Color(0xFFFBBF24);
  static const goldC = Color(0xFFFCD34D);
  static const goldBg = Color(0xFFFAF3E7);
  static const goldBd = Color(0xFFFDE68A);
  static const goldTx = Color(0xFF7C5E10);
  static const goldTxS = Color(0xFFA16207);

  // Status
  static const pending = Color(0xFFEAB308);
  static const pendingBg = Color(0xFFFEF9C3);
  static const pendingBd = Color(0xFFFDE68A);

  static const ok = Color(0xFF6EE7B7);
  static const okBg = Color(0xFFECFDF5);
  static const okBd = Color(0xFFA7F3D0);
  static const okDeep = Color(0xFF10B981);

  static const err = Color(0xFFFCA5A5);
  static const errBg = Color(0xFFFEE2E2);
  static const errBd = Color(0xFFFECACA);
  static const errDeep = Color(0xFFEF4444);

  static const info = Color(0xFF60A5FA);
  static const infoBg = Color(0xFFEFF6FF);
  static const infoBd = Color(0xFFDBEAFE);

  // Delivery
  static const home = Color(0xFF38BDF8);
  static const homeBg = Color(0xFFE0F2FE);
  static const homeBd = Color(0xFFBAE6FD);

  static const store = Color(0xFF818CF8);
  static const storeBg = Color(0xFFEEF2FF);
  static const storeBd = Color(0xFFC7D2FE);

  // Note
  static const noteBg = Color(0xFFFFF7ED);
  static const noteBd = Color(0xFFFED7AA);
  static const noteIc = Color(0xFFFB923C);
  static const noteTx = Color(0xFFC2410C);

  // History header
  static const histA = Color(0xFFFB7185);
  static const histB = Color(0xFFFECDD3);
}

// ════════════════════════════════════════════════════════════════════════════
//  BIRD-FLIGHT TRANSITION
//  Pure Flutter, no external assets. Card is carried by a small white bird
//  with flapping wings along a curved arc with a glowing particle trail,
//  then ripples into the destination section.
// ════════════════════════════════════════════════════════════════════════════

class FlightAnimator {
  static Future<void> fly({
    required BuildContext context,
    required Offset startPos,
    required Offset endPos,
    required Size cardSize,
    required Widget card,
    required Color accentColor,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    final completer = Completer<void>();
    final overlay = Overlay.of(context, rootOverlay: true);
    final entry = OverlayEntry(builder: (_) {
      return _FlightOverlay(
        startPos: startPos,
        endPos: endPos,
        cardSize: cardSize,
        card: card,
        accentColor: accentColor,
        duration: duration,
        onComplete: () {
          if (!completer.isCompleted) completer.complete();
        },
      );
    });
    overlay.insert(entry);
    return completer.future;
  }
}

class _FlightOverlay extends StatefulWidget {
  final Offset startPos;
  final Offset endPos;
  final Size cardSize;
  final Widget card;
  final Color accentColor;
  final Duration duration;
  final VoidCallback onComplete;

  const _FlightOverlay({
    required this.startPos,
    required this.endPos,
    required this.cardSize,
    required this.card,
    required this.accentColor,
    required this.duration,
    required this.onComplete,
  });

  @override
  State<_FlightOverlay> createState() => _FlightOverlayState();
}

class _FlightOverlayState extends State<_FlightOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _fly;
  late final AnimationController _flap;
  late final AnimationController _puff;

  final List<_Particle> _particles = [];
  final math.Random _rng = math.Random();

  Offset _cardPos = Offset.zero;
  double _cardRotation = 0;
  double _cardScale = 1.0;
  double _cardOpacity = 1.0;

  Offset _birdPos = Offset.zero;
  double _birdRotation = 0;
  double _birdScale = 1.0;

  double _rippleT = 0;

  @override
  void initState() {
    super.initState();
    _cardPos = widget.startPos;
    _birdPos = widget.startPos + const Offset(0, -32);

    _fly = AnimationController(vsync: this, duration: widget.duration)
      ..addListener(_onTick)
      ..forward().whenComplete(widget.onComplete);

    _flap = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat();

    _puff = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 70),
    )..repeat();
  }

  void _onTick() {
    final t = _fly.value;
    final eased = Curves.easeInOutCubic.transform(t);

    final p0 = widget.startPos;
    final p2 = widget.endPos;
    final mid = Offset((p0.dx + p2.dx) / 2, (p0.dy + p2.dy) / 2);
    final dx = p2.dx - p0.dx;
    final arcUp = math.max(120.0, dx.abs() * 0.22);
    final p1 = Offset(mid.dx, mid.dy - arcUp);

    final x = (1 - eased) * (1 - eased) * p0.dx +
        2 * (1 - eased) * eased * p1.dx +
        eased * eased * p2.dx;
    final y = (1 - eased) * (1 - eased) * p0.dy +
        2 * (1 - eased) * eased * p1.dy +
        eased * eased * p2.dy;

    final tx = 2 * (1 - eased) * (p1.dx - p0.dx) + 2 * eased * (p2.dx - p1.dx);
    final ty = 2 * (1 - eased) * (p1.dy - p0.dy) + 2 * eased * (p2.dy - p1.dy);
    final angle = math.atan2(ty, tx);

    setState(() {
      _cardPos = Offset(x, y);
      _cardRotation = angle * 0.35;
      _cardScale = 1.0 - eased * 0.18;
      _birdPos = Offset(x, y) + Offset(28, -22);
      _birdRotation = angle;
      _birdScale = t < 0.1
          ? t * 10
          : (t > 0.9 ? math.max(0.0, 1 - (t - 0.9) / 0.1) : 1.0);

      if (t > 0.85) {
        _cardOpacity = (1 - (t - 0.85) / 0.12).clamp(0.0, 1.0);
        _rippleT = ((t - 0.85) / 0.12).clamp(0.0, 1.0);
      } else {
        _rippleT = 0;
      }

      if (_puff.value == 0 && t > 0.05 && t < 0.85) {
        _spawnParticle();
      }

      _particles.removeWhere((p) {
        p.life -= 0.045;
        p.pos = p.pos.translate(0, -0.6);
        return p.life <= 0;
      });
    });
  }

  void _spawnParticle() {
    _particles.add(_Particle(
      pos: _cardPos +
          Offset(
            (_rng.nextDouble() - 0.5) * widget.cardSize.width * 0.8,
            (_rng.nextDouble() - 0.3) * widget.cardSize.height * 0.5,
          ),
      radius: 2 + _rng.nextDouble() * 4,
      life: 1.0,
      color: widget.accentColor,
    ));
  }

  @override
  void dispose() {
    _fly.dispose();
    _flap.dispose();
    _puff.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          for (final p in _particles)
            Positioned(
              left: p.pos.dx - p.radius,
              top: p.pos.dy - p.radius,
              child: Container(
                width: p.radius * 2,
                height: p.radius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.color.withOpacity((p.life * 0.7).clamp(0, 1)),
                  boxShadow: [
                    BoxShadow(
                      color: p.color.withOpacity((p.life * 0.4).clamp(0, 1)),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            left: _birdPos.dx - 18,
            top: _birdPos.dy - 12,
            child: Transform.rotate(
              angle: _birdRotation,
              child: Transform.scale(
                scale: _birdScale,
                child: SizedBox(
                  width: 36,
                  height: 24,
                  child: AnimatedBuilder(
                    animation: _flap,
                    builder: (_, __) => CustomPaint(
                      painter: _BirdPainter(flap: _flap.value),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: _cardPos.dx - widget.cardSize.width / 2,
            top: _cardPos.dy - widget.cardSize.height / 2,
            child: Transform.rotate(
              angle: _cardRotation,
              child: Transform.scale(
                scale: _cardScale,
                child: Opacity(
                  opacity: _cardOpacity,
                  child: SizedBox(
                    width: widget.cardSize.width,
                    height: widget.cardSize.height,
                    child: widget.card,
                  ),
                ),
              ),
            ),
          ),
          if (_rippleT > 0)
            Positioned(
              left: widget.endPos.dx - 40,
              top: widget.endPos.dy - 40,
              child: Container(
                width: 80 * (1 + _rippleT * 1.5),
                height: 80 * (1 + _rippleT * 1.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.accentColor
                        .withOpacity((1 - _rippleT) * 0.6),
                    width: 2.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BirdPainter extends CustomPainter {
  final double flap;
  _BirdPainter({required this.flap});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final f = math.sin(flap * math.pi * 2);
    final amp = h * 0.42 * (1.0 - f.abs() * 0.4);

    final body = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glow = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

    final path = Path();
    path.moveTo(w * 0.05, h * 0.7);
    path.quadraticBezierTo(w * 0.28, h * 0.7 - amp, w * 0.5, h * 0.55);
    path.quadraticBezierTo(w * 0.72, h * 0.7 - amp, w * 0.95, h * 0.7);

    canvas.drawPath(path, glow);
    canvas.drawPath(path, body);

    final bodyPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.5, h * 0.58), 1.5, bodyPaint);
  }

  @override
  bool shouldRepaint(_BirdPainter old) => old.flap != flap;
}

class _Particle {
  Offset pos;
  double radius;
  double life;
  Color color;
  _Particle({
    required this.pos,
    required this.radius,
    required this.life,
    required this.color,
  });
}

class FlyingCardPreview extends StatelessWidget {
  final String name;
  final String phone;
  final String amount;
  final String method;
  final Color accent;

  const FlyingCardPreview({
    super.key,
    required this.name,
    required this.phone,
    required this.amount,
    required this.method,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withOpacity(0.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: accent.withOpacity(0.15),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                method == 'Store Pickup'
                    ? Icons.storefront_rounded
                    : Icons.local_shipping_rounded,
                size: 16,
                color: accent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _P.t1),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(phone,
                      style:
                          const TextStyle(fontSize: 10, color: _P.t2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(amount,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: accent)),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  MAIN SCREEN
// ════════════════════════════════════════════════════════════════════════════

class RedemptionScreen extends StatefulWidget {
  const RedemptionScreen({super.key});

  @override
  State<RedemptionScreen> createState() => _RedemptionScreenState();
}

class _RedemptionScreenState extends State<RedemptionScreen> {
  final ApiService _api = ApiService();

  List<Redemption> _redemptions = [];
  bool _isLoading = true;
  String? _error;

  final TextEditingController _pendingSearchCtrl = TextEditingController();
  final TextEditingController _deliverySearchCtrl = TextEditingController();
  String _pendingSearch = '';
  String _deliverySearch = '';
  Timer? _pendingDebounce;
  Timer? _deliveryDebounce;

  final Set<String> _expanded = <String>{};

  // Keys for the bird-flight animation
  final Map<String, GlobalKey> _cardKeys = {};
  final GlobalKey _homeSectionKey = GlobalKey();
  final GlobalKey _storeSectionKey = GlobalKey();

  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadRedemptions();
    _pollTimer = Timer.periodic(
        const Duration(seconds: 15), (_) => _loadRedemptions(silent: true));
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pendingDebounce?.cancel();
    _deliveryDebounce?.cancel();
    _pendingSearchCtrl.dispose();
    _deliverySearchCtrl.dispose();
    super.dispose();
  }

  // ── Data ────────────────────────────────────────────────────────────────

  Future<void> _loadRedemptions({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final res = await _api.getRedemptions(limit: 200);
      final list = (res['redemptions'] as List<dynamic>? ?? [])
          .map((j) => Redemption.fromJson(j as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() {
        _redemptions = list;
        _isLoading = false;
      });
    } catch (e) {
      final msg = e.toString();
      final friendly = msg.contains('Unable to reach') ||
              msg.contains('timed out') ||
              msg.contains('unavailable')
          ? msg
          : 'Something went wrong. Please try again.';
      if (!mounted) return;
      setState(() {
        _error = friendly;
        _isLoading = false;
      });
    }
  }

  bool _match(Redemption r, String q) {
    if (q.isEmpty) return true;
    final s = q.toLowerCase();
    return r.userName.toLowerCase().contains(s) ||
        r.userPhone.toLowerCase().contains(s) ||
        r.userEmail.toLowerCase().contains(s);
  }

  List<Redemption> get _pendingList {
    return _redemptions
        .where((r) =>
            r.approvalStatus.toUpperCase() == 'PENDING' &&
            _match(r, _pendingSearch))
        .toList();
  }

  int get _approvedCount => _redemptions
      .where((r) => r.approvalStatus.toUpperCase() == 'APPROVED')
      .length;

  List<Redemption> get _homeList => _redemptions.where((r) {
        if (r.approvalStatus.toUpperCase() != 'APPROVED') return false;
        final ds = (r.deliveryStatus ?? '').toUpperCase();
        if (ds == 'DELIVERED' || ds == 'PICKED_UP') return false;
        final m = r.deliveryMethod.toUpperCase();
        if (m != 'DELIVERY' && m != 'HOME_DELIVERY') return false;
        return _match(r, _deliverySearch);
      }).toList();

  List<Redemption> get _storeList => _redemptions.where((r) {
        if (r.approvalStatus.toUpperCase() != 'APPROVED') return false;
        final ds = (r.deliveryStatus ?? '').toUpperCase();
        if (ds == 'DELIVERED' || ds == 'PICKED_UP') return false;
        if (r.deliveryMethod.toUpperCase() != 'STORE_PICKUP') return false;
        return _match(r, _deliverySearch);
      }).toList();

  double get _totalGold =>
      _redemptions.fold(0.0, (s, r) => s + r.goldAmount);

  int get _allActiveHome => _redemptions.where((r) {
        if (r.approvalStatus.toUpperCase() != 'APPROVED') return false;
        final ds = (r.deliveryStatus ?? '').toUpperCase();
        if (ds == 'DELIVERED' || ds == 'PICKED_UP') return false;
        final m = r.deliveryMethod.toUpperCase();
        return m == 'DELIVERY' || m == 'HOME_DELIVERY';
      }).length;

  int get _allActiveStore => _redemptions.where((r) {
        if (r.approvalStatus.toUpperCase() != 'APPROVED') return false;
        final ds = (r.deliveryStatus ?? '').toUpperCase();
        if (ds == 'DELIVERED' || ds == 'PICKED_UP') return false;
        return r.deliveryMethod.toUpperCase() == 'STORE_PICKUP';
      }).length;

  int get _allPending => _redemptions
      .where((r) => r.approvalStatus.toUpperCase() == 'PENDING')
      .length;

  // ── Helpers ─────────────────────────────────────────────────────────────

  IconData _iconForMethod(String? m) {
    final v = (m ?? '').toUpperCase();
    if (v == 'DELIVERY' || v == 'HOME_DELIVERY') {
      return Icons.local_shipping_rounded;
    }
    if (v == 'STORE_PICKUP') return Icons.storefront_rounded;
    return Icons.help_outline_rounded;
  }

  String _labelForDelivery(String? s) {
    if (s == null) return 'Pending';
    switch (s.toUpperCase()) {
      case 'PENDING':
        return 'Pending';
      case 'READY_TO_SHIP':
        return 'Ready to Ship';
      case 'ON_THE_WAY':
        return 'On the Way';
      case 'SHIPPED':
        return 'Shipped';
      case 'READY_FOR_PICKUP':
        return 'Ready for Pickup';
      case 'DELIVERED':
        return 'Delivered';
      case 'PICKED_UP':
        return 'Picked Up';
      default:
        return s.toUpperCase();
    }
  }

  Color _colorForDelivery(String? s) {
    if (s == null) return _P.pending;
    switch (s.toUpperCase()) {
      case 'PENDING':
        return _P.pending;
      case 'READY_TO_SHIP':
      case 'READY_FOR_PICKUP':
        return _P.info;
      case 'ON_THE_WAY':
        return const Color(0xFFFB923C);
      case 'SHIPPED':
        return const Color(0xFFA78BFA);
      case 'DELIVERED':
      case 'PICKED_UP':
        return _P.okDeep;
      default:
        return _P.t3;
    }
  }

  List<String> _flowFor(String method) {
    final m = method.toUpperCase();
    if (m == 'STORE_PICKUP') return const ['READY_FOR_PICKUP', 'PICKED_UP'];
    return const ['READY_TO_SHIP', 'ON_THE_WAY', 'SHIPPED', 'DELIVERED'];
  }

  int _indexOf(String? status, String method) {
    final flow = _flowFor(method);
    final i = flow.indexOf((status ?? '').toUpperCase());
    return i < 0 ? 0 : i;
  }

  // ── Actions ─────────────────────────────────────────────────────────────

  Future<void> _approve(Redemption r) async {
    HapticFeedback.lightImpact();

    // 1. Capture source + destination positions BEFORE we touch state
    //    (so we can read them while the card is still mounted in pending).
    final width = MediaQuery.of(context).size.width;
    final hasFlight = width >= 820;
    final isStore = r.deliveryMethod.toUpperCase() == 'STORE_PICKUP';
    final accent = isStore ? _P.store : _P.home;

    Offset? startPos;
    Offset? endPos;
    if (hasFlight) {
      final cardBox =
          _cardKeys[r.txId]?.currentContext?.findRenderObject() as RenderBox?;
      final destKey = isStore ? _storeSectionKey : _homeSectionKey;
      final destBox =
          destKey.currentContext?.findRenderObject() as RenderBox?;

      if (cardBox != null && destBox != null) {
        startPos = cardBox.localToGlobal(Offset.zero) +
            Offset(cardBox.size.width / 2, cardBox.size.height / 2);
        endPos = destBox.localToGlobal(Offset.zero) +
            Offset(destBox.size.width / 2, 60);
      }
    }

    // 2. OPTIMISTIC UPDATE — flip the local status so the card
    //    immediately appears in the right delivery list. The setState
    //    re-renders the lists in the same frame the user tapped Approve,
    //    so the card "moves" the instant the bird takes off.
    if (mounted) {
      setState(() {
        final i = _redemptions.indexWhere((x) => x.txId == r.txId);
        if (i >= 0) {
          _redemptions[i] = _withApprovedStatus(r);
        }
      });
    }

    // 3. Kick off the flight in parallel (do NOT await). The overlay
    //    is independent of the widget tree, so it keeps animating while
    //    the API call is in flight.
    if (startPos != null && endPos != null) {
      unawaited(FlightAnimator.fly(
        context: context,
        startPos: startPos,
        endPos: endPos,
        cardSize: const Size(220, 70),
        card: FlyingCardPreview(
          name: r.userName.isNotEmpty ? r.userName : 'User',
          phone: r.userPhone,
          amount: '${r.goldAmount.toStringAsFixed(2)}g',
          method: isStore ? 'Store Pickup' : 'Home Delivery',
          accent: accent,
        ),
        accentColor: accent,
      ));
    }

    // 4. API call in the background. We don't block the UI on it.
    try {
      await _api.approveRedemption(r.txId);
      _toast('Approved', 'Redemption approved', ok: true);
    } catch (e) {
      _toast('Error', e.toString(), ok: false);
    }

    // 5. Final server sync — picks up any server-side changes and
    //    guarantees the lists match the backend. Drop the stale key
    //    so the now-approved card no longer has a pending key tracked.
    _cardKeys.remove(r.txId);
    _loadRedemptions(silent: true);
  }

  /// Returns a copy of [r] with approvalStatus set to APPROVED.
  /// Uses toJson/fromJson so it works with any model that supports it.
  /// If your Redemption model has a `copyWith` method, replace this with
  /// `r.copyWith(approvalStatus: 'APPROVED')` for cleaner code.
  Redemption _withApprovedStatus(Redemption r) {
    final m = r.toJson();
    m['approvalStatus'] = 'APPROVED';
    return Redemption.fromJson(m);
  }

  Future<void> _reject(String txId) async {
    final noteCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _RejectDialog(controller: noteCtrl),
    );
    if (confirmed != true) return;
    try {
      await _api.rejectRedemption(txId, note: noteCtrl.text.trim());
      _toast('Rejected', 'Redemption rejected', ok: false);
      _loadRedemptions(silent: true);
    } catch (e) {
      _toast('Error', e.toString(), ok: false);
    }
  }

  Future<void> _advance(Redemption r, String next) async {
    HapticFeedback.mediumImpact();
    try {
      await _api.updateDeliveryStatus(r.txId, next);
      _toast('Status updated',
          '${r.userName.split(' ').first} → ${_labelForDelivery(next)}',
          ok: true);
      _loadRedemptions(silent: true);
    } catch (e) {
      _toast('Update failed', e.toString().replaceFirst('Exception: ', ''),
          ok: false);
    }
  }

  void _toast(String title, String msg, {required bool ok}) {
    Get.snackbar(title, msg,
        backgroundColor: ok ? _P.okDeep : _P.errDeep,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 16);
  }

  // ── History drawer ──────────────────────────────────────────────────────

  void _openHistory() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'History',
      barrierColor: Colors.black.withOpacity(0.12),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, _, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 480,
              child: _HistoryDrawerView(
                api: _api,
                colorFor: _colorForDelivery,
                labelFor: _labelForDelivery,
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _P.canvas,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSearchBars(),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? _buildLoading()
                  : _error != null
                      ? _buildError()
                      : _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      decoration: const BoxDecoration(color: _P.card, boxShadow: [
        BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2)),
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_P.goldC, _P.goldB],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.workspace_premium_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Redemptions',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _P.t1,
                            letterSpacing: -0.3)),
                    Text('Manage approvals and delivery pipeline',
                        style: TextStyle(fontSize: 12, color: _P.t2)),
                  ],
                ),
              ),
              Material(
                color: _P.home,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: _openHistory,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history_rounded,
                            size: 18, color: Colors.white),
                        SizedBox(width: 6),
                        Text('History',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton.filledTonal(
                onPressed: _loadRedemptions,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: _P.soft,
                  foregroundColor: _P.t2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildStats(),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final stats = <_Stat>[
      _Stat('Total', '${_redemptions.length}', _P.info),
      _Stat('Pending', '$_allPending', _P.pending),
      _Stat('Approved', '$_approvedCount', _P.okDeep),
      _Stat('Delivery', '$_allActiveHome', _P.home),
      _Stat('Pickup', '$_allActiveStore', _P.store),
      _Stat('Gold', '${_totalGold.toStringAsFixed(1)}g', _P.goldA),
    ];
    return Row(
      children: [
        for (int i = 0; i < stats.length; i++) ...[
          Expanded(child: _StatChip(stat: stats[i]))
              .animate(delay: (40 * i).ms)
              .fadeIn(duration: 280.ms)
              .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
          if (i != stats.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _buildSearchBars() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: LayoutBuilder(
        builder: (context, c) {
          if (c.maxWidth < 600) {
            return Column(
              children: [
                _SearchField(
                  controller: _pendingSearchCtrl,
                  hint: 'Search pending…',
                  accent: _P.pending,
                  onChanged: _onPendingChanged,
                  onClear: () {
                    _pendingSearchCtrl.clear();
                    setState(() => _pendingSearch = '');
                  },
                ),
                const SizedBox(height: 8),
                _SearchField(
                  controller: _deliverySearchCtrl,
                  hint: 'Search home delivery & store pickup…',
                  accent: _P.home,
                  onChanged: _onDeliveryChanged,
                  onClear: () {
                    _deliverySearchCtrl.clear();
                    setState(() => _deliverySearch = '');
                  },
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(
                  flex: 3,
                  child: _SearchField(
                    controller: _pendingSearchCtrl,
                    hint: 'Search pending…',
                    accent: _P.pending,
                    onChanged: _onPendingChanged,
                    onClear: () {
                      _pendingSearchCtrl.clear();
                      setState(() => _pendingSearch = '');
                    },
                  )),
              const SizedBox(width: 12),
              Expanded(
                  flex: 7,
                  child: _SearchField(
                    controller: _deliverySearchCtrl,
                    hint: 'Search home delivery & store pickup…',
                    accent: _P.home,
                    onChanged: _onDeliveryChanged,
                    onClear: () {
                      _deliverySearchCtrl.clear();
                      setState(() => _deliverySearch = '');
                    },
                  )),
            ],
          );
        },
      ),
    );
  }

  void _onPendingChanged(String v) {
    setState(() {});
    _pendingDebounce?.cancel();
    _pendingDebounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _pendingSearch = v.trim());
    });
  }

  void _onDeliveryChanged(String v) {
    setState(() {});
    _deliveryDebounce?.cancel();
    _deliveryDebounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _deliverySearch = v.trim());
    });
  }

  Widget _buildBody() {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth >= 1200) return _build3Column();
        if (c.maxWidth >= 820) return _build2Column();
        return _buildNarrowTabs();
      },
    );
  }

  Widget _build3Column() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: _Section(
              icon: Icons.pending_actions_rounded,
              color: _P.pending,
              title: 'Pending Approvals',
              count: _pendingList.length,
              child: _buildPendingList(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: _Section(
              key: _homeSectionKey,
              icon: Icons.local_shipping_rounded,
              color: _P.home,
              title: 'Home Delivery',
              count: _homeList.length,
              child: _buildDeliveryList(_homeList, 'No home deliveries'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: _Section(
              key: _storeSectionKey,
              icon: Icons.storefront_rounded,
              color: _P.store,
              title: 'Store Pickup',
              count: _storeList.length,
              child: _buildDeliveryList(_storeList, 'No store pickups'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build2Column() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: _Section(
              icon: Icons.pending_actions_rounded,
              color: _P.pending,
              title: 'Pending Approvals',
              count: _pendingList.length,
              child: _buildPendingList(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Column(
              children: [
                Expanded(
                  child: _Section(
                    key: _homeSectionKey,
                    icon: Icons.local_shipping_rounded,
                    color: _P.home,
                    title: 'Home Delivery',
                    count: _homeList.length,
                    child:
                        _buildDeliveryList(_homeList, 'No home deliveries'),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _Section(
                    key: _storeSectionKey,
                    icon: Icons.storefront_rounded,
                    color: _P.store,
                    title: 'Store Pickup',
                    count: _storeList.length,
                    child:
                        _buildDeliveryList(_storeList, 'No store pickups'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrowTabs() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            decoration: BoxDecoration(
              color: _P.soft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const TabBar(
              indicator: BoxDecoration(),
              labelColor: _P.t1,
              unselectedLabelColor: _P.t2,
              labelStyle: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 12),
              unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 12),
              tabs: [
                Tab(text: 'Pending'),
                Tab(text: 'Delivery'),
                Tab(text: 'Pickup'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: _buildPendingList(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: _buildDeliveryList(_homeList, 'No home deliveries'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: _buildDeliveryList(_storeList, 'No store pickups'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingList() {
    if (_pendingList.isEmpty) {
      return _EmptyState(
        icon: Icons.check_circle_outline_rounded,
        title: _pendingSearch.isEmpty ? 'Inbox zero' : 'No matches',
        message: _pendingSearch.isEmpty
            ? 'No pending approvals right now.'
            : 'No pending approvals match "$_pendingSearch".',
      );
    }
    return RefreshIndicator(
      onRefresh: () => _loadRedemptions(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 4, bottom: 12),
        itemCount: _pendingList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          final r = _pendingList[i];
          return _PendingCard(
            key: _cardKeys.putIfAbsent(r.txId, () => GlobalKey()),
            redemption: r,
            onApprove: () => _approve(r),
            onReject: () => _reject(r.txId),
            iconFor: _iconForMethod,
            formatDate: _formatDate,
          )
              .animate(delay: (40 * i).ms)
              .fadeIn(duration: 320.ms)
              .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
        },
      ),
    );
  }

  Widget _buildDeliveryList(List<Redemption> items, String emptyMsg) {
    if (items.isEmpty) {
      return _EmptyState(
        icon: Icons.inbox_rounded,
        title: _deliverySearch.isEmpty ? 'All clear' : 'No matches',
        message: _deliverySearch.isEmpty
            ? emptyMsg
            : 'No items match "$_deliverySearch".',
      );
    }
    return RefreshIndicator(
      onRefresh: () => _loadRedemptions(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 4, bottom: 12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          final r = items[i];
          final flow = _flowFor(r.deliveryMethod);
          final idx = _indexOf(r.deliveryStatus, r.deliveryMethod);
          return _DeliveryCard(
            redemption: r,
            flow: flow,
            currentIndex: idx,
            isComplete: idx >= flow.length - 1,
            isExpanded: _expanded.contains(r.txId),
            onToggle: () => setState(() {
              if (_expanded.contains(r.txId)) {
                _expanded.remove(r.txId);
              } else {
                _expanded.add(r.txId);
              }
            }),
            onAdvance: (next) {
              setState(() => _expanded.remove(r.txId));
              _advance(r, next);
            },
            iconFor: _iconForMethod,
            colorFor: _colorForDelivery,
            labelFor: _labelForDelivery,
            formatDate: _formatDate,
          )
              .animate(delay: (40 * i).ms)
              .fadeIn(duration: 320.ms)
              .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE5E7EB),
        highlightColor: const Color(0xFFF3F4F6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: List.generate(
                    3,
                    (_) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
                color: _P.errBg, shape: BoxShape.circle),
            child: const Icon(Icons.error_outline_rounded,
                color: _P.errDeep, size: 32),
          ),
          const SizedBox(height: 16),
          Text(_error!,
              style: const TextStyle(fontSize: 14, color: _P.t2)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loadRedemptions,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Try again'),
            style: FilledButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              backgroundColor: _P.info,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      final h = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$d/$m/${dt.year}  $h:$mm';
    } catch (_) {
      return iso;
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Helper data + small widgets
// ════════════════════════════════════════════════════════════════════════════

class _Stat {
  final String label;
  final String value;
  final Color color;
  const _Stat(this.label, this.value, this.color);
}

class _StatChip extends StatelessWidget {
  final _Stat stat;
  const _StatChip({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: stat.color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: stat.color.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration:
                BoxDecoration(color: stat.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(stat.label,
                    style: const TextStyle(
                        fontSize: 10,
                        color: _P.t2,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3)),
                const SizedBox(height: 1),
                Text(stat.value,
                    style: const TextStyle(
                        fontSize: 14,
                        color: _P.t1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        height: 1.1),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Color accent;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.hint,
    required this.accent,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _P.t3, fontSize: 13),
        prefixIcon: Icon(Icons.search_rounded, size: 18, color: accent),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded, size: 16),
                onPressed: onClear,
                color: _P.t3,
              ),
        filled: true,
        fillColor: _P.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _P.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _P.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 1.4),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final int count;
  final Widget child;

  const _Section({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.count,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _P.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _P.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, color: color, size: 17),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _P.t1,
                          letterSpacing: -0.2),
                      overflow: TextOverflow.ellipsis),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$count',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color)),
                ),
              ],
            ),
          ),
          Container(height: 1, color: _P.divider),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const _EmptyState(
      {required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
                color: _P.soft, shape: BoxShape.circle),
            child: Icon(icon, size: 28, color: _P.t3),
          ),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _P.t1)),
          const SizedBox(height: 4),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: _P.t2)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Pending card
// ════════════════════════════════════════════════════════════════════════════

class _PendingCard extends StatefulWidget {
  final Redemption redemption;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final IconData Function(String?) iconFor;
  final String Function(String) formatDate;

  const _PendingCard({
    super.key,
    required this.redemption,
    required this.onApprove,
    required this.onReject,
    required this.iconFor,
    required this.formatDate,
  });

  @override
  State<_PendingCard> createState() => _PendingCardState();
}

class _PendingCardState extends State<_PendingCard> {
  bool _dApprove = false;
  bool _dReject = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.redemption;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _P.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _P.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(
                initials: _initials(r.userName),
                color: _P.pending,
                icon: widget.iconFor(r.deliveryMethod),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.userName,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _P.t1,
                            letterSpacing: -0.2),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 1),
                    Text(r.userPhone,
                        style: const TextStyle(
                            fontSize: 11.5, color: _P.t2),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              _Pill(
                label: 'PENDING',
                color: _P.pending,
                bg: _P.pendingBg,
                bd: _P.pendingBd,
                icon: Icons.schedule_rounded,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _GoldRow(r: r),
          const SizedBox(height: 12),
          _Chips(r: r, iconFor: widget.iconFor),
          if (r.redemptionAddress != null &&
              r.redemptionAddress!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _Address(address: r.redemptionAddress!),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 12, color: _P.t3),
              const SizedBox(width: 4),
              Text(widget.formatDate(r.createdAt),
                  style: const TextStyle(
                      fontSize: 11, color: _P.t3)),
              const Spacer(),
              _Btn(
                label: 'Reject',
                icon: Icons.close_rounded,
                color: _P.errDeep,
                pressed: _dReject,
                onDown: () => setState(() => _dReject = true),
                onUp: () => setState(() => _dReject = false),
                onTap: widget.onReject,
              ),
              const SizedBox(width: 8),
              _Btn(
                label: 'Approve',
                icon: Icons.check_rounded,
                color: _P.okDeep,
                primary: true,
                pressed: _dApprove,
                onDown: () => setState(() => _dApprove = true),
                onUp: () => setState(() => _dApprove = false),
                onTap: widget.onApprove,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _initials(String n) {
    if (n.isEmpty) return '?';
    final p = n.trim().split(RegExp(r'\s+'));
    if (p.length == 1) return p.first.substring(0, 1).toUpperCase();
    return (p.first.substring(0, 1) + p.last.substring(0, 1)).toUpperCase();
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Delivery card
// ════════════════════════════════════════════════════════════════════════════

class _DeliveryCard extends StatefulWidget {
  final Redemption redemption;
  final List<String> flow;
  final int currentIndex;
  final bool isComplete;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<String> onAdvance;
  final IconData Function(String?) iconFor;
  final Color Function(String?) colorFor;
  final String Function(String?) labelFor;
  final String Function(String) formatDate;

  const _DeliveryCard({
    required this.redemption,
    required this.flow,
    required this.currentIndex,
    required this.isComplete,
    required this.isExpanded,
    required this.onToggle,
    required this.onAdvance,
    required this.iconFor,
    required this.colorFor,
    required this.labelFor,
    required this.formatDate,
  });

  @override
  State<_DeliveryCard> createState() => _DeliveryCardState();
}

class _DeliveryCardState extends State<_DeliveryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _d = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      value: widget.isExpanded ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant _DeliveryCard old) {
    super.didUpdateWidget(old);
    if (widget.isExpanded != old.isExpanded) {
      widget.isExpanded ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.redemption;
    final c = widget.colorFor(r.deliveryStatus);
    final lbl = widget.labelFor(r.deliveryStatus);

    return Container(
      decoration: BoxDecoration(
        color: _P.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: widget.isExpanded ? c.withOpacity(0.4) : _P.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Avatar(
                      initials: _initials(r.userName),
                      color: c,
                      icon: widget.iconFor(r.deliveryMethod),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.userName,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _P.t1,
                                  letterSpacing: -0.2),
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 1),
                          Text(r.userPhone,
                              style: const TextStyle(
                                  fontSize: 11.5, color: _P.t2),
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    _Pill(
                      label: lbl.toUpperCase(),
                      color: c,
                      bg: c.withOpacity(0.1),
                      bd: c.withOpacity(0.25),
                      icon: widget.isComplete
                          ? Icons.check_circle_rounded
                          : Icons.local_shipping_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _GoldRow(r: r),
                const SizedBox(height: 12),
                _Stepper(
                  steps: widget.flow.map(widget.labelFor).toList(),
                  currentIndex: widget.currentIndex,
                  color: c,
                ),
                const SizedBox(height: 12),
                _Chips(r: r, iconFor: widget.iconFor),
                if (r.redemptionAddress != null &&
                    r.redemptionAddress!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _Address(address: r.redemptionAddress!),
                ],
                if (r.adminNote != null && r.adminNote!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _Note(note: r.adminNote!),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 12, color: _P.t3),
                    const SizedBox(width: 4),
                    Text(widget.formatDate(r.createdAt),
                        style: const TextStyle(
                            fontSize: 11, color: _P.t3)),
                    const Spacer(),
                    if (widget.isComplete)
                      const _DoneBadge()
                    else
                      _Btn(
                        label: widget.isExpanded ? 'Close' : 'Advance',
                        icon: widget.isExpanded
                            ? Icons.expand_less_rounded
                            : Icons.arrow_forward_rounded,
                        color: c,
                        primary: true,
                        pressed: _d,
                        onDown: () => setState(() => _d = true),
                        onUp: () => setState(() => _d = false),
                        onTap: widget.onToggle,
                      ),
                  ],
                ),
              ],
            ),
          ),
          SizeTransition(
            sizeFactor:
                CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
            axisAlignment: -1,
            child: FadeTransition(
              opacity: _ctrl,
              child: _AdvancePanel(
                flow: widget.flow,
                currentIndex: widget.currentIndex,
                color: c,
                labelFor: widget.labelFor,
                onPick: widget.onAdvance,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String n) {
    if (n.isEmpty) return '?';
    final p = n.trim().split(RegExp(r'\s+'));
    if (p.length == 1) return p.first.substring(0, 1).toUpperCase();
    return (p.first.substring(0, 1) + p.last.substring(0, 1)).toUpperCase();
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Stepper
// ════════════════════════════════════════════════════════════════════════════

class _Stepper extends StatelessWidget {
  final List<String> steps;
  final int currentIndex;
  final Color color;

  const _Stepper({
    required this.steps,
    required this.currentIndex,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        const gap = 4.0;
        final stepW = (c.maxWidth - gap * (steps.length - 1)) / steps.length;
        return Row(
          children: List.generate(steps.length * 2 - 1, (i) {
            if (i.isOdd) {
              final filled = i ~/ 2 < currentIndex;
              return Container(
                width: gap,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  height: 2,
                  decoration: BoxDecoration(
                    color: filled ? color : _P.divider,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              );
            }
            final idx = i ~/ 2;
            final done = idx < currentIndex;
            final isCurrent = idx == currentIndex;
            return SizedBox(
              width: stepW,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? color
                          : done
                              ? color.withOpacity(0.15)
                              : _P.card,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: done || isCurrent ? color : _P.t3,
                        width: isCurrent ? 0 : 1.5,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.3),
                                blurRadius: 6,
                              )
                            ]
                          : null,
                    ),
                    child: done
                        ? Icon(Icons.check_rounded, size: 13, color: color)
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    steps[idx],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight:
                          isCurrent ? FontWeight.w700 : FontWeight.w500,
                      color: done || isCurrent ? _P.t1 : _P.t3,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

class _AdvancePanel extends StatelessWidget {
  final List<String> flow;
  final int currentIndex;
  final Color color;
  final String Function(String?) labelFor;
  final ValueChanged<String> onPick;

  const _AdvancePanel({
    required this.flow,
    required this.currentIndex,
    required this.color,
    required this.labelFor,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fast_forward_rounded, size: 14, color: color),
                const SizedBox(width: 6),
                Text('Advance to next step',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(flow.length, (i) {
                final s = flow[i];
                if (i == currentIndex) {
                  return _Choice(
                    label: 'Current: ${labelFor(s)}',
                    color: color,
                    selected: true,
                    onTap: () {},
                  );
                }
                if (i < currentIndex) {
                  return _Choice(
                    label: labelFor(s),
                    color: color,
                    done: true,
                    onTap: () {},
                  );
                }
                return _Choice(
                  label: labelFor(s),
                  color: color,
                  onTap: () => onPick(s),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _Choice extends StatefulWidget {
  final String label;
  final Color color;
  final bool selected;
  final bool done;
  final VoidCallback onTap;

  const _Choice({
    required this.label,
    required this.color,
    required this.onTap,
    this.selected = false,
    this.done = false,
  });

  @override
  State<_Choice> createState() => _ChoiceState();
}

class _ChoiceState extends State<_Choice> {
  bool _d = false;
  @override
  Widget build(BuildContext context) {
    final bg = widget.selected
        ? widget.color
        : widget.done
            ? widget.color.withOpacity(0.1)
            : _P.card;
    final bd =
        widget.selected || widget.done ? widget.color : _P.border;
    final fg = widget.selected
        ? Colors.white
        : widget.done
            ? widget.color
            : _P.t2;
    return AnimatedScale(
      scale: _d ? 0.95 : 1,
      duration: const Duration(milliseconds: 120),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _d = true),
          onTapUp: (_) => setState(() => _d = false),
          onTapCancel: () => setState(() => _d = false),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: bd),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.done)
                  Icon(Icons.check_rounded, size: 13, color: widget.color)
                else if (widget.selected)
                  const Icon(Icons.radio_button_checked,
                      size: 13, color: Colors.white)
                else
                  const Icon(Icons.circle_outlined,
                      size: 13, color: _P.t3),
                const SizedBox(width: 5),
                Text(widget.label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Shared building blocks
// ════════════════════════════════════════════════════════════════════════════

class _Avatar extends StatelessWidget {
  final String initials;
  final Color color;
  final IconData? icon;
  final double size;
  const _Avatar(
      {required this.initials, required this.color, this.icon, this.size = 38});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, color: color, size: size * 0.48)
            : Text(initials,
                style: TextStyle(
                    color: color,
                    fontSize: size * 0.38,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5)),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  final Color bd;
  final IconData? icon;
  const _Pill(
      {required this.label,
      required this.color,
      required this.bg,
      required this.bd,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ],
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.3)),
        ],
      ),
    );
  }
}

class _GoldRow extends StatelessWidget {
  final Redemption r;
  const _GoldRow({required this.r});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_P.goldBg, Color(0xFFFFFBF0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _P.goldBd.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _P.pendingBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.workspace_premium_rounded,
                color: _P.goldA, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${r.goldAmount.toStringAsFixed(2)} g',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _P.goldTx,
                        letterSpacing: -0.4)),
                const SizedBox(height: 1),
                Text('৳${r.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 11, color: _P.goldTxS)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _m('Fee', r.feeAmount),
              const SizedBox(height: 2),
              _m('VAT', r.vatAmount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _m(String l, double v) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$l:',
            style: const TextStyle(
                fontSize: 10,
                color: _P.goldTxS,
                fontWeight: FontWeight.w500)),
        const SizedBox(width: 3),
        Text('৳${v.toStringAsFixed(0)}',
            style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: _P.goldTx)),
      ],
    );
  }
}

class _Chips extends StatelessWidget {
  final Redemption r;
  final IconData Function(String?) iconFor;
  const _Chips({required this.r, required this.iconFor});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      _c(
          iconFor(r.deliveryMethod),
          r.deliveryMethod.toUpperCase() == 'STORE_PICKUP'
              ? 'Store Pickup'
              : 'Home Delivery',
          _P.t2),
      if (r.userEmail.isNotEmpty)
        _c(Icons.email_outlined, r.userEmail, _P.t2),
    ];
    return Wrap(spacing: 6, runSpacing: 6, children: items);
  }

  Widget _c(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _P.soft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(text,
                style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _Address extends StatelessWidget {
  final String address;
  final bool compact;
  const _Address({required this.address, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.location_on_outlined,
            size: compact ? 12 : 13, color: _P.t3),
        const SizedBox(width: 4),
        Expanded(
          child: Text(address,
              maxLines: compact ? 1 : 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: compact ? 11 : 11.5, color: _P.t2)),
        ),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  final String note;
  const _Note({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _P.noteBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _P.noteBd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.note_alt_outlined, size: 13, color: _P.noteIc),
          const SizedBox(width: 6),
          Expanded(
            child: Text(note,
                style: const TextStyle(fontSize: 11.5, color: _P.noteTx)),
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool primary;
  final bool pressed;
  final VoidCallback onDown;
  final VoidCallback onUp;
  final VoidCallback onTap;

  const _Btn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onDown,
    required this.onUp,
    required this.onTap,
    this.primary = false,
    this.pressed = false,
  });

  @override
  State<_Btn> createState() => _BtnState();
}

class _BtnState extends State<_Btn> {
  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: widget.pressed ? 0.94 : 1,
      duration: const Duration(milliseconds: 120),
      child: Material(
        color: widget.primary
            ? widget.color
            : widget.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: widget.onTap,
          onTapDown: (_) => widget.onDown(),
          onTapUp: (_) => widget.onUp(),
          onTapCancel: widget.onUp,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: widget.primary
                  ? null
                  : Border.all(color: widget.color.withOpacity(0.3)),
              boxShadow: widget.primary
                  ? [
                      BoxShadow(
                        color: widget.color.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon,
                    size: 13,
                    color: widget.primary ? Colors.white : widget.color),
                const SizedBox(width: 5),
                Text(widget.label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color:
                            widget.primary ? Colors.white : widget.color)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DoneBadge extends StatelessWidget {
  const _DoneBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _P.okBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _P.okBd),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 13, color: _P.okDeep),
          SizedBox(width: 4),
          Text('Completed',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _P.okDeep)),
        ],
      ),
    );
  }
}

class _RejectDialog extends StatefulWidget {
  final TextEditingController controller;
  const _RejectDialog({required this.controller});

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  bool _err = false;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _P.errBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.cancel_outlined,
                      color: _P.errDeep, size: 18),
                ),
                const SizedBox(width: 12),
                const Text('Reject redemption',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _P.t1,
                        letterSpacing: -0.2)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Please provide a reason. This will be visible to the user.',
              style: TextStyle(fontSize: 12, color: _P.t2),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.controller,
              maxLines: 3,
              onChanged: (_) {
                if (_err) setState(() => _err = false);
              },
              decoration: InputDecoration(
                hintText: 'Reason (required)',
                filled: true,
                fillColor: _P.softer,
                errorText: _err ? 'Reason is required' : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _P.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: _err ? _P.errDeep : _P.border),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel',
                      style: TextStyle(color: _P.t2)),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    if (widget.controller.text.trim().isEmpty) {
                      setState(() => _err = true);
                      HapticFeedback.lightImpact();
                      return;
                    }
                    Navigator.pop(context, true);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _P.errDeep,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Reject'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  History drawer
// ════════════════════════════════════════════════════════════════════════════

class _HistoryDrawerView extends StatefulWidget {
  final ApiService api;
  final Color Function(String?) colorFor;
  final String Function(String?) labelFor;
  const _HistoryDrawerView({
    required this.api,
    required this.colorFor,
    required this.labelFor,
  });

  @override
  State<_HistoryDrawerView> createState() => _HistoryDrawerViewState();
}

class _HistoryDrawerViewState extends State<_HistoryDrawerView> {
  List<Redemption> _history = [];
  bool _loading = false;
  bool _loaded = false;
  String? _status;
  String? _method;
  String _sortBy = 'created_at';
  String _sortOrder = 'desc';
  final TextEditingController _searchCtrl = TextEditingController();
  int _total = 0;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final res = await widget.api.getRedemptionHistory(
        status: _status,
        deliveryMethod: _method,
        search: _searchCtrl.text.trim().isEmpty
            ? null
            : _searchCtrl.text.trim(),
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        limit: 50,
      );
      if (!mounted) return;
      setState(() {
        _history = (res['redemptions'] as List<dynamic>? ?? [])
            .map((j) => Redemption.fromJson(j as Map<String, dynamic>))
            .toList();
        _total = res['total'] ?? _history.length;
        _loading = false;
        _loaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearch(String _) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _load);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _P.card,
      elevation: 20,
      child: SafeArea(
        child: Column(
          children: [
            _header(),
            _filters(),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_P.histA, _P.histB],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.history_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Redemption History',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2)),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _filters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      color: _P.softer,
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            onChanged: _onSearch,
            onSubmitted: (_) => _load(),
            decoration: InputDecoration(
              hintText: 'Search user…',
              hintStyle: const TextStyle(fontSize: 13, color: _P.t3),
              prefixIcon: const Icon(Icons.search_rounded,
                  size: 18, color: _P.t3),
              suffixIcon: _searchCtrl.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16),
                      onPressed: () {
                        _searchCtrl.clear();
                        _load();
                        setState(() {});
                      },
                    ),
              filled: true,
              fillColor: _P.card,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _P.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _P.border),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _dd<String>(
                  value: _status,
                  hint: 'All status',
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All status')),
                    DropdownMenuItem(
                        value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(
                        value: 'approved', child: Text('Approved')),
                    DropdownMenuItem(
                        value: 'rejected', child: Text('Rejected')),
                  ],
                  onChanged: (v) {
                    setState(() => _status = v);
                    _load();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dd<String>(
                  value: _method,
                  hint: 'All types',
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All types')),
                    DropdownMenuItem(
                        value: 'delivery', child: Text('Delivery')),
                    DropdownMenuItem(
                        value: 'store_pickup', child: Text('Pickup')),
                  ],
                  onChanged: (v) {
                    setState(() => _method = v);
                    _load();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _dd<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(
                        value: 'created_at', child: Text('Sort: Date')),
                    DropdownMenuItem(
                        value: 'gold_amount', child: Text('Sort: Gold')),
                    DropdownMenuItem(
                        value: 'total_amount', child: Text('Sort: Amount')),
                  ],
                  onChanged: (v) {
                    setState(() => _sortBy = v ?? 'created_at');
                    _load();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: _P.card,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: _P.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(() => _sortOrder =
                        _sortOrder == 'desc' ? 'asc' : 'desc');
                    _load();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      _sortOrder == 'desc'
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      size: 18,
                      color: _P.t2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '$_total',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _P.t2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dd<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _P.card,
        border: Border.all(color: _P.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint ?? '',
              style: const TextStyle(fontSize: 12, color: _P.t2)),
          isDense: true,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading && !_loaded) {
      return Shimmer.fromColors(
        baseColor: const Color(0xFFE5E7EB),
        highlightColor: const Color(0xFFF3F4F6),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: 6,
          itemBuilder: (_, __) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }
    if (_history.isEmpty) {
      return const _EmptyState(
        icon: Icons.inbox_rounded,
        title: 'Nothing here',
        message: 'No redemptions match your filters',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final r = _history[i];
        return _HistoryCard(
          redemption: r,
          colorFor: widget.colorFor,
          labelFor: widget.labelFor,
        ).animate(delay: (20 * i).ms).fadeIn(duration: 240.ms);
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Redemption redemption;
  final Color Function(String?) colorFor;
  final String Function(String?) labelFor;

  const _HistoryCard({
    required this.redemption,
    required this.colorFor,
    required this.labelFor,
  });

  @override
  Widget build(BuildContext context) {
    final r = redemption;
    final sColor = r.approvalStatus.toUpperCase() == 'APPROVED'
        ? _P.okDeep
        : r.approvalStatus.toUpperCase() == 'REJECTED'
            ? _P.errDeep
            : _P.pending;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _P.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _P.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(
                  initials: _initials(r.userName),
                  color: sColor,
                  size: 30),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.userName.isNotEmpty ? r.userName : 'Unknown',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis),
                    Text(
                      r.userPhone.isNotEmpty
                          ? r.userPhone
                          : (r.userEmail.isNotEmpty
                              ? r.userEmail
                              : 'No contact'),
                      style: const TextStyle(fontSize: 11, color: _P.t2),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _Pill(
                label: r.approvalStatus.toUpperCase(),
                color: sColor,
                bg: sColor.withOpacity(0.1),
                bd: sColor.withOpacity(0.25),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (r.userEmail.isNotEmpty ||
              r.userBankName != null ||
              r.userTotalGrams > 0)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _P.softer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (r.userEmail.isNotEmpty)
                    _kv(Icons.email_outlined, 'Email', r.userEmail),
                  if (r.userBankName != null && r.userBankName!.isNotEmpty)
                    _kv(
                      Icons.account_balance_rounded,
                      'Bank',
                      '${r.userBankName}${r.userBankAccount != null ? ' • ${r.userBankAccount}' : ''}',
                    ),
                  if (r.userTotalGrams > 0)
                    _kv(
                      Icons.savings_outlined,
                      'Wallet',
                      '${r.userTotalGrams.toStringAsFixed(2)}g total, ${r.userLockedGrams.toStringAsFixed(2)}g locked',
                    ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _stat('Type',
                  r.deliveryMethod.toUpperCase() == 'STORE_PICKUP'
                      ? 'Store Pickup'
                      : 'Home Delivery'),
              _stat('Gold', '${r.goldAmount.toStringAsFixed(2)}g'),
              _stat('Total', '৳${r.totalAmount.toStringAsFixed(0)}'),
              if (r.deliveryStatus != null)
                _stat('Delivery', labelFor(r.deliveryStatus)!.toUpperCase(),
                    color: colorFor(r.deliveryStatus)),
            ],
          ),
          if (r.adminNote != null && r.adminNote!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _Note(note: r.adminNote!),
          ],
          if (r.redemptionAddress != null &&
              r.redemptionAddress!.isNotEmpty) ...[
            const SizedBox(height: 6),
            _Address(address: r.redemptionAddress!, compact: true),
          ],
        ],
      ),
    );
  }

  Widget _kv(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(icon, size: 12, color: _P.t3),
          const SizedBox(width: 5),
          Text('$label: ',
              style: const TextStyle(
                  fontSize: 10.5,
                  color: _P.t2,
                  fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 10.5, color: _P.t1),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: _P.t2)),
        const SizedBox(height: 1),
        Text(value,
            style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: color ?? _P.t1)),
      ],
    );
  }

  String _initials(String n) {
    if (n.isEmpty) return '?';
    final p = n.trim().split(RegExp(r'\s+'));
    if (p.length == 1) return p.first.substring(0, 1).toUpperCase();
    return (p.first.substring(0, 1) + p.last.substring(0, 1)).toUpperCase();
  }
}
