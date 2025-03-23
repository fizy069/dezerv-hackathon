import 'package:expense_advisor/model/trip_transaction.model.dart';
import 'package:expense_advisor/model/user.model.dart';

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
    // Handle both populated user objects and just user IDs
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

    // Handle transactions with proper error checking
    List<TripTransaction> transactions = [];
    if (json['transactions'] != null && json['transactions'] is List) {
      for (var t in json['transactions']) {
        if (t is Map<String, dynamic>) {
          // Check if this is a valid transaction with required fields
          if (t.containsKey('userId') &&
              t.containsKey('amount') &&
              t.containsKey('description')) {
            try {
              transactions.add(TripTransaction.fromJson(t));
            } catch (e) {
              print('Error parsing transaction: $e');
              // Skip this transaction if there's an error
            }
          } else {
            // Log malformed transaction for debugging
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
