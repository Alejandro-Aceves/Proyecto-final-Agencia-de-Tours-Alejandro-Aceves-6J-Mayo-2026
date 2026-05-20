import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/models/models.dart';
import 'package:lifetours/services/services.dart';
import 'package:lifetours/widgets/bottom_nav_bar.dart';

class DestinationDetailScreen extends StatefulWidget {
  final String? destinationId;

  const DestinationDetailScreen({super.key, this.destinationId});

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  DestinationModel? _destination;
  List<TourModel> _tours = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    if (widget.destinationId == null) return;
    final dest = await _firestoreService.getDestination(widget.destinationId!);
    final tours = await _firestoreService.getToursByDestination(widget.destinationId!);
    if (mounted) {
      setState(() {
        _destination = dest;
        _tours = tours;
        _loading = false;
      });
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.favorite_border, color: AppColors.primary),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _destination == null
                ? const Center(child: Text('Destino no encontrado'))
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            _destination!.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_destination!.city}, ${_destination!.country}',
                            style: const TextStyle(fontSize: 16, color: AppColors.accent),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            height: 180,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Icon(Icons.image_outlined, size: 64, color: AppColors.background),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Detalles',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _destination!.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.accent,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Actividades',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _destination!.activities
                                .map((a) => _ActivityChip(label: a))
                                .toList(),
                          ),
                          if (_tours.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            const Text(
                              'Tours disponibles',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...List.generate(_tours.length, (i) {
                              final tour = _tours[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _TourListItem(
                                  tour: tour,
                                  onTap: () => context.push('/booking', extra: tour.id),
                                ),
                              );
                            }),
                          ],
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
    );
  }
}

class _ActivityChip extends StatelessWidget {
  final String label;
  const _ActivityChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _TourListItem extends StatelessWidget {
  final TourModel tour;
  final VoidCallback? onTap;
  const _TourListItem({required this.tour, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tour.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${tour.durationDays} día(s) · ${tour.availableSpots} lugares',
                    style: const TextStyle(fontSize: 13, color: AppColors.accent),
                  ),
                ],
              ),
            ),
            Text(
              '\$${tour.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
