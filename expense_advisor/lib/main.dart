import 'package:another_telephony/telephony.dart';
import 'package:expense_advisor/app.dart';
import 'package:expense_advisor/bloc/cubit/app_cubit.dart';
import 'package:expense_advisor/helpers/db.helper.dart';
import 'package:expense_advisor/services/payment_service.dart';
import 'package:expense_advisor/widgets/category_selection_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

// Global variables to store transaction data for the overlay
String _currentSmsBody = "No SMS content";
String? _currentSender;
double? _currentAmount;

Future<void> showTransactionOverlay(
  String smsBody,
  String? sender,
  double? amount,
) async {
  // Check if permission is granted
  final bool hasPermission = await FlutterOverlayWindow.isPermissionGranted();
  if (!hasPermission) {
    final bool? permissionGranted =
        await FlutterOverlayWindow.requestPermission();
    if (permissionGranted != true) {
      print("Overlay permission not granted");
      return;
    }
  }

  // Store the data globally since we can't pass it directly
  _currentSmsBody = smsBody;
  _currentSender = sender;
  _currentAmount = amount;

  // Close any existing overlay
  if (await FlutterOverlayWindow.isActive()) {
    await FlutterOverlayWindow.closeOverlay();
    // Add a small delay to ensure proper closing
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // Show the overlay without the extras parameter
  await FlutterOverlayWindow.showOverlay(
    enableDrag: true,
    height: 550, // Reduce height to fit better
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
      // Check if SMS contains transaction information
      final String body = message.body!.toLowerCase();
      if (body.contains("debit") ||
          body.contains("debited") ||
          body.contains("credited") ||
          body.contains("transaction") ||
          body.contains("payment")) {
        print("Transaction SMS detected");

        // Extract amount (simple example)
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

        // Show the overlay with transaction details
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

  // Remove the registerHandler call as it's not available in your version

  await getDBInstance();
  AppState appState = await AppState.getState();

  final Telephony telephony = Telephony.instance;
  telephony.listenIncomingSms(
    onNewMessage: (SmsMessage message) async {
      // Add async here
      print("NEW SMS: ${message.body}");
      print("From: ${message.address}");

      if (message.body != null) {
        try {
          // Check if SMS contains transaction information
          final String body = message.body!.toLowerCase();
          if (body.contains("debit") ||
              body.contains("credit") ||
              body.contains("transaction") ||
              body.contains("payment")) {
            print("Transaction SMS detected in foreground");

            // Extract amount (simple example)
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

            // Show the overlay with transaction details
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
