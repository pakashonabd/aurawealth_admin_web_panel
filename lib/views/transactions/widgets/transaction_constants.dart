import 'package:flutter/material.dart';

// ── Lottie URLs ───────────────────────────────────────────────────────────────
const lottieApproved = 'https://assets9.lottiefiles.com/packages/lf20_jbrw3hcz.json';
const lottieRejected = 'https://assets7.lottiefiles.com/packages/lf20_qmfs6c3i.json';
const lottieEmpty    = 'https://assets5.lottiefiles.com/packages/lf20_szlepvdh.json';
const lottieLoading  = 'https://assets2.lottiefiles.com/packages/lf20_usmfx6bp.json';

// ── Distinct PNG per transaction type ─────────────────────────────────────────
const pngBuyApp    = 'https://cdn-icons-png.flaticon.com/128/1170/1170678.png';
const pngBuyStore  = 'https://cdn-icons-png.flaticon.com/128/869/869636.png';
const pngSellBank  = 'https://cdn-icons-png.flaticon.com/128/2830/2830284.png';
const pngSellStore = 'https://cdn-icons-png.flaticon.com/128/1198/1198385.png';
const pngExchange  = 'https://cdn-icons-png.flaticon.com/128/1023/1023539.png';

// ── Design tokens ─────────────────────────────────────────────────────────────
const bg         = Color(0xFFF6F7FB);
const surface    = Colors.white;
const border     = Color(0xFFEDF0F7);
const sheetBg    = Color(0xFFF7F9FC);
const cardBg     = Color(0xFFFCFDFF);
const cardBorder = Color(0xFFE6ECF5);
const textPri    = Color(0xFF0F1828);
const textSec    = Color(0xFF6B7A99);
const textMuted  = Color(0xFFAAB4CC);
const radius     = 14.0;
const radiusSm   = 9.0;

// Per-type accent palette
const colBuyApp    = Color(0xFF0288D1);
const colBuyStore  = Color(0xFF00897B);
const colSellBank  = Color(0xFF5C4033);
const colSellStore = Color(0xFFE53935);
const colExchange  = Color(0xFF7B1FA2);

// Status palette
const colPending  = Color(0xFFF59E0B);
const colApproved = Color(0xFF10B981);
const colPaid     = Color(0xFF3B82F6);
const colRejected = Color(0xFFEF4444);

// ── Pure helpers ──────────────────────────────────────────────────────────────

Color statusColor(String s) {
  switch (s.toUpperCase()) {
    case 'PENDING':  return colPending;
    case 'APPROVED': return colApproved;
    case 'PAID':     return colPaid;
    case 'REJECTED': return colRejected;
    default:         return textSec;
  }
}

IconData statusIcon(String s) {
  switch (s.toUpperCase()) {
    case 'PENDING':  return Icons.schedule_rounded;
    case 'APPROVED': return Icons.check_circle_rounded;
    case 'PAID':     return Icons.payments_rounded;
    case 'REJECTED': return Icons.cancel_rounded;
    default:         return Icons.help_rounded;
  }
}

Color typeColor(String t) {
  switch (t.toUpperCase()) {
    case 'BUY_IN_APP':            return colBuyApp;
    case 'BUY_IN_STORE':          return colBuyStore;
    case 'SELL_TO_BANK':          return colSellBank;
    case 'SELL_TO_STORE':         return colSellStore;
    case 'EXCHANGE_TO_JEWELLERY': return colExchange;
    case 'REDEEM_COIN':           return colSellBank;
    default:                      return textSec;
  }
}

String typeLabel(String t) {
  switch (t.toUpperCase()) {
    case 'BUY_IN_APP':            return 'Buy In App';
    case 'BUY_IN_STORE':          return 'Buy In Store';
    case 'SELL_TO_BANK':          return 'Sell to Bank';
    case 'SELL_TO_STORE':         return 'Sell to Store';
    case 'EXCHANGE_TO_JEWELLERY': return 'Exchange';
    case 'REDEEM_COIN':           return 'Redeem Coin';
    default:
      return t.replaceAll('_', ' ').split(' ').map((w) =>
      w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
      ).join(' ');
  }
}

String pngForType(String t) {
  switch (t.toUpperCase()) {
    case 'BUY_IN_APP':            return pngBuyApp;
    case 'BUY_IN_STORE':          return pngBuyStore;
    case 'SELL_TO_BANK':          return pngSellBank;
    case 'SELL_TO_STORE':         return pngSellStore;
    case 'EXCHANGE_TO_JEWELLERY': return pngExchange;
    case 'REDEEM_COIN':           return pngSellBank;
    default:                      return pngExchange;
  }
}

IconData iconForType(String t) {
  switch (t.toUpperCase()) {
    case 'BUY_IN_APP':            return Icons.phone_android_rounded;
    case 'BUY_IN_STORE':          return Icons.shopping_bag_rounded;
    case 'SELL_TO_BANK':          return Icons.account_balance_rounded;
    case 'SELL_TO_STORE':         return Icons.storefront_rounded;
    case 'EXCHANGE_TO_JEWELLERY': return Icons.swap_horiz_rounded;
    case 'REDEEM_COIN':           return Icons.monetization_on_rounded;
    default:                      return Icons.receipt_long_rounded;
  }
}
