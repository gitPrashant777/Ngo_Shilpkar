class ReturnRequestModel {
  final String id;
  final String orderId;
  final String type; // REFUND, REPLACEMENT
  final String status; // REQUESTED, APPROVED, REJECTED, REFUNDED, REPLACED
  final String? reason;
  final String? adminRemark;
  final String? refundId;
  final String? replacementOrderId;
  final String? requesterName;
  final String? requesterAvatar;
  final String? requesterPhone;
  final String? requesterId;
  final String? transactionId;
  final DateTime? transactionCreatedAt;
  final String? paymentMethod;
  final double? paidAmount;
  final double? requestedAmount;
  final String? verificationStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReturnRequestModel({
    required this.id,
    required this.orderId,
    required this.type,
    required this.status,
    this.reason,
    this.adminRemark,
    this.refundId,
    this.replacementOrderId,
    this.requesterName,
    this.requesterAvatar,
    this.requesterPhone,
    this.requesterId,
    this.transactionId,
    this.transactionCreatedAt,
    this.paymentMethod,
    this.paidAmount,
    this.requestedAmount,
    this.verificationStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory ReturnRequestModel.fromJson(Map<String, dynamic> json) {
    // orderId may be a populated object or a plain string
    String parsedOrderId = '';
    if (json['orderId'] is Map) {
      parsedOrderId = json['orderId']['_id'] ?? json['orderId']['id'] ?? '';
    } else {
      parsedOrderId = json['orderId'] ?? '';
    }

    Map<String, dynamic>? requester;
    if (json['requester'] is Map) {
      requester = Map<String, dynamic>.from(json['requester']);
    } else if (json['user'] is Map) {
      requester = Map<String, dynamic>.from(json['user']);
    } else if (json['beneficiary'] is Map) {
      requester = Map<String, dynamic>.from(json['beneficiary']);
    }
    final payment = json['paymentId'] is Map
        ? Map<String, dynamic>.from(json['paymentId'])
        : null;

    double? parseAmount(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return ReturnRequestModel(
      id: json['_id'] ?? json['id'] ?? '',
      orderId: parsedOrderId,
      type: json['type'] ?? 'REFUND',
      status: json['status'] ?? 'PENDING',
      reason: json['reason'],
      adminRemark: json['adminRemark'],
      refundId: json['refundId'],
      replacementOrderId: json['replacementOrderId'],
      requesterName: json['requesterName'] ??
          requester?['name'] ??
          requester?['fullName'] ??
          requester?['firstName'],
      requesterAvatar: json['requesterAvatar'] ??
          requester?['avatar'] ??
          requester?['image'],
      requesterPhone: json['requesterPhone'] ??
          requester?['mobile'] ??
          requester?['phone'],
      requesterId: json['requesterId'] ??
          requester?['_id'] ??
          requester?['id'],
      transactionId: json['transactionId'] ??
          payment?['razorpayPaymentId'] ??
          json['razorpayPaymentId'],
      transactionCreatedAt: payment?['createdAt'] != null
          ? DateTime.tryParse(payment!['createdAt'].toString())
          : null,
      paymentMethod: json['paymentMethod'] ??
          payment?['paymentMethod'] ??
          json['method'],
      paidAmount:
          parseAmount(json['paidAmount'] ?? payment?['amount'] ?? json['totalPaid']),
      requestedAmount:
          parseAmount(json['requestedAmount'] ?? json['amount']),
      verificationStatus: json['verificationStatus'] ??
          (requester?['isVerified'] == true ? 'KYC Verified' : null) ??
          requester?['verificationStatus'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'type': type,
      'reason': reason,
      'status': status,
    };
  }
}
