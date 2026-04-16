class RecordItem {
  int? id;
  int? contactId;
  DateTime transactionDate;
  String type;
  String item;
  String? description;
  int amount;
  String currency;
  String? paymentMethod;
  DateTime? settlementDate;

  RecordItem({
    this.id,
    this.contactId,
    required this.transactionDate,
    required this.type,
    required this.item,
    this.description,
    required this.amount,
    required this.currency,
    this.paymentMethod,
    this.settlementDate
  });

  factory RecordItem.fromJson(Map<String, dynamic> json) {
    return RecordItem(
      id: json["id"],
      contactId: json["contactId"],
      transactionDate: json["transactionDate"] != null ? DateTime.parse(json["transactionDate"]) : DateTime.now(),
      type: json["type"],
      item: json["item"],
      description: json["description"] ?? "",
      amount: json["amount"],
      currency: json["currency"],
      paymentMethod: json["paymentMethod"],
      settlementDate: json["settlementDate"] != null ? DateTime.parse(json["settlementDate"]) : null
    );
  }
}