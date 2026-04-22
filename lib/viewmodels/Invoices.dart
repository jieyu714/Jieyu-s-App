class InvoiceModel {
  final String inputType;
  final String number;
  final String consumptionDate;
  final String? prizeType;
  final int? prizeAmount;

  InvoiceModel({
    required this.inputType,
    required this.number,
    required this.consumptionDate,
    this.prizeType,
    this.prizeAmount,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      inputType: json['inputType'] ?? '',
      number: json['number'] ?? '',
      consumptionDate: json['consumptionDate'] ?? '',
      prizeType: json['prizeType'] ?? '',
      prizeAmount: json['prizeAmount'] ?? 0,
    );
  }
}