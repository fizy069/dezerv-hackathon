import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  late String? username;
  late int themeColor;
  late String? currency;
  late int? age;
  late double? income;
  late String? email;
  late bool travelModeActive;
  late String? activeTripId;

  static Future<AppState> getState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? themeColor = prefs.getInt("themeColor");
    String? username = prefs.getString("username");
    String? currency = prefs.getString("currency");
    int? age = prefs.getInt("age");
    double? income = prefs.getDouble("income");
    String? email = prefs.getString("email");
    bool travelModeActive = prefs.getBool("travelModeActive") ?? false;
    String? activeTripId = prefs.getString("activeTripId");

    AppState appState = AppState();
    appState.themeColor = themeColor ?? Colors.green.value;
    appState.username = username;
    appState.currency = currency;
    appState.age = age;
    appState.income = income;
    appState.email = email;
    appState.travelModeActive = travelModeActive;
    appState.activeTripId = activeTripId;

    return appState;
  }
}

class AppCubit extends Cubit<AppState> {
  AppCubit(AppState initialState) : super(initialState);

  Future<void> updateUsername(username) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("username", username);
    emit(await AppState.getState());
  }

  Future<void> updateCurrency(currency) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("currency", currency);
    emit(await AppState.getState());
  }

  Future<void> updateThemeColor(int color) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("themeColor", color);
    emit(await AppState.getState());
  }

  Future<void> updateAge(int age) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("age", age);
    emit(await AppState.getState());
  }

  Future<void> updateIncome(double income) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("income", income);
    emit(await AppState.getState());
  }

  Future<void> updateEmail(String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("email", email);
    emit(await AppState.getState());
  }

  Future<void> toggleTravelMode(bool active, {String? tripId}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("travelModeActive", active);

    if (active && tripId != null) {
      await prefs.setString("activeTripId", tripId);
    } else if (!active) {
      await prefs.remove("activeTripId");
    }

    emit(await AppState.getState());
  }

  Future<void> setActiveTrip(String tripId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("activeTripId", tripId);
    emit(await AppState.getState());
  }

  Future<void> reset() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("currency");
    await prefs.remove("themeColor");
    await prefs.remove("username");
    await prefs.remove("age");
    await prefs.remove("income");
    await prefs.remove("email");
    await prefs.remove("travelModeActive");
    await prefs.remove("activeTripId");
    emit(await AppState.getState());
  }
}
