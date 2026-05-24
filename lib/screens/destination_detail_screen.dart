import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/models/models.dart';
import 'package:lifetours/services/services.dart';
import 'package:lifetours/providers/providers.dart';
import 'package:lifetours/widgets/bottom_nav_bar.dart';
import 'package:lifetours/i18n/translations.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fav = context.read<FavoriteProvider>();
      if (fav.userId == null) {
        final uid = context.read<AuthProvider>().uid;
        if (uid != null) fav.init(uid);
      }
    });
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
    final lang = context.watch<SettingsProvider>().locale.languageCode;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(Icons.favorite_border, color: Colors.white),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: _destination != null
                    ? CachedNetworkImage(
                        imageUrl: _destination!.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 240,
                        placeholder: (_, __) => Container(
                          color: context.primary,
                          child: Center(
                            child: Icon(Icons.image_outlined, size: 64, color: Colors.white),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: context.primary,
                          child: Center(
                            child: Icon(Icons.image_outlined, size: 64, color: Colors.white),
                          ),
                        ),
                      )
                    : Container(
                        color: context.primary,
                        child: Center(
                          child: Icon(Icons.image_outlined, size: 64, color: Colors.white),
                        ),
                      ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _loading
                ? const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _destination == null
                    ? Center(child: Text(AppTranslations.t('Destino no encontrado', lang)))
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            Text(
                              _destination!.name,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: context.primary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_destination!.city}, ${_destination!.country}',
                              style: TextStyle(fontSize: 16, color: context.accent),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              AppTranslations.t('Detalles', lang),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: context.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _destination!.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: context.accent,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              AppTranslations.t('Actividades', lang),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: context.primary,
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
                              Text(
                                AppTranslations.t('Tours disponibles', lang),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: context.primary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...List.generate(_tours.length, (i) {
                                final tour = _tours[i];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Consumer<FavoriteProvider>(
                                    builder: (context, favProv, _) {
                                      final isFav = favProv.isFavoriteLocally(tour.id);
                                      return _TourListItem(
                                        tour: tour,
                                        isFavorite: isFav,
                                        onTap: () => context.push('/booking', extra: tour.id),
                                        onToggleFavorite: () {
                                          final auth = context.read<AuthProvider>();
                                          if (auth.uid == null) return;
                                          if (favProv.userId == null) {
                                            favProv.init(auth.uid!);
                                          }
                                          favProv.toggleFavorite(
                                            tourId: tour.id,
                                            tourTitle: tour.title,
                                            tourImageUrl: tour.imageUrl,
                                            destinationName: tour.destinationName,
                                            price: tour.price,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                );
                              }),
                            ],
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
        ],
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
        border: Border.all(color: context.primary),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: context.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _TourListItem extends StatelessWidget {
  final TourModel tour;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onToggleFavorite;
  const _TourListItem({
    required this.tour,
    this.isFavorite = false,
    this.onTap,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().locale.languageCode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: context.primary),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: tour.imageUrl,
                width: 72,
                height: 72,
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
                  Text(
                    tour.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${tour.durationDays} ${AppTranslations.t('día(s)', lang)} · ${tour.availableSpots} ${AppTranslations.t('lugares', lang)}',
                    style: TextStyle(fontSize: 13, color: context.accent),
                  ),
                ],
              ),
            ),
            Text(
                '\$${tour.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greenAccent,
                ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : AppColors.greenAccent,
              ),
              onPressed: onToggleFavorite,
            ),
          ],
        ),
      ),
    );
  }
}
