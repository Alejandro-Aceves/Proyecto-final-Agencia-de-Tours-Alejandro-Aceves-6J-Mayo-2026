import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/providers/providers.dart';
import 'package:lifetours/widgets/bottom_nav_bar.dart';
import 'package:lifetours/i18n/translations.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().locale.languageCode;
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isAdmin) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppTranslations.t('Acceso restringido', lang),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: context.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: Text(AppTranslations.t('Volver', lang)),
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
                    Text(
                      AppTranslations.t('Bienvenido administrador', lang),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: context.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      AppTranslations.t('Tablas', lang),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: context.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _TableRow(
                      label: 'Usuarios',
                      lang: lang,
                      onTap: () => context.push('/admin/users', extra: 'users'),
                    ),
                    const Divider(),
                    _TableRow(
                      label: 'Destinos',
                      lang: lang,
                      onTap: () => context.push('/admin/users', extra: 'destinations'),
                    ),
                    const Divider(),
                    _TableRow(
                      label: 'Tours',
                      lang: lang,
                      onTap: () => context.push('/admin/users', extra: 'tours'),
                    ),
                    const Divider(),
                    _TableRow(
                      label: 'Reservas',
                      lang: lang,
                      onTap: () => context.push('/admin/users', extra: 'reservations'),
                    ),
                    const Divider(),
                    _TableRow(
                      label: 'Resenas',
                      lang: lang,
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
  final String lang;
  final VoidCallback? onTap;

  const _TableRow({required this.label, required this.lang, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppTranslations.t(label, lang),
            style: TextStyle(fontSize: 16, color: context.primary),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: Text(AppTranslations.t('Ver', lang)),
          ),
        ],
      ),
    );
  }
}
