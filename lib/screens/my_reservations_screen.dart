import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/models/models.dart';
import 'package:lifetours/providers/providers.dart';
import 'package:lifetours/i18n/translations.dart';
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

  Map<String, List<ReservationModel>> _groupByDate(List<ReservationModel> reservations, String lang) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastWeek = today.subtract(const Duration(days: 7));
    final lastMonth = today.subtract(const Duration(days: 30));

    final upcoming = AppTranslations.t('Próximos', lang);
    final todayLabel = AppTranslations.t('Hoy', lang);
    final yesterdayLabel = AppTranslations.t('Ayer', lang);
    final lastWeekLabel = AppTranslations.t('Última semana', lang);
    final lastMonthLabel = AppTranslations.t('Último mes', lang);
    final olderLabel = AppTranslations.t('Más antiguo', lang);

    final groups = <String, List<ReservationModel>>{
      upcoming: [],
      todayLabel: [],
      yesterdayLabel: [],
      lastWeekLabel: [],
      lastMonthLabel: [],
      olderLabel: [],
    };

    for (final r in reservations) {
      final date = DateTime(r.travelDate.year, r.travelDate.month, r.travelDate.day);
      if (date.isAfter(today)) {
        groups[upcoming]!.add(r);
      } else if (date == today) {
        groups[todayLabel]!.add(r);
      } else if (date == yesterday) {
        groups[yesterdayLabel]!.add(r);
      } else if (date.isAfter(lastWeek)) {
        groups[lastWeekLabel]!.add(r);
      } else if (date.isAfter(lastMonth)) {
        groups[lastMonthLabel]!.add(r);
      } else {
        groups[olderLabel]!.add(r);
      }
    }

    groups.removeWhere((_, list) => list.isEmpty);
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().locale.languageCode;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
        title: Text(AppTranslations.t('Mis Reservas', lang)),
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
            if (provider.error != null) {
              return Center(
                child: Text(
                  provider.error!,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              );
            }
            if (provider.reservations.isEmpty) {
              return Center(
                child: Text(
                  AppTranslations.t('No tienes reservas', lang),
                  style: TextStyle(fontSize: 16, color: context.accent),
                ),
              );
            }

            final groups = _groupByDate(provider.reservations, lang);
            final labels = groups.keys.toList();

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: labels.length,
              itemBuilder: (context, sectionIndex) {
                final label = labels[sectionIndex];
                final items = groups[label]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (sectionIndex > 0) const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: context.primary,
                        ),
                      ),
                    ),
                    ...items.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ReservationCard(reservation: r),
                    )),
                  ],
                );
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
    final lang = context.watch<SettingsProvider>().locale.languageCode;
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: context.primary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: reservation.tourImageUrl,
                  width: 72,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 72,
                    height: 72,
                    color: AppColors.greenAccent.withAlpha(60),
                    child: Icon(Icons.image_outlined, color: AppColors.greenAccent),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 72,
                    height: 72,
                    color: AppColors.greenAccent.withAlpha(60),
                    child: Icon(Icons.image_outlined, color: AppColors.greenAccent),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            reservation.tourTitle,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: context.primary,
                            ),
                          ),
                        ),
                        Text(
                          reservation.status.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: reservation.status == ReservationStatus.confirmed
                                ? AppColors.greenAccent
                                : reservation.status == ReservationStatus.cancelled
                                    ? Colors.red
                                    : context.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reservation.destinationName,
                      style: TextStyle(fontSize: 14, color: context.accent),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${reservation.participants} ${AppTranslations.t('persona(s)', lang)} · ${dateFormat.format(reservation.travelDate)}',
                      style: TextStyle(fontSize: 14, color: context.accent),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${reservation.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greenAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
