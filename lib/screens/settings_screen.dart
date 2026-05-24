import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/providers/providers.dart';
import 'package:lifetours/i18n/translations.dart';
import 'package:lifetours/widgets/bottom_nav_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = (String key) =>
        AppTranslations.t(key, context.watch<SettingsProvider>().locale.languageCode);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                t('settings'),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: context.primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 32),
              Consumer<SettingsProvider>(
                builder: (context, settings, _) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: context.primary),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text(
                            t('dark_mode'),
                            style: TextStyle(
                              fontSize: 16,
                              color: context.primary,
                            ),
                          ),
                          value: settings.isDarkMode,
                          onChanged: (_) => settings.toggleDarkMode(),
                          activeTrackColor: AppColors.greenAccent,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        SwitchListTile(
                          title: Text(
                            t('language'),
                            style: TextStyle(
                              fontSize: 16,
                              color: context.primary,
                            ),
                          ),
                          subtitle: Text(
                            settings.isEnglish ? t('english') : t('spanish'),
                            style: TextStyle(
                              fontSize: 13,
                              color: context.accent,
                            ),
                          ),
                          value: settings.isEnglish,
                          onChanged: (_) => settings.toggleLanguage(),
                          activeTrackColor: AppColors.greenAccent,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
    );
  }
}
