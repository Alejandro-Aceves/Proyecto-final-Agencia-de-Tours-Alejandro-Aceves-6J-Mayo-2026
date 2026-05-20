import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/providers/providers.dart';
import 'package:lifetours/widgets/bottom_nav_bar.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                '¿Estas Aburrido?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Encuentra esto y mas',
                style: TextStyle(fontSize: 16, color: AppColors.accent),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _CategoryCard(label: 'Cultura', index: 0),
                    _CategoryCard(label: 'Agua', index: 1),
                    _CategoryCard(label: 'Al aire libre', index: 2),
                    _CategoryCard(label: 'Comida', index: 3),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Comprueba nuestra variedad de actividades',
                style: TextStyle(fontSize: 14, color: AppColors.accent),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => context.go('/catalog'),
                  child: const Text('Ver mas', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 40),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Destinos',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Consumer<DestinationProvider>(
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
                  if (provider.destinations.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'No hay destinos disponibles',
                        style: TextStyle(color: AppColors.accent),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: provider.destinations.map((dest) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () => context.push('/destination-detail',
                                extra: dest.id),
                            child: Container(
                              height: 180,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.bottomLeft,
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    dest.name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.background,
                                    ),
                                  ),
                                  Text(
                                    '${dest.city}, ${dest.country}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.background,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String label;
  final int index;

  const _CategoryCard({required this.label, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/catalog'),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
