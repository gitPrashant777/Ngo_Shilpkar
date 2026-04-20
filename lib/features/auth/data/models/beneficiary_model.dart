class BeneficiaryModel {
  final String id;
  final String firstName;
  final String lastName;
  final String mobile;
  final String email;
  final String category;
  final String paymentStatus;
  final String state;
  final String district;
  final String taluka;
  final String village;
  final String address;
  final String avatarUrl;

  // Bank Details
  final String accountHolderName;
  final String accountNumber;
  final String ifsc;
  final String accountType;

  BeneficiaryModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.mobile,
    required this.email,
    required this.category,
    required this.paymentStatus,
    required this.state,
    required this.district,
    required this.taluka,
    required this.village,
    required this.address,
    required this.avatarUrl,
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifsc,
    required this.accountType,
  });

  factory BeneficiaryModel.fromJson(Map<String, dynamic> json) {
    // The API structure for user list typically wraps unique fields in a 'beneficiary' object
    // inside the user object, or flattens them. 
    // Based on create-user payload, 'beneficiary' is a nested object. 
    // However, for GET /users, it might be flattened or nested.
    // Assuming a flattened structure for now based on typical profile/me responses, 
    // BUT since this is a list, it might be:
    // { "user": { ... }, "profile": { ... } } OR combined.
    // Let's assume a combined stricture for now, or adapt based on API testing.
    
    // SAFE PARSING: Check if 'beneficiary' key exists, otherwise assume root.
    final profile = json['beneficiary'] ?? json; 
    final location = profile['location'] ?? {};
    final bank = profile['bankDetails'] ?? {};

    return BeneficiaryModel(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: profile['firstName'] ?? '',
      lastName: profile['lastName'] ?? '',
      mobile: json['mobile'] ?? '', // Mobile is usually on User model too
      email: json['email'] ?? '',
      category: profile['category'] ?? '',
      paymentStatus: profile['paymentStatus'] ?? 'UNPAID',
      state: location['state'] ?? '',
      district: location['district'] ?? '',
      taluka: location['taluka'] ?? '',
      village: location['village'] ?? '',
      address: location['address'] ?? '',
      avatarUrl: profile['avatarUrl'] ?? '',
      accountHolderName: bank['accountHolderName'] ?? '',
      accountNumber: bank['accountNumber'] ?? '',
      ifsc: bank['ifsc'] ?? '',
      accountType: bank['accountType'] ?? '',
    );
  }
}
