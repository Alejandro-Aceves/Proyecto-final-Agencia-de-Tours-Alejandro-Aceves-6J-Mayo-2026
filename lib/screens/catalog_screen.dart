import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/models/models.dart';
import 'package:lifetours/providers/providers.dart';
import 'package:lifetours/widgets/bottom_nav_bar.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.only(left: 24),
                child: Text(
                  'Tours',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reserva cosas que hacer\naprobadas por nosotros',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.background,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Busca por destino',
                        prefixIcon:
                            const Icon(Icons.search, color: AppColors.accent),
                        fillColor: AppColors.background,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.only(left: 24),
                child: Text(
                  'Podria interesarte',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Consumer<TourProvider>(
                builder: (context, provider, _) {
                  if (provider.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.error != null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        provider.error!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    );
                  }
                  if (provider.tours.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'No hay tours disponibles',
                        style: TextStyle(color: AppColors.accent),
                      ),
                    );
                  }
                  return SizedBox(
                    height: 220,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: provider.tours.map((tour) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: _TourCard(
                            tour: tour,
                            onTap: () => context.push('/destination-detail',
                                extra: tour.destinationId),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
    );
  }
}

class _TourCard extends StatelessWidget {
  final TourModel tour;
  final VoidCallback? onTap;

  const _TourCard({required this.tour, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 220,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(
                    child:
                        Icon(Icons.image_outlined, size: 48, color: AppColors.accent),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  tour.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tour.destinationName,
                  style: const TextStyle(fontSize: 13, color: AppColors.accent),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${tour.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: tour.categories
                      .map((c) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.accent),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              c.label,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.accent),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
