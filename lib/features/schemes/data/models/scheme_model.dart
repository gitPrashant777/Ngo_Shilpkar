// lib/features/schemes/data/models/scheme_model.dart

class SchemeModel {
  final String id;
  final String name;
  final String description;
  final List<String> benefits;
  final String status;
  final double price;
  final bool isActive;
  final String schemeType;
  final String financialType;
  final String payoutMode;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> eligibleCategories;

  SchemeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.benefits,
    required this.status,
    required this.price,
    required this.isActive,
    required this.schemeType,
    required this.financialType,
    required this.payoutMode,
    this.startDate,
    this.endDate,
    this.eligibleCategories = const [],
  });

  factory SchemeModel.fromJson(Map<String, dynamic> json) {
    return SchemeModel(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      benefits: List<String>.from(json["benefits"] ?? []),
      status: json["status"] ?? "",
      price: (json["price"] ?? 0).toDouble(),
      isActive: json["isActive"] ?? true,
      schemeType: json["schemeType"] ?? "FREE",
      financialType: json["financialType"] ?? "NONE",
      payoutMode: json["payoutMode"] ?? "NONE",
      startDate: json["startDate"] != null ? DateTime.tryParse(json["startDate"]) : null,
      endDate: json["endDate"] != null ? DateTime.tryParse(json["endDate"]) : null,
      eligibleCategories: List<String>.from(json["eligibleCategories"] ?? []),
    );
  }
}

class PaginatedSchemesModel {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final List<SchemeModel> data;

  PaginatedSchemesModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.data,
  });

  factory PaginatedSchemesModel.fromJson(Map<String, dynamic> json) {
    return PaginatedSchemesModel(
      page: json["page"] ?? 1,
      limit: json["limit"] ?? 10,
      total: json["total"] ?? 0,
      totalPages: json["totalPages"] ?? 1,
      data: (json["data"] as List?)?.map((e) => SchemeModel.fromJson(e)).toList() ?? [],
    );
  }
}

/// Same shape – used for the public / beneficiary published-schemes list
class PaginatedPublishedSchemesModel {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final List<SchemeModel> data;

  PaginatedPublishedSchemesModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.data,
  });

  factory PaginatedPublishedSchemesModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> rawList = [];
    if (json['data'] is List) rawList = json['data'] as List;
    else if (json['schemes'] is List) rawList = json['schemes'] as List;
    else if (json['results'] is List) rawList = json['results'] as List;

    return PaginatedPublishedSchemesModel(
      page: (json["page"] as num?)?.toInt() ?? 1,
      limit: (json["limit"] as num?)?.toInt() ?? 10,
      total: (json["total"] as num?)?.toInt() ?? 0,
      totalPages: (json["totalPages"] as num?)?.toInt() ?? 1,
      data: rawList.map((e) => SchemeModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
