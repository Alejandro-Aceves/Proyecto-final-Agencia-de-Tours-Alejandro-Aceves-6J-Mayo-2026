import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/providers/providers.dart';
import 'package:lifetours/widgets/bottom_nav_bar.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isAdmin) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Acceso restringido',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Bienvenido administrador',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Tablas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _TableRow(
                      label: 'Usuarios',
                      onTap: () => context.push('/admin/users', extra: 'users'),
                    ),
                    const Divider(),
                    _TableRow(
                      label: 'Destinos',
                      onTap: () => context.push('/admin/users', extra: 'destinations'),
                    ),
                    const Divider(),
                    _TableRow(
                      label: 'Tours',
                      onTap: () => context.push('/admin/users', extra: 'tours'),
                    ),
                    const Divider(),
                    _TableRow(
                      label: 'Reservas',
                      onTap: () => context.push('/admin/users', extra: 'reservations'),
                    ),
                    const Divider(),
                    _TableRow(
                      label: 'Resenas',
                      onTap: () => context.push('/admin/users', extra: 'reviews'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
        );
      },
    );
  }
}

class _TableRow extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _TableRow({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: AppColors.primary),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: const Text('Ver'),
          ),
        ],
      ),
    );
  }
}
