import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/models/models.dart';
import 'package:lifetours/providers/providers.dart';
import 'package:lifetours/i18n/translations.dart';
import 'package:lifetours/widgets/bottom_nav_bar.dart';

class FavoritesDetailScreen extends StatefulWidget {
  const FavoritesDetailScreen({super.key});

  @override
  State<FavoritesDetailScreen> createState() => _FavoritesDetailScreenState();
}

class _FavoritesDetailScreenState extends State<FavoritesDetailScreen> {
  @override
  void initState() {
    super.initState();
    _initFavorites();
  }

  void _initFavorites() {
    final auth = context.read<AuthProvider>();
    final uid = auth.uid;
    if (uid != null) {
      context.read<FavoriteProvider>().init(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().locale.languageCode;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(AppTranslations.t('Favoritos', lang)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.favorite, color: AppColors.greenAccent),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer2<AuthProvider, FavoriteProvider>(
          builder: (context, auth, provider, _) {
            if (auth.uid != null && provider.userId == null) {
              provider.init(auth.uid!);
            }
            if (provider.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.favorites.isEmpty) {
              return Center(
                child: Text(
                  AppTranslations.t('No tienes favoritos', lang),
                  style: TextStyle(fontSize: 16, color: context.accent),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: provider.favorites.length,
              itemBuilder: (context, index) {
                final fav = provider.favorites[index];
                return _FavoriteCard(
                  favorite: fav,
                  onRemove: () => provider.toggleFavorite(
                    tourId: fav.tourId,
                    tourTitle: fav.tourTitle,
                    tourImageUrl: fav.tourImageUrl,
                    destinationName: fav.destinationName,
                    price: fav.price,
                  ),
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

class _FavoriteCard extends StatelessWidget {
  final FavoriteModel favorite;
  final VoidCallback? onRemove;
  const _FavoriteCard({required this.favorite, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
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
              imageUrl: favorite.tourImageUrl,
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
                  favorite.tourTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  favorite.destinationName,
                  style: TextStyle(fontSize: 14, color: context.accent),
                ),
                const SizedBox(height: 4),
                Text(
                '\$${favorite.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greenAccent,
                ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
