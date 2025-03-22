import 'package:expense_advisor/bloc/cubit/app_cubit.dart';
import 'package:expense_advisor/model/trip.model.dart';
import 'package:expense_advisor/model/trip_transaction.model.dart';
import 'package:expense_advisor/model/user.model.dart';
import 'package:expense_advisor/services/trip_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TripDetailsScreen extends StatefulWidget {
  final Trip trip;

  const TripDetailsScreen({Key? key, required this.trip}) : super(key: key);

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  late Trip _trip;
  bool _isLoading = false;
  final TripService _tripService = TripService();
  List<User> _users = [];
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    _loadUsers();

    // Find current user's ID
    final email =
        context.read<AppCubit>().state.email ??
        context.read<AppCubit>().state.username ??
        'guest@example.com';

    _userId = email; // Temporarily use email as ID until users are loaded
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _tripService.getAllUsers();

      // Find current user
      final email =
          context.read<AppCubit>().state.email ??
          context.read<AppCubit>().state.username;

      String userId = '';
      if (email != null) {
        for (var user in users) {
          if (user.email == email) {
            userId = user.id;
            break;
          }
        }
      }

      if (mounted) {
        setState(() {
          _users = users;
          if (userId.isNotEmpty) {
            _userId = userId;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading users: $e');
    }
  }

  String _getUserNameById(String userId) {
    for (var user in _users) {
      if (user.id == userId) {
        return user.name;
      }
    }

    // If not found by ID, try matching by email
    // This is a fallback since sometimes we just have email addresses
    for (var user in _users) {
      if (user.email == userId) {
        return user.name;
      }
    }

    return 'Unknown User';
  }

  void _addExpense() async {
    // Show expense form dialog
    final expenseData = await _showAddExpenseDialog();

    if (expenseData != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await _tripService.addTripTransaction(
          _trip.id,
          _userId,
          expenseData['amount'],
          expenseData['description'],
        );

        if (success) {
          _refreshTripData();
        } else {
          throw Exception('Failed to add expense');
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding expense: $e')));
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>?> _showAddExpenseDialog() async {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Trip Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (amountController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty) {
                  Navigator.pop(context, {
                    'amount': double.parse(amountController.text),
                    'description': descriptionController.text,
                  });
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _refreshTripData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final email =
          context.read<AppCubit>().state.email ??
          context.read<AppCubit>().state.username ??
          'guest@example.com';

      final trips = await _tripService.getUserTrips(email);

      for (var trip in trips) {
        if (trip.id == _trip.id) {
          setState(() {
            _trip = trip;
          });
          break;
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to refresh trip data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_trip.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTripData,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [_buildTripSummary(), _buildTransactionsList()],
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExpense,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  Widget _buildTripSummary() {
    // Calculate total expenses
    double totalExpenses = _trip.transactions.fold(
      0,
      (sum, transaction) => sum + transaction.amount,
    );

    // Calculate per-person expenses
    Map<String, double> perPersonExpenses = {};
    for (var userId in _trip.users) {
      perPersonExpenses[userId] = 0;
    }

    for (var transaction in _trip.transactions) {
      perPersonExpenses[transaction.userId] =
          (perPersonExpenses[transaction.userId] ?? 0) + transaction.amount;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trip Summary', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Expenses',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '\$${totalExpenses.toStringAsFixed(2)}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Per Person', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...perPersonExpenses.entries.map((entry) {
            bool isCurrentUser = entry.key == _userId;
            String displayName = _getUserNameById(entry.key);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isCurrentUser ? '$displayName (You)' : displayName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '\$${entry.value.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (_trip.transactions.isEmpty) {
      return const Expanded(
        child: Center(child: Text('No expenses recorded yet')),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _trip.transactions.length,
        itemBuilder: (context, index) {
          final transaction = _trip.transactions[index];
          final isCurrentUser = transaction.userId == _userId;
          final userName = _getUserNameById(transaction.userId);

          return ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  isCurrentUser
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
              child: Text(
                userName.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(transaction.description),
            subtitle: Text(
              '${DateFormat('MMM d, yyyy').format(transaction.date)} • $userName',
            ),
            trailing: Text(
              '\$${transaction.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}
