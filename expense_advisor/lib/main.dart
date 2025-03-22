import 'package:another_telephony/telephony.dart';
import 'package:expense_advisor/app.dart';
import 'package:expense_advisor/bloc/cubit/app_cubit.dart';
import 'package:expense_advisor/helpers/db.helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@pragma('vm:entry-point')
onBackgroundMessage(SmsMessage message) {
  print("onBackgroundMessage called");
  print("BACKGROUND SMS RECEIVED: ${message.body}");
  print("From: ${message.address}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await getDBInstance();
  AppState appState = await AppState.getState();

  runApp(
    MultiBlocProvider(
      providers: [BlocProvider(create: (_) => AppCubit(appState))],
      child: const App(),
    ),
  );
}
