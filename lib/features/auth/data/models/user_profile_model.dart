class UserProfileModel {
  final UserData user;
  final ProfileData profile;

  UserProfileModel({
    required this.user,
    required this.profile,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    var sourceMap = json;
    if (json.containsKey('data') && json['data'] is Map) {
      sourceMap = json['data'] as Map<String, dynamic>;
    }
    
    return UserProfileModel(
      user: UserData.fromJson(sourceMap['user'] ?? {}),
      profile: ProfileData.fromJson(sourceMap['profile'] ?? {}),
    );
  }
}

class UserData {
  final String id;
  final String username;
  final String role;
  final String email;
  final String mobile;
  final bool isActive;
  final String? createdAt;

  UserData({
    required this.id,
    required this.username,
    required this.role,
    required this.email,
    required this.mobile,
    required this.isActive,
    this.createdAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'],
    );
  }
}

class ProfileData {
  final String? firstName;
  final String? lastName;
  final String? dob;
  final String? category;
  final String? paymentStatus;
  final LocationData location;
  final BankDetailsData bankDetails;
  final String? avatarUrl;
  final String? createdAt; // NEW FIELD FOR PROGRESS TRACKING

  ProfileData({
    this.firstName,
    this.lastName,
    this.dob,
    this.category,
    this.paymentStatus,
    required this.location,
    required this.bankDetails,
    this.avatarUrl,
    this.createdAt,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      firstName: json['firstName'],
      lastName: json['lastName'],
      dob: json['dob'],
      category: json['category'],
      paymentStatus: json['paymentStatus'],
      location: LocationData.fromJson(json['location'] ?? {}),
      bankDetails: BankDetailsData.fromJson(json['bankDetails'] ?? {}),
      avatarUrl: json['avatarUrl'],
      createdAt: json['createdAt'],
    );
  }
}

class LocationData {
  final String? state;
  final String? district;
  final String? taluka;
  final String? village;
  final String? address;

  LocationData({
    this.state,
    this.district,
    this.taluka,
    this.village,
    this.address,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      state: json['state'],
      district: json['district'],
      taluka: json['taluka'],
      village: json['village'],
      address: json['address'],
    );
  }
}

class BankDetailsData {
  final String? accountHolderName;
  final String? accountNumber;
  final String? ifsc;
  final String? accountType;
  final String? upiId;

  BankDetailsData({
    this.accountHolderName,
    this.accountNumber,
    this.ifsc,
    this.accountType,
    this.upiId,
  });

  factory BankDetailsData.fromJson(Map<String, dynamic> json) {
    return BankDetailsData(
      accountHolderName: json['accountHolderName'],
      accountNumber: json['accountNumber'],
      ifsc: json['ifsc'],
      accountType: json['accountType'],
      upiId: json['upiId'],
    );
  }
}
