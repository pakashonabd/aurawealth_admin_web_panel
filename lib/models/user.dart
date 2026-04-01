class User {
  final String id;
  final String? firebaseUid;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime createdAt;
  final bool phoneVerified;
  final String kycStatus;
  final double? totalGrams;
  final double? lockedGrams;
  final double? availableGrams;

  User({
    required this.id,
    this.firebaseUid,
    this.name,
    this.email,
    this.phoneNumber,
    this.photoUrl,
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
    
    final id = json['id']?.toString() ?? json['user_id']?.toString() ?? '';
    final name = json['name']?.toString() ?? json['user_name']?.toString();
    final email = json['email']?.toString() ?? json['user_email']?.toString();
    final photoUrl = json['photo_url']?.toString() ?? 
                     json['profile_photo']?.toString() ?? 
                     json['user_photo']?.toString();
    
    print('🔸 User.fromJson:');
    print('   ID: $id');
    print('   Name: $name');
    print('   Email: $email');
    print('   PhotoUrl: $photoUrl');
    print('   JSON keys: ${json.keys.toList()}');
    
    return User(
      id: id,
      firebaseUid: json['firebase_uid']?.toString(),
      name: name,
      email: email,
      phoneNumber: json['phone_number']?.toString(),
      photoUrl: photoUrl,
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
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
      'phone_verified': phoneVerified,
      'kyc_status': kycStatus,
      'total_grams': totalGrams,
      'locked_grams': lockedGrams,
      'available_grams': availableGrams,
    };
  }
}
