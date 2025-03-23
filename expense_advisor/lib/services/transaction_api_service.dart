import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:expense_advisor/model/payment.model.dart';

class TransactionApiService {
  final String baseUrl = '';

  Future<List<Payment>> getTransactions(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transactions?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Payment.fromApiJson(json)).toList();
      } else {
        throw Exception('Failed to load transactions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching transactions: $e');
    }
  }

  Future<Payment> createTransaction({
    required String userId,
    required double amount,
    required String description,
    required DateTime date,
    required PaymentType type,
    required String title,
    required int accountId,
    required int categoryId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transaction'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'amount': amount,
          'description': description,
          'date': date.toIso8601String(),
          'type': type == PaymentType.credit ? 'CR' : 'DR',
          'title': title,
          'accountId': accountId,
          'categoryId': categoryId,
        }),
      );

      if (response.statusCode == 200) {
        return Payment.fromApiJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create transaction: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating transaction: $e');
    }
  }

  Future<void> updateTransaction(Payment payment) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/transaction/${payment.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payment.toApiJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update transaction: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating transaction: $e');
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/transaction/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete transaction: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting transaction: $e');
    }
  }
}
