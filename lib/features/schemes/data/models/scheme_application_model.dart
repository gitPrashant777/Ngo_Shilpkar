class SchemeApplicationModel {
  final String id;
  final String status;
  final String schemeId;
  final String schemeName;
  final double schemePrice; // amount required for PAID scheme
  final bool isActive;
  final String paymentStatus;

  // Admin listing fields (from backend populate)
  final String beneficiaryName;
  final String category;

  final DateTime createdAt;

  SchemeApplicationModel({
    required this.id,
    required this.status,
    required this.schemeId,
    required this.schemeName,
    required this.schemePrice,
    required this.isActive,
    required this.paymentStatus,
    required this.beneficiaryName,
    required this.category,
    required this.createdAt,
  });

  factory SchemeApplicationModel.fromJson(Map<String, dynamic> json) {
    final schemeData = json["scheme"];
    final beneficiary = json["beneficiarySnapshot"] ?? json["beneficiary"];

    return SchemeApplicationModel(
      id: json["_id"] ?? "",
      status: json["status"] ?? "",
      schemeId: schemeData is Map ? schemeData["_id"] ?? "" : "",
      schemeName: schemeData is Map ? schemeData["name"] ?? "" : "",
      schemePrice: schemeData is Map ? (schemeData["price"] as num?)?.toDouble() ?? 0.0 : 0.0,
      isActive: json["isActive"] ?? true,
      paymentStatus: json["paymentStatus"] ?? "PENDING",
      beneficiaryName: beneficiary?["name"] ?? beneficiary?["firstName"] ?? "",
      category: beneficiary?["category"] ?? "",
      createdAt: json["createdAt"] != null ? DateTime.tryParse(json["createdAt"]) ?? DateTime.now() : DateTime.now(),
    );
  }

  SchemeApplicationModel copyWith({
    String? status,
    String? paymentStatus,
  }) {
    return SchemeApplicationModel(
      id: id,
      status: status ?? this.status,
      schemeId: schemeId,
      schemeName: schemeName,
      schemePrice: schemePrice,
      isActive: isActive,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      beneficiaryName: beneficiaryName,
      category: category,
      createdAt: createdAt,
    );
  }
}

class PaginatedApplicationsModel {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final List<SchemeApplicationModel> data;

  PaginatedApplicationsModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.data,
  });

  factory PaginatedApplicationsModel.fromJson(Map<String, dynamic> json) {
    return PaginatedApplicationsModel(
      page: json["page"] ?? 1,
      limit: json["limit"] ?? 10,
      total: json["total"] ?? 0,
      totalPages: json["totalPages"] ?? 1,
      data: (json["data"] as List?)?.map((e) => SchemeApplicationModel.fromJson(e)).toList() ?? [],
    );
  }
}
