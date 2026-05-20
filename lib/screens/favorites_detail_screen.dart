import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/models/models.dart';
import 'package:lifetours/providers/providers.dart';
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Favoritos'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.favorite, color: AppColors.accent),
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
              return const Center(
                child: Text(
                  'No tienes favoritos',
                  style: TextStyle(fontSize: 16, color: AppColors.accent),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: provider.favorites.length,
              itemBuilder: (context, index) {
                final fav = provider.favorites[index];
                return _FavoriteCard(favorite: fav);
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
  const _FavoriteCard({required this.favorite});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
                  favorite.tourTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  favorite.destinationName,
                  style: const TextStyle(fontSize: 14, color: AppColors.accent),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${favorite.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.favorite, color: AppColors.accent),
        ],
      ),
    );
  }
}
