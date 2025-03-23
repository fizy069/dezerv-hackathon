import 'package:expense_advisor/bloc/cubit/app_cubit.dart';
import 'package:expense_advisor/model/trip.model.dart';
import 'package:expense_advisor/screens/trips/create_trip.screen.dart';
import 'package:expense_advisor/screens/trips/trip_details.screen.dart';
import 'package:expense_advisor/services/trip_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TravelModeToggle extends StatelessWidget {
  const TravelModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Travel Mode",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Switch(
                    value: state.travelModeActive,
                    onChanged:
                        (value) => _handleTravelModeToggle(context, value),
                  ),
                ],
              ),
              if (state.travelModeActive) _buildActiveTripInfo(context, state),
              SizedBox(height: 5),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveTripInfo(BuildContext context, AppState state) {
    if (!state.travelModeActive || state.activeTripId == null) {
      return Row(
        children: [
          const Text("No active trip"),
          const Spacer(),
          TextButton(
            onPressed: () => _createNewTrip(context),
            child: const Text("Create Trip"),
          ),
        ],
      );
    }

    final tripService = TripService();
    final email = state.email ?? state.username ?? 'guest@example.com';

    return FutureBuilder<Trip?>(
      future: tripService.getActiveTrip(email, state.activeTripId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Row(
            children: [
              const Text("Error loading trip"),
              const Spacer(),
              TextButton(
                onPressed: () => _createNewTrip(context),
                child: const Text("Create Trip"),
              ),
            ],
          );
        }

        final trip = snapshot.data!;
        return InkWell(
          onTap: () => _openTripDetails(context, trip),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Active Trip: ${trip.name}",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "${trip.transactions.length} transactions",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        );
      },
    );
  }

  void _handleTravelModeToggle(BuildContext context, bool value) async {
    final appCubit = context.read<AppCubit>();
    final email =
        appCubit.state.email ?? appCubit.state.username ?? 'guest@example.com';

    if (value) {
      final tripService = TripService();
      final trips = await tripService.getUserTrips(email);

      if (trips.isEmpty) {
        appCubit.toggleTravelMode(value);
        _createNewTrip(context);
      } else if (trips.length == 1) {
        appCubit.toggleTravelMode(value, tripId: trips.first.id);
      } else {
        _showTripSelectionDialog(context, trips);
      }
    } else {
      appCubit.toggleTravelMode(value);
    }
  }

  void _showTripSelectionDialog(BuildContext context, List<Trip> trips) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a Trip'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: trips.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == trips.length) {
                  return ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Create New Trip'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _createNewTrip(context);
                    },
                  );
                }

                return ListTile(
                  title: Text(trips[index].name),
                  subtitle: Text(
                    '${trips[index].transactions.length} transactions',
                  ),
                  onTap: () {
                    context.read<AppCubit>().toggleTravelMode(
                      true,
                      tripId: trips[index].id,
                    );
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _createNewTrip(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CreateTripScreen()));
  }

  void _openTripDetails(BuildContext context, Trip trip) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TripDetailsScreen(trip: trip)),
    );
  }
}
