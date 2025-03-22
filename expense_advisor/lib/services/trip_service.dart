import 'dart:convert';
import 'package:expense_advisor/model/trip.model.dart';
import 'package:expense_advisor/model/user.model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TripService {
  final String baseUrl = 'http://10.70.109.97:3000';

  // Get all users
  Future<List<User>> getAllUsers() async {
    print('Fetching all users');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/trip/users'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Get users response status: ${response.statusCode}');
      print('Get users response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> usersJson = json.decode(response.body);
        print('Users JSON: $usersJson');
        return usersJson.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAllUsers: $e');
      rethrow;
    }
  }

  // Get all trips for a user by email
  Future<List<Trip>> getUserTrips(String email) async {
    print('Fetching trips for user email: $email');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/trip/user-trips'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      print('Get user trips response status: ${response.statusCode}');
      print('Get user trips response body: ${response.body} for user email: $email');
      if (response.statusCode == 200) {
        List<dynamic> tripsJson = json.decode(response.body);
        return tripsJson.map((json) => Trip.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load trips: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getUserTrips: $e');
      return []; // Return empty list on error
    }
  }

  // Create a new trip
  Future<Trip> createTrip(String name, List<String> userIds) async {
    print('Creating trip: name=$name, users=$userIds');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/trip/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'userIds': userIds}),
      );

      print('Create trip response status: ${response.statusCode}');
      print('Create trip response body: ${response.body}');
      if (response.statusCode == 200) {
        return Trip.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create trip: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in createTrip: $e');
      rethrow;
    }
  }

  // Add a transaction to a trip
  Future<bool> addTripTransaction(
    String tripId,
    String userId,
    double amount,
    String description,
  ) async {
    print(
      'Adding transaction: tripId=$tripId, userId=$userId, amount=$amount, description=$description',
    );
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/trip/$tripId/transaction'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'amount': amount,
          'description': description,
          'date': DateTime.now().toIso8601String(),
        }),
      );

      print('Add transaction response status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error in addTripTransaction: $e');
      return false;
    }
  }

  // Get active trip (we'll use user-trips and just return the latest one if needed)
  Future<Trip?> getActiveTrip(String email, String tripId) async {
    print('Fetching active trip for user: $email with tripId: $tripId');
    try {
      // Get all user trips
      final trips = await getUserTrips(email);

      // Find the trip matching the active trip ID
      for (var trip in trips) {
        if (trip.id == tripId) {
          return trip;
        }
      }
      return null;
    } catch (e) {
      print('Error in getActiveTrip: $e');
      return null;
    }
  }
}
