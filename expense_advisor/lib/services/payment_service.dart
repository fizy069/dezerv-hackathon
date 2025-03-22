// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:logger/logger.dart';

// class PaymentService {
//   static final PaymentService _instance = PaymentService._internal();
//   final Logger _logger = Logger();
//   final String baseUrl = 'http://localhost:3000';

//   factory PaymentService() {
//     return _instance;
//   }

//   PaymentService._internal();

//   Future<bool> processPayment(
//     String amount, {
//     String? recipient,
//     String? description,
//     String category = 'Other',
//   }) async {
//     try {
//       final cleanAmount = _extractAmount(amount);
//       if (cleanAmount == null) {
//         _logger.e('Invalid amount format: $amount');
//         return false;
//       }

//       final response = await http.post(
//         Uri.parse(baseUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer YOUR_API_KEY', // Replace with actual API key
//         },
//         body: jsonEncode({
//           'amount': cleanAmount,
//           'recipient': recipient ?? 'default-recipient',
//           'description': description ?? 'Payment from SMS',
//           'category': category,
//           'timestamp': DateTime.now().toIso8601String(),
//         }),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         _logger.i('Payment successful: $cleanAmount to $recipient');
//         return true;
//       } else {
//         _logger.e('Payment failed: ${response.statusCode} - ${response.body}');
//         return false;
//       }
//     } catch (e) {
//       _logger.e('Error processing payment: $e');
//       return false;
//     }
//   }

//   double? _extractAmount(String text) {
//     final amountRegex = RegExp(
//       r'(?:Rs\.?|₹|\$)?\s?(\d+(?:[,.]\d+)?)(?:\s?(?:INR|USD|EUR))?',
//     );

//     final match = amountRegex.firstMatch(text);
//     if (match != null && match.group(1) != null) {
//       final amount = match.group(1)!.replaceAll(',', '');
//       return double.tryParse(amount);
//     }
//     return null;
//   }
// }
