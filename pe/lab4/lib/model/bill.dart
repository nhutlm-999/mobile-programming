class Bill {
  final int? id;
  final String billName;
  final String category;
  final double amount;
  final String status;
  final String dueDate;

  Bill({
    this.id,
    required this.billName,
    required this.category,
    required this.amount,
    required this.status,
    required this.dueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
      'bill_name': this.billName,
      'category': this.category,
      'amount': this.amount,
      'status': this.status,
      'due_date': this.dueDate,
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'],
      billName: map['bill_name'],
      category: map['category'],
      amount: map['amount'],
      status: map['status'],
      dueDate: map['due_date'],
    );
  }
}
