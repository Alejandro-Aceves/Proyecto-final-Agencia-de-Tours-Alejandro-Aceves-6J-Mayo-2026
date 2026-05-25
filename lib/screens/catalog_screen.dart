import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/models/models.dart';
import 'package:lifetours/providers/providers.dart';
import 'package:lifetours/i18n/translations.dart';
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
  int? _randomTourIndex;

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
    final lang = context.watch<SettingsProvider>().locale.languageCode;
    final t = (String key) => AppTranslations.t(key, lang);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  t('Tours'),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: context.primary,
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
                    Text(
                      t('Reserva cosas que hacer\naprobadas por nosotros'),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: t('Busca por destino'),
                        prefixIcon:
                            const Icon(Icons.search, color: AppColors.greenAccent),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    color: AppColors.greenAccent),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        fillColor: context.surface,
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
                            Text(
                              t('Filtrar por precio'),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: context.primary,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '\$${_priceRange.start.toStringAsFixed(0)} - \$${_priceRange.end.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.greenAccent,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    _isGridMode ? Icons.view_carousel : Icons.grid_view,
                                    size: 20,
                                    color: AppColors.greenAccent,
                                  ),
                                  onPressed: () {
                                    setState(() => _isGridMode = !_isGridMode);
                                  },
                                  tooltip: _isGridMode ? t('Vista carrusel') : t('Vista cuadrícula'),
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
                          activeColor: AppColors.greenAccent,
                          inactiveColor: AppColors.greenAccent.withAlpha(60),
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
              Consumer<TourProvider>(
                builder: (context, provider, _) {
                  if (provider.tours.isEmpty) return const SizedBox.shrink();
                  if (_randomTourIndex == null ||
                      _randomTourIndex! >= provider.tours.length) {
                    _randomTourIndex = DateTime.now().microsecondsSinceEpoch % provider.tours.length;
                  }
                  final tour = provider.tours[_randomTourIndex!];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 28),
                        Text(
                          t('Recomendado para ti'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: context.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => context.push('/booking', extra: tour.id),
                          child: Container(
                            height: 260,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: NetworkImage(tour.imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                            alignment: Alignment.bottomLeft,
                            padding: const EdgeInsets.all(20),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: context.primary.withAlpha(200),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    tour.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${tour.destinationName} — \$${tour.price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(context).colorScheme.onPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  t('Podria interesarte'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.primary,
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
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        t('No hay tours disponibles'),
                        style: TextStyle(color: context.accent),
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
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  t('Destinos'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.primary,
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
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        t('No hay destinos disponibles'),
                        style: TextStyle(color: context.accent),
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

              // ── Why choose us ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Por qué viajar con nosotros?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: context.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.flight_takeoff,
                              value: '150+',
                              label: 'Destinos',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.people,
                              value: '12K',
                              label: 'Viajeros',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.star,
                              value: '4.8',
                              label: 'Calificación',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Testimonios ──
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  'Lo que dicen nuestros viajeros',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _TestimonialCard(
                      name: 'Sofía G.',
                      avatar: 'S',
                      text: 'Una experiencia increíble. Todo estaba perfectamente organizado.',
                    ),
                    const SizedBox(width: 16),
                    _TestimonialCard(
                      name: 'Carlos M.',
                      avatar: 'C',
                      text: 'Los tours superaron mis expectativas. Volveré a reservar.',
                    ),
                    const SizedBox(width: 16),
                    _TestimonialCard(
                      name: 'Ana L.',
                      avatar: 'A',
                      text: 'La mejor agencia de viajes con la que he trabajado. 100% recomendada.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Tips de viaje ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tips para tu próximo viaje',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: context.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _TipRow(
                      icon: Icons.wb_sunny_outlined,
                      text: 'Mejor época para viajar: primavera y otoño.',
                    ),
                    const SizedBox(height: 12),
                    _TipRow(
                      icon: Icons.luggage_outlined,
                      text: 'Ligero de equipaje: lleva solo lo esencial.',
                    ),
                    const SizedBox(height: 12),
                    _TipRow(
                      icon: Icons.language_outlined,
                      text: 'Aprende frases básicas del idioma local.',
                    ),
                    const SizedBox(height: 12),
                    _TipRow(
                      icon: Icons.camera_alt_outlined,
                      text: 'No olvides tu cámara para capturar los momentos.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
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
          border: Border.all(color: context.primary),
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
                    color: AppColors.greenAccent.withAlpha(60),
                    child: Center(
                      child: Icon(Icons.image_outlined, size: 48, color: AppColors.greenAccent),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 130,
                    color: AppColors.greenAccent.withAlpha(60),
                    child: Center(
                      child: Icon(Icons.image_outlined, size: 48, color: AppColors.greenAccent),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${destination.city}, ${destination.country}',
                      style: TextStyle(fontSize: 13, color: context.accent),
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String name;
  final String avatar;
  final String text;
  const _TestimonialCard({
    required this.name,
    required this.avatar,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: context.primary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: Text(
                  avatar,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: context.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: context.accent,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TipRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.greenAccent, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: context.accent,
            ),
          ),
        ),
      ],
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
      child: grid ? _buildGrid(context) : _buildCarousel(context),
    );
  }

  Widget _buildCarousel(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: context.primary),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(100),
              const SizedBox(height: 12),
              _buildTitle(context),
              const SizedBox(height: 4),
              _buildDestination(context),
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

  Widget _buildGrid(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: context.surface,
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
                _buildTitle(context),
                const SizedBox(height: 2),
                _buildDestination(context),
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
          color: AppColors.greenAccent.withAlpha(60),
          child: Center(
            child: Icon(Icons.image_outlined, size: 48, color: AppColors.greenAccent),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          height: height,
          color: AppColors.greenAccent.withAlpha(60),
          child: Center(
            child: Icon(Icons.image_outlined, size: 48, color: AppColors.greenAccent),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      tour.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: context.primary,
      ),
    );
  }

  Widget _buildDestination(BuildContext context) {
    return Text(
      tour.destinationName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 12, color: context.accent),
    );
  }

  Widget _buildPrice() {
    return Text(
      '\$${tour.price.toStringAsFixed(2)}',
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.greenAccent,
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
                  border: Border.all(color: AppColors.greenAccent),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  c.label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.greenAccent),
                ),
              ))
          .toList(),
    );
  }
}
