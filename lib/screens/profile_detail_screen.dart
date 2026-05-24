import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/providers/providers.dart';
import 'package:lifetours/i18n/translations.dart';

class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().locale.languageCode;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(AppTranslations.t('Perfil', lang)),
      ),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            final user = auth.userModel;
            if (user == null) {
              return Center(child: Text(AppTranslations.t('Inicia sesión para ver tu perfil', lang)));
            }
            String memberSince;
            try {
              memberSince = DateFormat('MMMM yyyy', 'es').format(user.createdAt);
            } catch (_) {
              memberSince = '${user.createdAt.month}/${user.createdAt.year}';
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    AppTranslations.t('Mi Perfil', lang),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: context.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: context.primary,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _InfoRow(label: AppTranslations.t('Nombre', lang), value: user.name),
                  const Divider(),
                  _InfoRow(label: AppTranslations.t('Correo', lang), value: user.email),
                  const Divider(),
                  _InfoRow(label: AppTranslations.t('Telefono', lang), value: user.phone ?? AppTranslations.t('No registrado', lang)),
                  const Divider(),
                  _InfoRow(label: AppTranslations.t('Miembro desde', lang), value: memberSince),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 15, color: context.accent),
          ),
          Text(
            value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: context.primary,
            ),
          ),
        ],
      ),
    );
  }
}
