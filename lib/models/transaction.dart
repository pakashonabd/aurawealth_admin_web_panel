class Transaction {
  final String id;
  final String type;
  final String status;
  final double grams;
  final double amountBdt;
  final double feePercent;
  final double feeAmount;
  final String? code;
  final DateTime? expiryTime;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? paidAt;
  final DateTime? rejectedAt;
  final String? adminNote;
  final String? userId;
  final String? userName;
  final String? userEmail;

  Transaction({
    required this.id,
    required this.type,
    required this.status,
    required this.grams,
    required this.amountBdt,
    required this.feePercent,
    required this.feeAmount,
    this.code,
    this.expiryTime,
    required this.createdAt,
    this.approvedAt,
    this.paidAt,
    this.rejectedAt,
    this.adminNote,
    this.userId,
    this.userName,
    this.userEmail,
  });

  static double _d(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  static DateTime? _dt(dynamic v) {
    if (v == null) return null;
    try { return DateTime.parse(v.toString()); } catch (_) { return null; }
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      grams: _d(json['grams']),
      amountBdt: _d(json['amount_bdt']),
      feePercent: _d(json['fee_percent']),
      feeAmount: _d(json['fee_amount']),
      code: json['code']?.toString(),
      expiryTime: _dt(json['expiry_time']),
      createdAt: _dt(json['created_at']) ?? DateTime.now(),
      approvedAt: _dt(json['approved_at']),
      paidAt: _dt(json['paid_at']),
      rejectedAt: _dt(json['rejected_at']),
      adminNote: json['admin_note']?.toString(),
      userId: json['user_id']?.toString(),
      userName: json['user_name']?.toString(),
      userEmail: json['user_email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'status': status,
      'grams': grams,
      'amount_bdt': amountBdt,
      'fee_percent': feePercent,
      'fee_amount': feeAmount,
      'code': code,
      'expiry_time': expiryTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'rejected_at': rejectedAt?.toIso8601String(),
      'admin_note': adminNote,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
    };
  }
}
