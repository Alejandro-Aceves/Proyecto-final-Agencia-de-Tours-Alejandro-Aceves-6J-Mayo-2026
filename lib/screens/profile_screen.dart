import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/providers/providers.dart';
import 'package:lifetours/i18n/translations.dart';
import 'package:lifetours/widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  t('Cuenta'),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: context.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  if (auth.isAuthenticated && auth.userModel != null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: context.primary),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: context.primary,
                              child: Text(
                                auth.userModel!.name.isNotEmpty
                                    ? auth.userModel!.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    auth.userModel!.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: context.primary,
                                    ),
                                  ),
                                  Text(
                                    auth.userModel!.email,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: context.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      t('Inicia sesión para ver tu perfil'),
                      style: TextStyle(fontSize: 16, color: context.accent),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _MenuTile(
                icon: Icons.confirmation_number_outlined,
                title: t('Reservaciones'),
                onTap: () => context.push('/my-reservations'),
              ),
              const Divider(indent: 24, endIndent: 24),
              _MenuTile(
                icon: Icons.person_outline,
                title: t('Perfil'),
                onTap: () => context.push('/profile-detail'),
              ),
              const Divider(indent: 24, endIndent: 24),
               _MenuTile(
                icon: Icons.shopping_cart_outlined,
                title: t('Carrito'),
                onTap: () => context.push('/cart'),
              ),
              const Divider(indent: 24, endIndent: 24),
               _MenuTile(
                icon: Icons.info_outline,
                title: t('Informacion'),
                onTap: () => context.push('/info'),
              ),
              const Divider(indent: 24, endIndent: 24),
              _MenuTile(
                icon: Icons.favorite_border,
                title: t('Favoritos'),
                onTap: () => context.push('/favorites-detail'),
              ),
              const Divider(indent: 24, endIndent: 24),
              _MenuTile(
                icon: Icons.settings_outlined,
                title: t('Configuración'),
                onTap: () => context.push('/settings'),
              ),
              const SizedBox(height: 32),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  if (!auth.isAuthenticated) return const SizedBox.shrink();
                  return Column(
                    children: [
                      if (auth.isAdmin)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: context.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  t('Accede al panel de administracion'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => context.push('/admin'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: context.surface,
                                    foregroundColor: context.primary,
                                  ),
                                  child: Text(
                                    t('Ver panel'),
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Center(
                        child: SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () => auth.signOut(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(t('Cerrar Sesion'),
                                style: const TextStyle(fontSize: 16)),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _MenuTile({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: context.primary),
      title:
          Text(title, style: TextStyle(fontSize: 16, color: context.primary)),
      trailing: Icon(Icons.chevron_right, color: AppColors.greenAccent),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}
