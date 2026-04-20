class OnboardingStatusModel {
  final String status;
  final double requiredAmount;
  final double? paidAmount;
  final DateTime? paidAt;
  final String? waiverReason;
  final String? waiverDocument;

  OnboardingStatusModel({
    required this.status,
    required this.requiredAmount,
    this.paidAmount,
    this.paidAt,
    this.waiverReason,
    this.waiverDocument,
  });

  factory OnboardingStatusModel.fromJson(Map<String, dynamic> json) {
    // Some responses wrap in 'data', some might not
    final Map<String, dynamic> data = json.containsKey('data') ? json['data'] : json;

    double reqAmount = (data['requiredAmount'] ?? 100).toDouble();
    if (reqAmount <= 0) reqAmount = 100.0; // Default to 100 Rs if missing or zero

    return OnboardingStatusModel(
      status: data['status'] ?? 'PENDING',
      requiredAmount: reqAmount,
      paidAmount: data['paidAmount'] != null ? (data['paidAmount']).toDouble() : null,
      paidAt: data['paidAt'] != null ? DateTime.tryParse(data['paidAt']) : null,
      waiverReason: data['waiverReason'],
      waiverDocument: data['waiverDocument'],
    );
  }
}

class OnboardingPaymentIntent {
  final String id;
  final double amount;
  final String razorpayOrderId;
  final String module;
  final String key; // Razorpay Key

  OnboardingPaymentIntent({
    required this.id,
    required this.amount,
    required this.razorpayOrderId,
    required this.module,
    required this.key,
  });

  factory OnboardingPaymentIntent.fromJson(Map<String, dynamic> json) {
    dynamic node = json.containsKey('data') ? json['data'] : json;
    if (node is List && node.isNotEmpty) node = node.first;
    final Map<String, dynamic> data = node is Map ? Map<String, dynamic>.from(node) : {};

    return OnboardingPaymentIntent(
      id: data['paymentId'] ?? data['_id'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      razorpayOrderId: data['razorpayOrderId'] ?? '',
      module: data['module'] ?? 'ONBOARDING',
      key: data['key'] ?? '',
    );
  }
}

class OnboardingConfigModel {
  final String id;
  final double amount;
  final DateTime effectiveFrom;
  final String createdBy;

  OnboardingConfigModel({
    required this.id,
    required this.amount,
    required this.effectiveFrom,
    required this.createdBy,
  });

  factory OnboardingConfigModel.fromJson(Map<String, dynamic> json) {
    dynamic node = json.containsKey('data') ? json['data'] : json;
    if (node is List && node.isNotEmpty) node = node.first;
    final Map<String, dynamic> data = node is Map ? Map<String, dynamic>.from(node) : {};

    return OnboardingConfigModel(
      id: data['_id'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      effectiveFrom: data['effectiveFrom'] != null ? DateTime.tryParse(data['effectiveFrom']) ?? DateTime.now() : DateTime.now(),
      createdBy: data['createdBy'] ?? '',
    );
  }
}

class OnboardingStats {
  final int total;
  final int paid;
  final int waiverPending;
  final int waiverApproved;

  OnboardingStats({
    required this.total,
    required this.paid,
    required this.waiverPending,
    required this.waiverApproved,
  });

  factory OnboardingStats.fromJson(Map<String, dynamic> json) {
    dynamic node = json.containsKey('data') ? json['data'] : json;
    if (node is List && node.isNotEmpty) node = node.first;
    final Map<String, dynamic> data = node is Map ? Map<String, dynamic>.from(node) : {};

    return OnboardingStats(
      total: data['total'] ?? 0,
      paid: data['paid'] ?? 0,
      waiverPending: data['waiverPending'] ?? 0,
      waiverApproved: data['waiverApproved'] ?? 0,
    );
  }
}

class WaiverRequestModel {
  final String id;
  final String status;
  final String? waiverReason;
  final String? waiverDocumentUrl;
  
  // Requester Data nested obj
  final String requesterId;
  final String requesterName;
  final String requesterPhone;
  final String requesterRole;

  WaiverRequestModel({
    required this.id,
    required this.status,
    this.waiverReason,
    this.waiverDocumentUrl,
    required this.requesterId,
    required this.requesterName,
    required this.requesterPhone,
    required this.requesterRole,
  });

  factory WaiverRequestModel.fromJson(Map<String, dynamic> json) {
    // Fallback to the root json if 'requester' is not nested (i.e. if it returns the user directly)
    final req = json.containsKey('requester') ? json['requester'] : json;
    
    return WaiverRequestModel(
      id: json['_id'] ?? '',
      status: json['onboarding']?['status'] ?? 'PENDING',
      waiverReason: json['onboarding']?['waiverReason'],
      waiverDocumentUrl: json['onboarding']?['waiverDocument'],
      requesterId: req['_id'] ?? req['id'] ?? json['_id'] ?? json['id'] ?? '',
      requesterName: req['name'] ?? req['fullName'] ?? 'Unknown User',
      requesterPhone: req['phone'] ?? req['mobile'] ?? 'N/A',
      requesterRole: req['role'] ?? 'BENEFICIARY',
    );
  }
}

class PaginatedWaiversModel {
  final int total;
  final int totalPages;
  final List<WaiverRequestModel> data;

  PaginatedWaiversModel({
    required this.total,
    required this.totalPages,
    required this.data,
  });

  factory PaginatedWaiversModel.fromJson(Map<String, dynamic> json) {
    final dataNode = json.containsKey('data') ? json['data'] : json;
    
    // Check if it's the paginated format (has 'data' array inside 'data' node)
    final itemsList = (dataNode is Map && dataNode.containsKey('data')) 
        ? dataNode['data'] as List 
        : (dataNode is List ? dataNode : []);

    return PaginatedWaiversModel(
      total: dataNode is Map ? (dataNode['total'] ?? 0) : itemsList.length,
      totalPages: dataNode is Map ? (dataNode['totalPages'] ?? 1) : 1,
      data: itemsList.map((e) => WaiverRequestModel.fromJson(e)).toList(),
    );
  }
}