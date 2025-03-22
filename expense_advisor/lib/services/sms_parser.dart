class SMSParser {
  static double? extractAmount(String message) {
    final RegExp amountRegex = RegExp(
      r'(?:(?:Rs\.?|INR)\s*)?(\d+(?:,\d+)*(?:\.\d+)?)(?:\s*(?:debited|credited|paid|received|sent))?',

      caseSensitive: false,
    );

    final match = amountRegex.firstMatch(message);
    if (match != null && match.group(1) != null) {
      String amountStr = match.group(1)!.replaceAll(',', '');
      try {
        return double.parse(amountStr);
      } catch (e) {
        print("Failed to parse amount: $e");
      }
    }
    return null;
  }

  static bool isPaymentSMS(String message) {
    final paymentKeywords = [
      'debited',
      'credited',
      'transaction',
      'payment',
      'spent',
      'paid',
      'purchase',
      'debit',
      'credit',
    ];

    final messageLower = message.toLowerCase();
    return paymentKeywords.any((keyword) => messageLower.contains(keyword));
  }
}
