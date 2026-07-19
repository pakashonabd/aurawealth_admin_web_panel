import '../core/constants/app_constants.dart';

class User {
  final String id;
  final String? backendId;
  final String? firebaseUid;
  final String role;
  final bool isAdmin;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? photoUrl;
  final String? accountNumber;
  final String? bankName;
  final String? nationalId;
  final String? nidFrontUrl;
  final String? nidBackUrl;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool? hasFingerprint;
  final bool? hasPasscode;
  final bool? otpVerified;
  final bool phoneVerified;
  final String kycStatus;
  final double? totalGrams;
  final double? lockedGrams;
  final double? availableGrams;
  final DateTime? walletUpdatedAt;

  User({
    required this.id,
    this.backendId,
    this.firebaseUid,
    this.role = 'user',
    this.isAdmin = false,
    this.name,
    this.email,
    this.phoneNumber,
    this.photoUrl,
    this.accountNumber,
    this.bankName,
    this.nationalId,
    this.nidFrontUrl,
    this.nidBackUrl,
    required this.createdAt,
    this.lastLogin,
    this.hasFingerprint,
    this.hasPasscode,
    this.otpVerified,
    required this.phoneVerified,
    required this.kycStatus,
    this.totalGrams,
    this.lockedGrams,
    this.availableGrams,
    this.walletUpdatedAt,
  });

  static double? _d(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static bool? _b(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final lower = v.toLowerCase();
      if (lower == 'true' || lower == '1' || lower == 'yes') return true;
      if (lower == 'false' || lower == '0' || lower == 'no') return false;
    }
    return null;
  }

  static DateTime? _dt(dynamic v) {
    if (v == null || v.toString().isEmpty) return null;
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return null;
    }
  }

  static String? _cleanString(dynamic v) {
    if (v == null) return null;
    final text = v.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
  }

  static String? _normalizeImageUrl(dynamic v) {
    final raw = _cleanString(v);
    if (raw == null) return null;
    if (raw.startsWith('http://') ||
        raw.startsWith('https://') ||
        raw.startsWith('data:')) {
      return raw;
    }

    final path = raw.startsWith('/') ? raw : '/$raw';
    return '${AppConstants.baseUrl}$path';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final wallet = json['wallet'] is Map
        ? Map<String, dynamic>.from(json['wallet'] as Map)
        : <String, dynamic>{};

    final backendId = json['id']?.toString() ?? json['user_id']?.toString();
    final firebaseUid =
        json['firebase_uid']?.toString() ?? json['uid']?.toString();
    // Existing admin flows identify users by UID. Prefer Firebase UID while
    // keeping the PostgreSQL ID separately in [backendId] for display/details.
    final id = firebaseUid ?? backendId ?? '';
    final name = json['name']?.toString() ?? json['user_name']?.toString();
    final email = json['email']?.toString() ?? json['user_email']?.toString();
    final phoneNumber =
        json['phoneNumber']?.toString() ?? json['phone_number']?.toString();
    final photoUrl =
        _normalizeImageUrl(json['profileImageUrl']) ??
        _normalizeImageUrl(json['profile_image_url']) ??
        _normalizeImageUrl(json['profile_image']) ??
        _normalizeImageUrl(json['photo_url']) ??
        _normalizeImageUrl(json['profile_photo']) ??
        _normalizeImageUrl(json['avatar']) ??
        _normalizeImageUrl(json['image']) ??
        _normalizeImageUrl(json['user_photo']);
    final createdAt =
        _dt(json['createdAt'] ?? json['created_at']) ?? DateTime.now();

    if (photoUrl != null) {
      print(
        '👤 User image URL: user=${name ?? email ?? phoneNumber ?? id} url=$photoUrl',
      );
    } else {
      print(
        '👤 User image URL: user=${name ?? email ?? phoneNumber ?? id} url=<none>',
      );
    }

    return User(
      id: id,
      backendId: backendId,
      firebaseUid: firebaseUid,
      role: json['role']?.toString() ?? 'user',
      isAdmin: _b(json['is_admin']) ?? false,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      photoUrl: photoUrl,
      accountNumber:
          json['accountNumber']?.toString() ??
          json['account_number']?.toString(),
      bankName: json['bankName']?.toString() ?? json['bank_name']?.toString(),
      nationalId:
          json['nationalId']?.toString() ?? json['national_id']?.toString(),
      nidFrontUrl:
          json['nidFrontUrl']?.toString() ?? json['nid_front_url']?.toString(),
      nidBackUrl:
          json['nidBackUrl']?.toString() ?? json['nid_back_url']?.toString(),
      createdAt: createdAt,
      lastLogin: _dt(json['lastLogin'] ?? json['last_login']),
      hasFingerprint: _b(json['hasFingerprint'] ?? json['has_fingerprint']),
      hasPasscode: _b(json['hasPasscode'] ?? json['has_passcode']),
      otpVerified: _b(json['otp_verified']),
      phoneVerified:
          _b(json['phone_verified']) ?? _b(json['otp_verified']) ?? false,
      kycStatus: (json['kyc_status'] ?? json['kycStatus'])?.toString() ?? 'pending',
      totalGrams: _d(wallet['total_grams'] ?? json['total_grams']),
      lockedGrams: _d(wallet['locked_grams'] ?? json['locked_grams']),
      availableGrams: _d(wallet['available_grams'] ?? json['available_grams']),
      walletUpdatedAt: _dt(wallet['updated_at'] ?? json['wallet_updated_at']),
    );
  }

  String get displayName => name ?? email ?? phoneNumber ?? 'User';

  String get initials {
    if (name != null && name!.trim().isNotEmpty) {
      final parts = name!.trim().split(RegExp(r'\s+'));
      if (parts.length > 1) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return parts.first[0].toUpperCase();
    }
    if (email != null && email!.isNotEmpty) return email![0].toUpperCase();
    if (phoneNumber != null && phoneNumber!.isNotEmpty) return phoneNumber![0];
    return 'U';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': backendId,
      'firebase_uid': firebaseUid,
      'role': role,
      'is_admin': isAdmin,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': photoUrl,
      'accountNumber': accountNumber,
      'bankName': bankName,
      'nationalId': nationalId,
      'nidFrontUrl': nidFrontUrl,
      'nidBackUrl': nidBackUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'hasFingerprint': hasFingerprint,
      'hasPasscode': hasPasscode,
      'otp_verified': otpVerified,
      'phone_verified': phoneVerified,
      'kyc_status': kycStatus,
      'wallet': {
        'total_grams': totalGrams,
        'locked_grams': lockedGrams,
        'available_grams': availableGrams,
        'updated_at': walletUpdatedAt?.toIso8601String(),
      },
    };
  }
}
