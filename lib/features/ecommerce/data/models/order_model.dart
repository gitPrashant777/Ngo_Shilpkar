class OrderAddress {
  final String street;
  final String city;
  final String state;
  final String pincode;

  OrderAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.pincode,
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'pincode': pincode,
    };
  }
}

class OrderModel {
  final String id;
  final String productId;
  final String? productName;
  final String? productImage;
  final int quantity;
  final OrderAddress address;
  final String status; // PENDING, CONFIRMED, DELIVERED, REFUND_REQUESTED, REFUNDED, REPLACED
  final String paymentStatus; // UNPAID, PAID, FAILED, REFUNDED
  final double totalAmount;
  final String currency;
  final String? razorpayOrderId;
  final DateTime? createdAt;
  final DateTime? deliveredAt;
  final DateTime? refundExpiryAt;
  final bool isReplacement;
  final String? replacementOf;

  OrderModel({
    required this.id,
    required this.productId,
    this.productName,
    this.productImage,
    required this.quantity,
    required this.address,
    required this.status,
    this.paymentStatus = 'UNPAID',
    required this.totalAmount,
    this.currency = 'INR',
    this.razorpayOrderId,
    this.createdAt,
    this.deliveredAt,
    this.refundExpiryAt,
    this.isReplacement = false,
    this.replacementOf,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    String pId = '';
    String? pName;
    String? pImage;

    if (json['productId'] != null) {
      if (json['productId'] is Map) {
        pId = json['productId']['_id'] ?? json['productId']['id'] ?? '';
        pName = json['productId']['name'];
        if (json['productId']['images'] != null && json['productId']['images'] is List && json['productId']['images'].isNotEmpty) {
          pImage = json['productId']['images'][0];
        } else if (json['productId']['image'] != null) {
          pImage = json['productId']['image'];
        }
      } else {
        pId = json['productId'].toString();
      }
    }

    return OrderModel(
      id: json['_id'] ?? json['id'] ?? '',
      productId: pId,
      productName: pName,
      productImage: pImage,
      quantity: json['quantity'] ?? 1,
      address: json['address'] != null 
          ? OrderAddress.fromJson(json['address'])
          : OrderAddress(street: '', city: '', state: '', pincode: ''),
      status: json['orderStatus'] ?? json['status'] ?? 'PENDING',
      paymentStatus: json['paymentStatus'] ?? 'UNPAID',
      totalAmount: (json['totalAmount'] ?? json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'INR',
      razorpayOrderId: json['razorpayOrderId'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      deliveredAt: json['deliveredAt'] != null ? DateTime.tryParse(json['deliveredAt']) : null,
      refundExpiryAt: json['refundExpiryAt'] != null ? DateTime.tryParse(json['refundExpiryAt']) : null,
      isReplacement: json['isReplacement'] ?? false,
      replacementOf: json['replacementOf'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'address': address.toJson(),
      'status': status,
      'paymentStatus': paymentStatus,
      'totalAmount': totalAmount,
      'currency': currency,
      if (razorpayOrderId != null) 'razorpayOrderId': razorpayOrderId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (deliveredAt != null) 'deliveredAt': deliveredAt!.toIso8601String(),
      if (isReplacement) 'isReplacement': isReplacement,
      if (replacementOf != null) 'replacementOf': replacementOf,
    };
  }
}
