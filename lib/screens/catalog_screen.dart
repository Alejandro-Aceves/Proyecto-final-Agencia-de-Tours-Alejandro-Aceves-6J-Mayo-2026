import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/models/models.dart';
import 'package:lifetours/providers/providers.dart';
import 'package:lifetours/widgets/bottom_nav_bar.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  RangeValues _priceRange = const RangeValues(0, 5000);
  bool _isGridMode = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(String value) =>
      _searchQuery.isEmpty || value.toLowerCase().contains(_searchQuery);

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
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Busca por destino',
                        prefixIcon:
                            const Icon(Icons.search, color: AppColors.accent),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    color: AppColors.accent),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        fillColor: AppColors.background,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Consumer<TourProvider>(
                builder: (context, provider, _) {
                  if (provider.tours.isEmpty) return const SizedBox.shrink();
                  final maxPrice = provider.tours
                      .map((t) => t.price)
                      .reduce((a, b) => a > b ? a : b);
                  const minPrice = 0.0;
                  if (_priceRange.end > maxPrice) {
                    _priceRange = RangeValues(minPrice, maxPrice);
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Filtrar por precio',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '\$${_priceRange.start.toStringAsFixed(0)} - \$${_priceRange.end.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.accent,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    _isGridMode ? Icons.view_carousel : Icons.grid_view,
                                    size: 20,
                                    color: AppColors.accent,
                                  ),
                                  onPressed: () {
                                    setState(() => _isGridMode = !_isGridMode);
                                  },
                                  tooltip: _isGridMode ? 'Vista carrusel' : 'Vista cuadrícula',
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ],
                        ),
                        RangeSlider(
                          values: _priceRange,
                          min: minPrice,
                          max: maxPrice > 0 ? maxPrice : 1,
                          divisions: 50,
                          activeColor: AppColors.accent,
                          inactiveColor: AppColors.accent.withAlpha(60),
                          labels: RangeLabels(
                            '\$${_priceRange.start.toStringAsFixed(0)}',
                            '\$${_priceRange.end.toStringAsFixed(0)}',
                          ),
                          onChanged: (values) {
                            setState(() => _priceRange = values);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
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
                  final filteredTours = provider.tours.where((t) =>
                      (_matchesSearch(t.title) ||
                       _matchesSearch(t.destinationName)) &&
                      t.price >= _priceRange.start &&
                      t.price <= _priceRange.end).toList();
                  if (filteredTours.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'No hay tours disponibles',
                        style: TextStyle(color: AppColors.accent),
                      ),
                    );
                  }
                  if (_isGridMode) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.65,
                        children: filteredTours.map((tour) => _TourCard(
                          tour: tour,
                          onTap: () =>
                              context.push('/booking', extra: tour.id),
                          grid: true,
                        )).toList(),
                      ),
                    );
                  }
                  const int cardLimit = 7;
                  final chunks = <List<TourModel>>[];
                  for (int i = 0; i < filteredTours.length; i += cardLimit) {
                    chunks.add(filteredTours.sublist(i, i + cardLimit > filteredTours.length ? filteredTours.length : i + cardLimit));
                  }
                  return Column(
                    children: chunks.asMap().entries.map((entry) {
                      final chunk = entry.value;
                      return Padding(
                        padding: entry.key > 0
                            ? const EdgeInsets.only(top: 16)
                            : EdgeInsets.zero,
                        child: SizedBox(
                          height: 300,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            children: chunk.map((tour) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: _TourCard(
                                  tour: tour,
                                  onTap: () =>
                                      context.push('/booking', extra: tour.id),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.only(left: 24),
                child: Text(
                  'Destinos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                  final filteredDests = provider.destinations.where((d) =>
                      _matchesSearch(d.name) ||
                      _matchesSearch(d.city) ||
                      _matchesSearch(d.country)).toList();
                  if (filteredDests.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'No hay destinos disponibles',
                        style: TextStyle(color: AppColors.accent),
                      ),
                    );
                  }
                  const int cardLimit = 7;
                  final chunks = <List<DestinationModel>>[];
                  for (int i = 0; i < filteredDests.length; i += cardLimit) {
                    chunks.add(filteredDests.sublist(i, i + cardLimit > filteredDests.length ? filteredDests.length : i + cardLimit));
                  }
                  return Column(
                    children: chunks.asMap().entries.map((entry) {
                      final chunk = entry.value;
                      return Padding(
                        padding: entry.key > 0
                            ? const EdgeInsets.only(top: 16)
                            : EdgeInsets.zero,
                        child: SizedBox(
                          height: 220,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            children: chunk.map((dest) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: _DestinationCard(
                                  destination: dest,
                                  onTap: () => context.push('/destination-detail',
                                      extra: dest.id),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    }).toList(),
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

class _DestinationCard extends StatelessWidget {
  final DestinationModel destination;
  final VoidCallback? onTap;
  const _DestinationCard({required this.destination, this.onTap});

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(11),
                  topRight: Radius.circular(11),
                ),
                child: CachedNetworkImage(
                  imageUrl: destination.imageUrl,
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 130,
                    color: AppColors.accent.withAlpha(60),
                    child: Center(
                      child: Icon(Icons.image_outlined, size: 48, color: AppColors.accent),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 130,
                    color: AppColors.accent.withAlpha(60),
                    child: Center(
                      child: Icon(Icons.image_outlined, size: 48, color: AppColors.accent),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${destination.city}, ${destination.country}',
                      style: const TextStyle(fontSize: 13, color: AppColors.accent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TourCard extends StatelessWidget {
  final TourModel tour;
  final VoidCallback? onTap;
  final bool grid;

  const _TourCard({required this.tour, this.onTap, this.grid = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: grid ? _buildGrid() : _buildCarousel(),
    );
  }

  Widget _buildCarousel() {
    return SizedBox(
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
              _buildImage(100),
              const SizedBox(height: 12),
              _buildTitle(),
              const SizedBox(height: 4),
              _buildDestination(),
              const SizedBox(height: 4),
              _buildPrice(),
              const SizedBox(height: 8),
              _buildCategories(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.background,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(110),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(),
                const SizedBox(height: 2),
                _buildDestination(),
                const SizedBox(height: 2),
                _buildPrice(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: tour.imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          height: height,
          color: AppColors.accent.withAlpha(60),
          child: Center(
            child: Icon(Icons.image_outlined, size: 48, color: AppColors.accent),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          height: height,
          color: AppColors.accent.withAlpha(60),
          child: Center(
            child: Icon(Icons.image_outlined, size: 48, color: AppColors.accent),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      tour.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildDestination() {
    return Text(
      tour.destinationName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 12, color: AppColors.accent),
    );
  }

  Widget _buildPrice() {
    return Text(
      '\$${tour.price.toStringAsFixed(2)}',
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.accent,
      ),
    );
  }

  Widget _buildCategories() {
    return Wrap(
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
    );
  }
}
