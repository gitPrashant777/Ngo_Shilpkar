class SchemeApplicationModel {
  final String id;
  final String status;
  final String schemeId;
  final String schemeName;
  final bool isActive;

  // Admin listing fields (from backend populate)
  final String beneficiaryName;
  final String category;

  SchemeApplicationModel({
    required this.id,
    required this.status,
    required this.schemeId,
    required this.schemeName,
    required this.isActive,
    required this.beneficiaryName,
    required this.category,
  });

  factory SchemeApplicationModel.fromJson(Map<String, dynamic> json) {
    final schemeData = json["scheme"];
    final beneficiary = json["beneficiary"];

    return SchemeApplicationModel(
      id: json["_id"] ?? "",
      status: json["status"] ?? "",
      schemeId: schemeData is Map ? schemeData["_id"] ?? "" : "",
      schemeName: schemeData is Map ? schemeData["name"] ?? "" : "",
      isActive: json["isActive"] ?? true,
      beneficiaryName: beneficiary?["firstName"] ?? "",
      category: beneficiary?["category"] ?? "",
    );
  }

  SchemeApplicationModel copyWith({
    String? status,
  }) {
    return SchemeApplicationModel(
      id: id,
      status: status ?? this.status,
      schemeId: schemeId,
      schemeName: schemeName,
      isActive: isActive,
      beneficiaryName: beneficiaryName,
      category: category,
    );
  }
}
