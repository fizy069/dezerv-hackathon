import 'package:another_telephony/telephony.dart';
import 'package:expense_advisor/app.dart';
import 'package:expense_advisor/bloc/cubit/app_cubit.dart';
import 'package:expense_advisor/helpers/db.helper.dart';
import 'package:expense_advisor/widgets/category_selection_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

String _currentSmsBody = "No SMS content";
String? _currentSender;
double? _currentAmount;

Future<void> sendTransactionToAPI(
  double? amount,
  String category,
  String description,
) async {
  print("entered sendTransactionToAPI");
  if (amount == null) return;
  print("Sending transaction data to API");

  try {
    final response = await http.post(
      Uri.parse(''),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': 'test1@example.com',
        'amount': amount,
        'description': description,
        'date': DateTime.now().toIso8601String(),
        'category': category,
      }),
    );

    print('API Response Status: ${response.statusCode}');
    print('API Response Body: ${response.body}');
  } catch (e) {
    print('Error sending transaction data to API: $e');
  }
}

Future<void> showTransactionOverlay(
  String smsBody,
  String? sender,
  double? amount,
) async {
  final bool hasPermission = await FlutterOverlayWindow.isPermissionGranted();
  if (!hasPermission) {
    final bool? permissionGranted =
        await FlutterOverlayWindow.requestPermission();
    if (permissionGranted != true) {
      print("Overlay permission not granted");
      return;
    }
  }

  _currentSmsBody = smsBody;
  _currentSender = sender;
  _currentAmount = amount;

  if (await FlutterOverlayWindow.isActive()) {
    await FlutterOverlayWindow.closeOverlay();

    await Future.delayed(const Duration(milliseconds: 300));
  }

  await FlutterOverlayWindow.showOverlay(
    enableDrag: true,
    height: 550,
    width: WindowSize.matchParent,
    alignment: OverlayAlignment.center,
    flag: OverlayFlag.defaultFlag,
  );
}

@pragma('vm:entry-point')
onBackgroundMessage(SmsMessage message) async {
  print("onBackgroundMessage called");
  print("BACKGROUND SMS RECEIVED: ${message.body}");
  print("From: ${message.address}");

  if (message.body != null) {
    try {
      final String body = message.body!.toLowerCase();
      if (body.contains("debit") ||
          body.contains("debited") ||
          body.contains("credited") ||
          body.contains("transaction") ||
          body.contains("payment")) {
        print("Transaction SMS detected");

        double? amount;
        final RegExp regExp = RegExp(
          r'(?:rs\.?|inr)\s*(\d+(:?\,\d+)*(:?\.\d+)?)',
        );
        final match = regExp.firstMatch(body);
        if (match != null) {
          final amountStr = match.group(1)?.replaceAll(',', '');
          amount = double.tryParse(amountStr ?? '');
          print("Extracted amount: $amount");
        }

        print("Showing transaction overlay from background");
        await showTransactionOverlay(message.body!, message.address, amount);
      }
    } catch (e) {
      print("Error in background message handler: $e");
    }
  }
}

@pragma('vm:entry-point')
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        cardColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        cardColor: Color(0xFF1E1E1E),
      ),
      themeMode: ThemeMode.system,
      home: CategorySelectionOverlay(
        smsBody: _currentSmsBody,
        sender: _currentSender,
        amount: _currentAmount,
      ),
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await getDBInstance();
  AppState appState = await AppState.getState();

  final Telephony telephony = Telephony.instance;
  telephony.listenIncomingSms(
    onNewMessage: (SmsMessage message) async {
      print("NEW SMS: ${message.body}");
      print("From: ${message.address}");

      if (message.body != null) {
        try {
          final String body = message.body!.toLowerCase();
          if (body.contains("debit") ||
              body.contains("credit") ||
              body.contains("transaction") ||
              body.contains("payment")) {
            print("Transaction SMS detected in foreground");

            double? amount;
            final RegExp regExp = RegExp(
              r'(?:rs\.?|inr)\s*(\d+(:?\,\d+)*(:?\.\d+)?)',
            );
            final match = regExp.firstMatch(body);
            if (match != null) {
              final amountStr = match.group(1)?.replaceAll(',', '');
              amount = double.tryParse(amountStr ?? '');
              print("Extracted amount: $amount");

              await sendTransactionToAPI(
                amount,
                "uncategorized",
                message.body ?? "Transaction",
              );
            }

            print("Showing transaction overlay from foreground");
            await showTransactionOverlay(
              message.body!,
              message.address,
              amount,
            );
          }
        } catch (e) {
          print("Error handling SMS in foreground: $e");
        }
      }
    },
    onBackgroundMessage: onBackgroundMessage,
  );

  runApp(
    MultiBlocProvider(
      providers: [BlocProvider(create: (_) => AppCubit(appState))],
      child: const App(),
    ),
  );
}
