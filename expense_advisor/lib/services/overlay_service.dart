import 'package:expense_advisor/helpers/notification_helper.dart';
import 'package:expense_advisor/services/sms_parser.dart';
import 'package:expense_advisor/widgets/category_selection_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayService {
  static Future<void> showCategorySelectionOverlay(
    String smsBody, {
    String? sender,
  }) async {
    final amount = SMSParser.extractAmount(smsBody);

    // Show notification first
    await NotificationHelper.showNotification(
      title: 'Payment Detected',
      body:
          amount != null
              ? 'Amount: ₹${amount.toStringAsFixed(2)}. Tap to categorize.'
              : 'New payment detected. Tap to categorize.',
    );

    // Request overlay permission if not granted
    if (!await NotificationHelper.checkOverlayPermission()) {
      final granted = await NotificationHelper.requestOverlayPermission();
      if (!granted) return;
    }

    // Show overlay window
    await FlutterOverlayWindow.showOverlay(
      enableDrag: true,
      height: 1000,
      width: WindowSize.matchParent,
      alignment: OverlayAlignment.center,
      flag: OverlayFlag.defaultFlag,
      overlayTitle: 'Expense Advisor',
      overlayContent: 'Select category for your transaction',
    );

    // Set the overlay content
    FlutterOverlayWindow.overlayListener.listen((event) {
      if (event == 'overlay_clicked') {
        // Handle overlay click events if needed
      }
    });

    // Add the overlay widget
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
        darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
        themeMode: ThemeMode.system,
        home: SafeArea(
          child: CategorySelectionOverlay(
            smsBody: smsBody,
            sender: sender,
            amount: amount,
          ),
        ),
      ),
    );
  }
}
