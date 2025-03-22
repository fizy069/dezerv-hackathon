class TripTransaction {
  final String userId;
  final double amount;
  final String description;
  final DateTime date;

  TripTransaction({
    required this.userId,
    required this.amount,
    required this.description,
    required this.date,
  });

  factory TripTransaction.fromJson(Map<String, dynamic> json) {
    // Handle both string userId and populated user object
    String userId;
    if (json['userId'] is String) {
      userId = json['userId'];
    } else if (json['userId'] is Map<String, dynamic>) {
      userId = json['userId']['_id'];
    } else {
      userId = 'unknown';
    }

    return TripTransaction(
      userId: userId,
      amount: (json['amount'] is int) 
          ? (json['amount'] as int).toDouble() 
          : json['amount'].toDouble(),
      description: json['description'],
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
    };
  }
}
