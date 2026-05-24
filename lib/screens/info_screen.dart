import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/i18n/translations.dart';
import 'package:lifetours/providers/providers.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().locale.languageCode;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(AppTranslations.t('Informacion', lang)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                AppTranslations.t('Informacion', lang),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: context.primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: context.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTranslations.t('Sobre Life Tours', lang),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: context.primary,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      AppTranslations.t('Life Tours es una plataforma de reserva de viajes y experiencias diseñada para ayudarte a descubrir los mejores destinos alrededor del mundo.', lang),
                      style: TextStyle(fontSize: 14, color: context.accent, height: 1.6),
                    ),
                    SizedBox(height: 16),
                    Text(
                      AppTranslations.t('Version 1.0.0', lang),
                      style: TextStyle(fontSize: 13, color: context.accent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: context.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTranslations.t('Contacto', lang),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: context.primary,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      AppTranslations.t('Correo: soporte@lifetours.com', lang),
                      style: TextStyle(fontSize: 14, color: context.accent, height: 1.6),
                    ),
                    Text(
                      AppTranslations.t('Telefono: +52 55 9876 5432', lang),
                      style: TextStyle(fontSize: 14, color: context.accent, height: 1.6),
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
