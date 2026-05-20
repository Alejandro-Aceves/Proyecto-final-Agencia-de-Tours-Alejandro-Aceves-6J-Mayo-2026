import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/models/models.dart';
import 'package:lifetours/providers/providers.dart';
import 'package:lifetours/widgets/bottom_nav_bar.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  @override
  void initState() {
    super.initState();
    _initReservations();
  }

  void _initReservations() {
    final auth = context.read<AuthProvider>();
    final uid = auth.uid;
    if (uid != null) {
      context.read<ReservationProvider>().init(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Mis Reservas'),
      ),
      body: SafeArea(
        child: Consumer2<AuthProvider, ReservationProvider>(
          builder: (context, auth, provider, _) {
            if (auth.uid != null && provider.userId == null) {
              provider.init(auth.uid!);
            }
            if (provider.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.reservations.isEmpty) {
              return const Center(
                child: Text(
                  'No tienes reservas',
                  style: TextStyle(fontSize: 16, color: AppColors.accent),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: provider.reservations.length,
              itemBuilder: (context, index) {
                final reservation = provider.reservations[index];
                return _ReservationCard(reservation: reservation);
              },
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final ReservationModel reservation;
  const _ReservationCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                reservation.tourTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Text(
                reservation.status.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: reservation.status == ReservationStatus.confirmed
                      ? AppColors.accent
                      : reservation.status == ReservationStatus.cancelled
                          ? Colors.red
                          : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reservation.destinationName,
            style: const TextStyle(fontSize: 14, color: AppColors.accent),
          ),
          const SizedBox(height: 4),
          Text(
            '${reservation.participants} persona(s) · ${dateFormat.format(reservation.travelDate)}',
            style: const TextStyle(fontSize: 14, color: AppColors.accent),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${reservation.totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
