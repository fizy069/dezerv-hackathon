import 'package:expense_advisor/bloc/cubit/app_cubit.dart';
import 'package:expense_advisor/model/trip.model.dart';
import 'package:expense_advisor/model/user.model.dart';
import 'package:expense_advisor/services/trip_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TripDetailsScreen extends StatefulWidget {
  final Trip trip;

  const TripDetailsScreen({super.key, required this.trip});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen>
    with SingleTickerProviderStateMixin {
  late Trip _trip;
  bool _isLoading = false;
  final TripService _tripService = TripService();
  List<User> _users = [];
  String _userId = '';
  late TabController _tabController;

  Map<String, Map<String, double>> _settlements = {};

  bool _isAdVisible = true;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();

    final email =
        context.read<AppCubit>().state.email ??
        context.read<AppCubit>().state.username ??
        'guest@example.com';

    _userId = email;

    _calculateSettlements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _calculateSettlements() {
    _settlements = {};

    double totalExpenses = _trip.transactions.fold(
      0,
      (sum, transaction) => sum + transaction.amount,
    );

    Map<String, double> paid = {};
    for (var userId in _trip.users) {
      paid[userId] = 0;
    }

    for (var transaction in _trip.transactions) {
      paid[transaction.userId] =
          (paid[transaction.userId] ?? 0) + transaction.amount;
    }

    double equalShare = totalExpenses / _trip.users.length;

    Map<String, double> balance = {};
    for (var userId in _trip.users) {
      balance[userId] = (paid[userId] ?? 0) - equalShare;
    }

    List<String> creditors = [];
    List<String> debtors = [];

    for (var entry in balance.entries) {
      if (entry.value > 0) {
        creditors.add(entry.key);
      } else if (entry.value < 0) {
        debtors.add(entry.key);
      }
    }

    for (var creditor in creditors) {
      if (!_settlements.containsKey(creditor)) {
        _settlements[creditor] = {};
      }

      double remainingCredit = balance[creditor]!;

      for (var debtor in debtors) {
        if (remainingCredit <= 0 || balance[debtor]! >= 0) continue;

        double debtorOwes = -balance[debtor]!;
        double settlement =
            remainingCredit < debtorOwes ? remainingCredit : debtorOwes;

        _settlements[creditor]![debtor] = settlement;

        remainingCredit -= settlement;
        balance[debtor] = balance[debtor]! + settlement;

        if (remainingCredit <= 0.01) break;
      }
    }
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _tripService.getAllUsers();

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

    for (var user in _users) {
      if (user.email == userId) {
        return user.name;
      }
    }

    return 'Unknown User';
  }

  void _addExpense() async {
    final expenseData = await _showAddExpenseDialog();

    if (expenseData != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final email =
            context.read<AppCubit>().state.email ??
            context.read<AppCubit>().state.username ??
            'guest@example.com';

        final success = await _tripService.addTripTransaction(
          _trip.id,
          email,
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

            _calculateSettlements();
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Expenses'), Tab(text: 'Settlement')],
        ),
      ),
      body: Column(
        children: [
          _buildAdvertisementBanner(),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                      controller: _tabController,
                      children: [
                        Column(
                          children: [
                            _buildTripSummary(),
                            _buildTransactionsList(),
                          ],
                        ),

                        _buildSettlementsView(),
                      ],
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExpense,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  Widget _buildAdvertisementBanner() {
    if (!_isAdVisible) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 60,
      width: double.infinity,
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.credit_card, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Travel Smart with ExpenseCard',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'No foreign transaction fees & 2% cashback',
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Advertisement clicked')),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(60, 28),
            ),
            child: const Text('Learn More', style: TextStyle(fontSize: 12)),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() {
                _isAdVisible = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTripSummary() {
    double totalExpenses = _trip.transactions.fold(
      0,
      (sum, transaction) => sum + transaction.amount,
    );

    Map<String, double> perPersonExpenses = {};
    for (var userId in _trip.users) {
      perPersonExpenses[userId] = 0;
    }

    for (var transaction in _trip.transactions) {
      perPersonExpenses[transaction.userId] =
          (perPersonExpenses[transaction.userId] ?? 0) + transaction.amount;
    }

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trip Summary',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Expenses',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '\$${totalExpenses.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Per Person', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: perPersonExpenses.entries.length,
                itemBuilder: (context, index) {
                  final entry = perPersonExpenses.entries.elementAt(index);
                  bool isCurrentUser = entry.key == _userId;
                  String displayName = _getUserNameById(entry.key);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            isCurrentUser ? '$displayName (You)' : displayName,
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '\$${entry.value.toStringAsFixed(2)}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: entry.value > 0 ? Colors.green[700] : null,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
                userName.isNotEmpty
                    ? userName.substring(0, 1).toUpperCase()
                    : '?',
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

  Widget _buildSettlementsView() {
    double totalExpenses = _trip.transactions.fold(
      0,
      (sum, transaction) => sum + transaction.amount,
    );

    if (totalExpenses == 0) {
      return const Center(child: Text('No expenses to settle'));
    }

    double equalShare = totalExpenses / _trip.users.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total trip expenses:'),
                      Text(
                        '\$${totalExpenses.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Equal share per person:'),
                      Text(
                        '\$${equalShare.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Text('Settlements', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          if (_settlements.isEmpty)
            const Center(child: Text('Everyone has paid their fair share!')),

          ..._buildSettlementList(),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          Text('How it works:', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'We calculate the total expenses and divide them equally among all participants. '
            'Then we figure out who paid more than their share and who paid less. '
            'The settlements above show the minimum number of transactions needed to '
            'balance everyone\'s contributions.',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSettlementList() {
    List<Widget> settlements = [];

    _settlements.forEach((creditorId, debtors) {
      String creditorName = _getUserNameById(creditorId);
      bool isCreditorCurrentUser = creditorId == _userId;

      debtors.forEach((debtorId, amount) {
        String debtorName = _getUserNameById(debtorId);
        bool isDebtorCurrentUser = debtorId == _userId;

        String message;
        if (isCreditorCurrentUser) {
          message = '$debtorName owes you';
        } else if (isDebtorCurrentUser) {
          message = 'You owe $creditorName';
        } else {
          message = '$debtorName owes $creditorName';
        }

        settlements.add(
          Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            color:
                isCreditorCurrentUser || isDebtorCurrentUser
                    ? Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.3)
                    : null,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    isDebtorCurrentUser
                        ? Colors.red
                        : isCreditorCurrentUser
                        ? Colors.green
                        : Colors.grey,
                child: Icon(
                  isDebtorCurrentUser
                      ? Icons.arrow_upward
                      : isCreditorCurrentUser
                      ? Icons.arrow_downward
                      : Icons.swap_horiz,
                  color: Colors.white,
                ),
              ),
              title: Text(message),
              trailing: Text(
                '\$${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      });
    });

    return settlements;
  }
}
