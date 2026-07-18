class Redemption {
  final String txId;
  final String userId;
  final String userName;
  final String userPhone;
  final String userEmail;
  final String deliveryMethod;
  final String? deliveryStatus;
  final String approvalStatus;
  final String? adminNote;
  final String? redemptionAddress;
  final double goldAmount;
  final double feeAmount;
  final double vatAmount;
  final double totalAmount;
  final String createdAt;

  Redemption({
    required this.txId,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.userEmail,
    required this.deliveryMethod,
    this.deliveryStatus,
    required this.approvalStatus,
    this.adminNote,
    this.redemptionAddress,
    required this.goldAmount,
    required this.feeAmount,
    required this.vatAmount,
    required this.totalAmount,
    required this.createdAt,
  });

  factory Redemption.fromJson(Map<String, dynamic> json) {
    return Redemption(
      txId: json['tx_id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      userPhone: json['user_phone'] ?? '',
      userEmail: json['user_email'] ?? '',
      deliveryMethod: json['delivery_method'] ?? '',
      deliveryStatus: json['delivery_status'],
      approvalStatus: json['approval_status'] ?? '',
      adminNote: json['admin_note'],
      redemptionAddress: json['redemption_address'],
      goldAmount: (json['gold_amount'] ?? 0).toDouble(),
      feeAmount: (json['fee_amount'] ?? 0).toDouble(),
      vatAmount: (json['vat_amount'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      createdAt: json['created_at'] ?? '',
    );
  }
}
