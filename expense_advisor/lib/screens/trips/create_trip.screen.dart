import 'package:expense_advisor/bloc/cubit/app_cubit.dart';
import 'package:expense_advisor/model/user.model.dart';
import 'package:expense_advisor/services/trip_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<String> _participantIds = [];
  final List<User> _availableUsers = [];
  bool _isLoading = false;
  bool _isLoadingUsers = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      final tripService = TripService();
      final users = await tripService.getAllUsers();

      debugPrint('Loaded ${users.length} users');

      if (users.isNotEmpty) {
        for (var user in users) {
          debugPrint('User: ${user.name} (${user.email}), ID: ${user.id}');
        }
      } else {
        debugPrint('No users found');
      }

      if (mounted) {
        setState(() {
          _availableUsers.clear();
          _availableUsers.addAll(users);

          final currentUserEmail =
              context.read<AppCubit>().state.email ??
              context.read<AppCubit>().state.username;

          debugPrint('Current user email: $currentUserEmail');

          if (currentUserEmail != null) {
            for (var user in users) {
              if (user.email == currentUserEmail) {
                _currentUserId = user.id;
                _participantIds.add(user.id);
                debugPrint('Found current user: ${user.name} (${user.id})');
                break;
              }
            }
          }

          if (_currentUserId == null && users.isNotEmpty) {
            _currentUserId = users.first.id;
            _participantIds.add(users.first.id);
            debugPrint('Added first user as default: ${users.first.name}');
          }

          _isLoadingUsers = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading users: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load users: $e')));
        setState(() {
          _isLoadingUsers = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addParticipant(String userId) {
    if (!_participantIds.contains(userId)) {
      setState(() {
        _participantIds.add(userId);
      });
    }
  }

  void _removeParticipant(String userId) {
    if (userId != _currentUserId) {
      setState(() {
        _participantIds.remove(userId);
      });
    }
  }

  String _getUserNameById(String id) {
    for (var user in _availableUsers) {
      if (user.id == id) {
        return user.name;
      }
    }
    return 'Unknown';
  }

  String _getUserEmailById(String id) {
    for (var user in _availableUsers) {
      if (user.id == id) {
        return user.email;
      }
    }
    return '';
  }

  Future<void> _createTrip() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_participantIds.isEmpty) {
          throw Exception('Please add at least one participant');
        }

        debugPrint('Creating trip with name: ${_nameController.text}');

        final List<String> participantEmails =
            _participantIds.map((userId) {
              return _getUserEmailById(userId);
            }).toList();

        debugPrint('Participants (IDs): $_participantIds');
        debugPrint('Participants (Emails): $participantEmails');

        final tripService = TripService();
        final trip = await tripService.createTrip(
          _nameController.text,
          participantEmails,
        );

        context.read<AppCubit>().toggleTravelMode(true, tripId: trip.id);

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        debugPrint('Error creating trip: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to create trip: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showUserSelectionDialog() {
    if (_availableUsers.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No users available')));
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Participants'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _availableUsers.length,
              itemBuilder: (context, index) {
                final user = _availableUsers[index];
                final isSelected = _participantIds.contains(user.id);
                final isCurrentUser = user.id == _currentUserId;

                return CheckboxListTile(
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  value: isSelected,
                  enabled: !isCurrentUser,
                  onChanged:
                      isCurrentUser
                          ? null
                          : (selected) {
                            if (selected == true) {
                              _addParticipant(user.id);
                            } else {
                              _removeParticipant(user.id);
                            }
                            Navigator.pop(context);
                            _showUserSelectionDialog();
                          },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Trip')),
      body:
          _isLoadingUsers
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Trip Name',
                          hintText: 'e.g., Weekend Getaway',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a trip name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Participants',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _showUserSelectionDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _participantIds.isEmpty
                          ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text('No participants selected'),
                            ),
                          )
                          : Expanded(
                            child: ListView.builder(
                              itemCount: _participantIds.length,
                              itemBuilder: (context, index) {
                                final userId = _participantIds[index];
                                final isCurrentUser = userId == _currentUserId;

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      child: Text(
                                        _getUserNameById(userId).isNotEmpty
                                            ? _getUserNameById(
                                              userId,
                                            ).substring(0, 1).toUpperCase()
                                            : '?',
                                      ),
                                    ),
                                    title: Text(_getUserNameById(userId)),
                                    subtitle: Text(_getUserEmailById(userId)),
                                    trailing:
                                        isCurrentUser
                                            ? const Chip(label: Text('You'))
                                            : IconButton(
                                              icon: const Icon(
                                                Icons.remove_circle_outline,
                                                color: Colors.red,
                                              ),
                                              onPressed:
                                                  () => _removeParticipant(
                                                    userId,
                                                  ),
                                            ),
                                  ),
                                );
                              },
                            ),
                          ),
                    ],
                  ),
                ),
              ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _createTrip,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child:
              _isLoading
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Create Trip'),
        ),
      ),
    );
  }
}
