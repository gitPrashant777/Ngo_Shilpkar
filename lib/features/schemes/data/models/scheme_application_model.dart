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

  static SchemeApplicationModel _empty() {
    return SchemeApplicationModel(
      id: "",
      status: "UNKNOWN",
      schemeId: "",
      schemeName: "Unknown Scheme",
      schemePrice: 0.0,
      isActive: false,
      paymentStatus: "UNKNOWN",
      beneficiaryName: "Unknown Beneficiary",
      category: "Unknown Category",
      createdAt: DateTime.now(),
    );
  }

  factory SchemeApplicationModel.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) return _empty(); // safety

    try {
      final schemeData = json["scheme"] ?? json["schemeId"];
      final beneficiary = json["beneficiarySnapshot"] ?? json["beneficiary"];

      String parsedSchemeId = "";
      String parsedSchemeName = "";
      double parsedSchemePrice = 0.0;

      if (schemeData is Map) {
        parsedSchemeId = schemeData["_id"]?.toString() ?? "";
        parsedSchemeName = schemeData["name"]?.toString() ?? "";
        parsedSchemePrice = (schemeData["price"] as num?)?.toDouble() ?? 0.0;
      } else {
        parsedSchemeId = schemeData?.toString() ?? "";
      }

      // Fallback if scheme name is returned directly at root
      if (parsedSchemeName.isEmpty && json["schemeName"] != null) {
        parsedSchemeName = json["schemeName"].toString();
      }

      return SchemeApplicationModel(
        id: json["_id"]?.toString() ?? "",
        status: json["status"]?.toString() ?? "",
        schemeId: parsedSchemeId,
        schemeName: parsedSchemeName,
        schemePrice: parsedSchemePrice,
        isActive: json["isActive"] ?? true,
        paymentStatus: json["paymentStatus"]?.toString() ?? "PENDING",
        beneficiaryName: beneficiary is Map
            ? (beneficiary["name"]?.toString() ??
                  beneficiary["firstName"]?.toString() ??
                  "")
            : "",
        category: beneficiary is Map
            ? (beneficiary["category"]?.toString() ?? "")
            : "",
        createdAt: json["createdAt"] != null
            ? (DateTime.tryParse(json["createdAt"].toString()) ??
                  DateTime.now())
            : DateTime.now(),
      );
    } catch (e, st) {
      print("🚨 PARSING ERROR IN SchemeApplicationModel: $e");
      print("🚨 OFFENDING JSON: $json");
      print("🚨 STACK: $st");
      return _empty();
    }
  }

  SchemeApplicationModel copyWith({
    String? status,
    String? paymentStatus,
    String? schemeName,
    double? schemePrice,
  }) {
    return SchemeApplicationModel(
      id: id,
      status: status ?? this.status,
      schemeId: schemeId,
      schemeName: schemeName ?? this.schemeName,
      schemePrice: schemePrice ?? this.schemePrice,
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
      data:
          (json["data"] as List?)
              ?.map((e) => SchemeApplicationModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
