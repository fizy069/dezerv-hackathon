import 'package:expense_advisor/model/account.model.dart';
import 'package:expense_advisor/model/category.model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum PaymentType { debit, credit }

class Payment {
  int? id;
  Account account;
  Category category;
  double amount;
  PaymentType type;
  DateTime datetime;
  String title;
  String description;

  Payment({
    this.id,
    required this.account,
    required this.category,
    required this.amount,
    required this.type,
    required this.datetime,
    required this.title,
    required this.description,
  });

  factory Payment.fromJson(Map<String, dynamic> data) {
    return Payment(
      id: data["id"],
      title: data["title"] ?? "",
      description: data["description"] ?? "",
      account: Account.fromJson(data["account"]),
      category: Category.fromJson(data["category"]),
      amount: data["amount"],
      type: data["type"] == "CR" ? PaymentType.credit : PaymentType.debit,
      datetime: DateTime.parse(data["datetime"]),
    );
  }

  // Updated method to handle API responses with the account model
  factory Payment.fromApiJson(Map<String, dynamic> data) {
    return Payment(
      id: data["id"],
      title: data["title"] ?? "",
      description: data["description"] ?? "",
      account: Account(
        id: data["accountId"],
        name: data["accountName"] ?? "Default Account",
        holderName: data["accountHolderName"] ?? "",
        accountNumber: data["accountNumber"] ?? "",
        icon: const IconData(
          0xe332,
          fontFamily: 'MaterialIcons',
        ), // Default icon
        color: Color(data["accountColor"] ?? 0xFF000000),
        isDefault: false,
      ),
      category: Category(
        id: data["categoryId"],
        name: data["categoryName"] ?? "Default Category",
        color: Colors.black,
        icon: Icons.sports_baseball_sharp,
      ),
      amount: data["amount"].toDouble(),
      type: data["type"] == "CR" ? PaymentType.credit : PaymentType.debit,
      datetime: DateTime.parse(data["date"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "account": account.id,
    "category": category.id,
    "amount": amount,
    "datetime": DateFormat('yyyy-MM-dd kk:mm:ss').format(datetime),
    "type": type == PaymentType.credit ? "CR" : "DR",
  };

  // Updated API request method to include all account fields
  Map<String, dynamic> toApiJson() => {
    "id": id,
    "title": title,
    "description": description,
    "accountId": account.id,
    "accountName": account.name,
    "accountHolderName": account.holderName,
    "accountNumber": account.accountNumber,
    "accountColor": account.color.value,
    "categoryId": category.id,
    "categoryName": category.name,
    "amount": amount,
    "date": datetime.toIso8601String(),
    "type": type == PaymentType.credit ? "CR" : "DR",
    "userId": "", // This should be filled from the app state
  };
}
