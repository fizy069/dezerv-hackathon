import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        //welpwelp do this
      },
    );
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'expense_advisor_channel',
          'Expense Advisor Notifications',
          channelDescription: 'Notifications for SMS payments',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  static Future<bool> requestOverlayPermission() async {
    final status = await Permission.systemAlertWindow.request();
    return status.isGranted;
  }

  static Future<bool> checkOverlayPermission() async {
    return await FlutterOverlayWindow.isPermissionGranted();
  }

  static Future<void> showOverlayWindow() async {
    if (await checkOverlayPermission()) {
      await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        height: 1000,
        width: 400,
        alignment: OverlayAlignment.center,
        flag: OverlayFlag.defaultFlag,
      );
    }
  }
}
