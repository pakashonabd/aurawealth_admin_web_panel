class User {
  final String id;
  final String? firebaseUid;
  final String? email;
  final String? phoneNumber;
  final DateTime createdAt;
  final bool phoneVerified;
  final String kycStatus;
  final double? totalGrams;
  final double? lockedGrams;
  final double? availableGrams;

  User({
    required this.id,
    this.firebaseUid,
    this.email,
    this.phoneNumber,
    required this.createdAt,
    required this.phoneVerified,
    required this.kycStatus,
    this.totalGrams,
    this.lockedGrams,
    this.availableGrams,
  });

  static double? _d(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    DateTime createdAt;
    try {
      createdAt = DateTime.parse(json['created_at']?.toString() ?? '');
    } catch (_) {
      createdAt = DateTime.now();
    }
    return User(
      id: json['id']?.toString() ?? json['user_id']?.toString() ?? '',
      firebaseUid: json['firebase_uid']?.toString(),
      email: json['email']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      createdAt: createdAt,
      phoneVerified: json['phone_verified'] == true || json['phone_verified'] == 1,
      kycStatus: json['kyc_status']?.toString() ?? 'pending',
      totalGrams: _d(json['total_grams']),
      lockedGrams: _d(json['locked_grams']),
      availableGrams: _d(json['available_grams']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebase_uid': firebaseUid,
      'email': email,
      'phone_number': phoneNumber,
      'created_at': createdAt.toIso8601String(),
      'phone_verified': phoneVerified,
      'kyc_status': kycStatus,
      'total_grams': totalGrams,
      'locked_grams': lockedGrams,
      'available_grams': availableGrams,
    };
  }
}
