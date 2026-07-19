class Transaction {
  final String id;
  final String type;       // stored UPPERCASE internally
  final String status;     // stored UPPERCASE internally
  final double grams;
  final double pricePerGram;
  final double amountBdt;  // net amount after fee
  final double feePercent; // e.g. 0.03 = 3%
  final double feeAmount;  // computed: pricePerGram * grams * feePercent
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
  final String? userPhoto;
  final String? userPhone;

  Transaction({
    required this.id,
    required this.type,
    required this.status,
    required this.grams,
    required this.pricePerGram,
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
    this.userPhoto,
    this.userPhone,
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
    // API returns type like "sell_to_bank" — normalise to UPPERCASE
    final rawType   = (json['type']?.toString() ?? '').toUpperCase();
    final rawStatus = (json['status']?.toString() ?? '').toUpperCase();

    final grams        = _d(json['grams']);
    final pricePerGram = _d(json['price_per_g_bdt']);
    final amountBdt    = _d(json['amount_bdt']);

    // API uses deduction_rate (e.g. 0.03).
    // fee_percent / fee_amount may come from future API versions too — support both.
    final deductionRate = _d(json['deduction_rate']);
    final feePercent    = _d(json['fee_percent'] ?? json['deduction_rate']);

    // Compute fee amount: gross - net  OR  price * grams * rate
    double feeAmount = _d(json['fee_amount']);

    // REDEEM_COIN special handling:
    // Backend stores total_fee (e.g. 1260) in amount_bdt, NOT the gold value.
    // Gold value = grams * pricePerGram. Fee = amount_bdt.
    double computedAmountBdt = amountBdt;
    if (rawType == 'REDEEM_COIN' && grams > 0 && pricePerGram > 0) {
      computedAmountBdt = grams * pricePerGram;
      if (feeAmount == 0.0) {
        feeAmount = amountBdt; // amount_bdt holds the total fee for REDEEM_COIN
      }
    } else {
      if (feeAmount == 0.0 && pricePerGram > 0 && grams > 0 && deductionRate > 0) {
        feeAmount = pricePerGram * grams * deductionRate;
      }
      if (feeAmount == 0.0 && amountBdt > 0 && pricePerGram > 0 && grams > 0) {
        // gross = price * grams, fee = gross - net
        final gross = pricePerGram * grams;
        if (gross > amountBdt) feeAmount = gross - amountBdt;
      }
    }

    // Extract user information with debug logging
    final userId = json['user_id']?.toString();
    final userName = json['user_name']?.toString();
    final userEmail = json['user_email']?.toString();
    final userPhoto = json['user_photo']?.toString() ??
                      json['photo_url']?.toString() ??
                      json['profile_photo']?.toString();
    final userPhone = json['user_phone']?.toString() ??
                      json['phone_number']?.toString() ??
                      json['phone']?.toString();
    
    // Debug log for user data
    if (userId != null) {
      print('🔹 Transaction.fromJson - User Data:');
      print('   Transaction ID: ${json['id']}');
      print('   user_id: $userId');
      print('   user_name: $userName');
      print('   user_email: $userEmail');
      print('   user_photo: $userPhoto');
      print('   Available keys in JSON: ${json.keys.toList()}');
    }

    return Transaction(
      id:           json['id']?.toString() ?? '',
      type:         rawType,
      status:       rawStatus,
      grams:        grams,
      pricePerGram: pricePerGram,
      amountBdt:    computedAmountBdt,
      feePercent:   feePercent,
      feeAmount:    feeAmount,
      code:         json['code']?.toString(),
      expiryTime:   _dt(json['code_expires_at'] ?? json['expiry_time']),
      createdAt:    _dt(json['created_at']) ?? DateTime.now(),
      approvedAt:   _dt(json['approved_at']),
      paidAt:       _dt(json['paid_at']),
      rejectedAt:   _dt(json['rejected_at']),
      adminNote:    json['admin_note']?.toString(),
      userId:       userId,
      userName:     userName,
      userEmail:    userEmail,
      userPhoto:    userPhoto,
      userPhone:    userPhone,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'status': status,
    'grams': grams,
    'price_per_g_bdt': pricePerGram,
    'amount_bdt': amountBdt,
    'deduction_rate': feePercent,
    'fee_amount': feeAmount,
    'code': code,
    'code_expires_at': expiryTime?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'approved_at': approvedAt?.toIso8601String(),
    'paid_at': paidAt?.toIso8601String(),
    'rejected_at': rejectedAt?.toIso8601String(),
    'admin_note': adminNote,
    'user_id': userId,
    'user_name': userName,
    'user_email': userEmail,
    'user_photo': userPhoto,
    'user_phone': userPhone,
  };
}
