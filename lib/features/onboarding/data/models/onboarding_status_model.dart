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
    final data = json.containsKey('data') ? json['data'] : json;

    return OnboardingStatusModel(
      status: data['status'] ?? 'PENDING',
      requiredAmount: (data['requiredAmount'] ?? 0).toDouble(),
      paidAmount: data['paidAmount'] != null ? (data['paidAmount']).toDouble() : null,
      paidAt: data['paidAt'] != null ? DateTime.tryParse(data['paidAt']) : null,
      waiverReason: data['waiverReason'],
      waiverDocument: data['waiverDocument'],
    );
  }
}