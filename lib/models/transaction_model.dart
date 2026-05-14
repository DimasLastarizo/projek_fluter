enum TransactionType {
  income,
  expense,
}

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.type,
    required this.date,
  });

  final String id;
  final double amount;
  final String description;
  final TransactionType type;
  final DateTime date;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'type': type.name,
      'date': date.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String,
      type: _parseTransactionType(map['type'] as String?),
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
    );
  }

  static TransactionType _parseTransactionType(String? value) {
    switch (value) {
      case 'income':
        return TransactionType.income;
      case 'expense':
      default:
        return TransactionType.expense;
    }
  }
}
