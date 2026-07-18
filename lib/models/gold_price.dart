class GoldPrice {
  final double price;
  final double bankSellPrice;
  final double storeSellPrice;
  final DateTime createdAt;

  GoldPrice({
    required this.price,
    required this.bankSellPrice,
    required this.storeSellPrice,
    required this.createdAt,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  factory GoldPrice.fromJson(Map<String, dynamic> json) {
    DateTime createdAt;
    try {
      createdAt = DateTime.parse(json['created_at']?.toString() ?? '');
    } catch (_) {
      createdAt = DateTime.now();
    }
    return GoldPrice(
      price: _toDouble(json['price']),
      bankSellPrice: _toDouble(json['bank_sell_price']),
      storeSellPrice: _toDouble(json['store_sell_price']),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'bank_sell_price': bankSellPrice,
      'store_sell_price': storeSellPrice,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
