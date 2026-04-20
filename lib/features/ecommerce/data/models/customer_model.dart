class CustomerModel {
  final String id;
  final String email;
  final String? fullName;
  final String? mobile;
  final DateTime? createdAt;

  CustomerModel({
    required this.id,
    required this.email,
    this.fullName,
    this.mobile,
    this.createdAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString(),
      mobile: json['mobile']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'mobile': mobile,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
