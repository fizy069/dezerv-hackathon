import 'package:expense_advisor/model/trip_transaction.model.dart';

class Trip {
  final String id;
  final String name;
  final List<String> users;
  final List<TripTransaction> transactions;
  final DateTime createdAt;

  Trip({
    required this.id,
    required this.name,
    required this.users,
    required this.transactions,
    required this.createdAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    List<String> userIds = [];
    if (json['users'] != null) {
      if (json['users'] is List) {
        for (var user in json['users']) {
          if (user is String) {
            userIds.add(user);
          } else if (user is Map<String, dynamic>) {
            userIds.add(user['_id'] ?? '');
          }
        }
      }
    }

    List<TripTransaction> transactions = [];
    if (json['transactions'] != null && json['transactions'] is List) {
      for (var t in json['transactions']) {
        if (t is Map<String, dynamic>) {
          if (t.containsKey('userId') &&
              t.containsKey('amount') &&
              t.containsKey('description')) {
            try {
              transactions.add(TripTransaction.fromJson(t));
            } catch (e) {
              print('Error parsing transaction: $e');
            }
          } else {
            print('Skipping malformed transaction: $t');
          }
        }
      }
    }

    return Trip(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      users: userIds,
      transactions: transactions,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'users': users,
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
