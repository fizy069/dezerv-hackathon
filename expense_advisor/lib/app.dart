import 'package:another_telephony/telephony.dart';
import 'package:expense_advisor/bloc/cubit/app_cubit.dart';
import 'package:expense_advisor/main.dart';
import 'package:expense_advisor/screens/main.screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';

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
  }

  onMessage(SmsMessage message) async {
    setState(() {
      _message = message.body ?? "Error reading message body.";
    });

    // Add debug prints to terminal
    print("SMS RECEIVED: $_message");
    print("From: ${message.address}");
    print("Timestamp: ${message.date}");
  }

  onSendStatus(SendStatus status) {
    setState(() {
      _message = status == SendStatus.SENT ? "sent" : "delivered";
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final bool? result = await telephony.requestPhoneAndSmsPermissions;

      if (result != null && result) {
        print("SMS permissions granted");

        // Register the background handler
        telephony.listenIncomingSms(
          onNewMessage: onMessage,
          onBackgroundMessage: onBackgroundMessage, // Add this line
          listenInBackground: true, // Enable background listening
        );
      } else {
        print("SMS permissions denied");
      }
    } on PlatformException catch (e) {
    print("led to get permissions: ${e.message}");
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
          // localizationsDelegates:  [
          //   GlobalWidgetsLocalizations.delegate,
          //   GlobalMaterialLocalizations.delegate,
          // ],
        );
      },
    );
  }
}
