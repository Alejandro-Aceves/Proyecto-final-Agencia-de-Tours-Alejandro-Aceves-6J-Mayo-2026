import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/providers/providers.dart';
import 'package:lifetours/widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Padding(
                padding: EdgeInsets.only(left: 24),
                child: Text(
                  'Cuenta',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
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
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                auth.userModel!.name.isNotEmpty
                                    ? auth.userModel!.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: AppColors.background,
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
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  Text(
                                    auth.userModel!.email,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.accent,
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
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Inicia sesión para ver tu perfil',
                      style: TextStyle(fontSize: 16, color: AppColors.accent),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _MenuTile(
                icon: Icons.confirmation_number_outlined,
                title: 'Reservaciones',
                onTap: () => context.push('/my-reservations'),
              ),
              const Divider(indent: 24, endIndent: 24),
              _MenuTile(
                icon: Icons.person_outline,
                title: 'Perfil',
                onTap: () => context.push('/profile-detail'),
              ),
              const Divider(indent: 24, endIndent: 24),
              _MenuTile(
                icon: Icons.info_outline,
                title: 'Informacion',
                onTap: () => context.push('/info'),
              ),
              const Divider(indent: 24, endIndent: 24),
              _MenuTile(
                icon: Icons.favorite_border,
                title: 'Favoritos',
                onTap: () => context.push('/favorites-detail'),
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
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Accede al panel de administracion',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.background,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => context.push('/admin'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.background,
                                    foregroundColor: AppColors.primary,
                                  ),
                                  child: const Text(
                                    'Ver panel',
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
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.background,
                            ),
                            child: const Text('Cerrar Sesion',
                                style: TextStyle(fontSize: 16)),
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
      leading: Icon(icon, color: AppColors.primary),
      title:
          Text(title, style: const TextStyle(fontSize: 16, color: AppColors.primary)),
      trailing: Icon(Icons.chevron_right, color: AppColors.accent),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}
