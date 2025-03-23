import 'package:another_telephony/telephony.dart';
import 'package:expense_advisor/bloc/cubit/app_cubit.dart';
import 'package:expense_advisor/helpers/notification_helper.dart';
import 'package:expense_advisor/main.dart';
import 'package:expense_advisor/screens/main.screen.dart';
import 'package:expense_advisor/services/overlay_service.dart';
import 'package:expense_advisor/services/sms_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final telephony = Telephony.instance;
  String _message = "";

  @override
  void initState() {
    super.initState();
    initPlatformState();
    NotificationHelper.initialize();
  }

  onMessage(SmsMessage message) async {
    setState(() {
      _message = message.body ?? "Error reading message body.";
    });

    print("SMS RECEIVED: $_message");
    print("From: ${message.address}");
    print("Timestamp: ${message.date}");

    if (message.body != null && SMSParser.isPaymentSMS(message.body!)) {
      await OverlayService.showCategorySelectionOverlay(
        message.body!,
        sender: message.address,
      );
    }
  }

  Future<void> initPlatformState() async {
    try {
      final bool? result = await telephony.requestPhoneAndSmsPermissions;

      if (result != null && result) {
        print("SMS permissions granted");

        await NotificationHelper.requestOverlayPermission();

        telephony.listenIncomingSms(
          onNewMessage: onMessage,
          onBackgroundMessage: onBackgroundMessage,
          listenInBackground: true,
        );
      } else {
        print("SMS permissions denied");
      }
    } on PlatformException catch (e) {
      print("Failed to get permissions: ${e.message}");
    }

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: MediaQuery.of(context).platformBrightness,
      ),
    );
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Dezerv',
          theme: ThemeData(
            useMaterial3: true,
            brightness: MediaQuery.of(context).platformBrightness,
            navigationBarTheme: NavigationBarThemeData(
              labelTextStyle: WidgetStateProperty.resolveWith((
                Set<WidgetState> states,
              ) {
                TextStyle style = const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                );
                if (states.contains(WidgetState.selected)) {
                  style = style.merge(
                    const TextStyle(fontWeight: FontWeight.w600),
                  );
                }
                return style;
              }),
            ),
          ),
          home: const MainScreen(),
        );
      },
    );
  }
}
