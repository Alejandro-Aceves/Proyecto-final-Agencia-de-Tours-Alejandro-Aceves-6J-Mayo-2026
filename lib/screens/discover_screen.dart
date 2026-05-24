import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/providers/providers.dart';
import 'package:lifetours/i18n/translations.dart';
import 'package:lifetours/widgets/bottom_nav_bar.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().locale.languageCode;
    final t = (String key) => AppTranslations.t(key, lang);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                t('¿Estas Aburrido?'),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: context.primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                t('Encuentra esto y mas'),
                style: TextStyle(fontSize: 16, color: context.accent),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _CategoryCard(label: t('Cultura'), imageUrl: 'https://picsum.photos/seed/cultura/400/300'),
                    _CategoryCard(label: t('Agua'), imageUrl: 'https://picsum.photos/seed/agua/400/300'),
                    _CategoryCard(label: t('Al aire libre'), imageUrl: 'https://picsum.photos/seed/airelibre/400/300'),
                    _CategoryCard(label: t('Comida'), imageUrl: 'https://picsum.photos/seed/comida/400/300'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                t('Comprueba nuestra variedad de actividades'),
                style: TextStyle(fontSize: 14, color: context.accent),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => context.go('/catalog'),
                  child: Text(t('Ver mas'), style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    t('Destinos'),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: context.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
                  if (provider.destinations.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        t('No hay destinos disponibles'),
                        style: TextStyle(color: context.accent),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: provider.destinations.map((dest) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () => context.push('/destination-detail',
                                extra: dest.id),
                            child: Container(
                              height: 180,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(dest.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              alignment: Alignment.bottomLeft,
                              padding: const EdgeInsets.all(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: context.primary.withAlpha(180),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      dest.name,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).colorScheme.onPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${dest.city}, ${dest.country}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).colorScheme.onPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // ── Por qué elegirnos ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    t('Por que elegirnos'),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: context.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _BenefitCard(
                      icon: Icons.verified,
                      title: t('Viajes verificados'),
                      description: t('Todos nuestros tours son revisados y aprobados por nuestro equipo de expertos locales.'),
                    ),
                    const SizedBox(height: 12),
                    _BenefitCard(
                      icon: Icons.support_agent,
                      title: t('Soporte 24/7'),
                      description: t('Estamos disponibles en todo momento para ayudarte durante tu viaje.'),
                    ),
                    const SizedBox(height: 12),
                    _BenefitCard(
                      icon: Icons.monetization_on,
                      title: t('Mejor precio garantizado'),
                      description: t('Te ofrecemos los mejores precios del mercado con cancelacion flexible.'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ── Testimonios ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                color: context.primary.withAlpha(20),
                child: Column(
                  children: [
                    Text(
                      t('Testimonios'),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: context.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _TestimonialCard(
                      name: t('Maria G.'),
                      location: t('España'),
                      text: t('Una experiencia inolvidable. El tour por Barcelona supero todas mis expectativas. Guias muy capacitados y atentos.'),
                    ),
                    const SizedBox(height: 16),
                    _TestimonialCard(
                      name: t('Carlos R.'),
                      location: t('Mexico'),
                      text: t('Viaje a Paris con mi familia y todo estuvo perfectamente organizado. Sin duda repetire con LifeTours.'),
                    ),
                    const SizedBox(height: 16),
                    _TestimonialCard(
                      name: t('Ana L.'),
                      location: t('Argentina'),
                      text: t('Los mejores destinos y precios. La atencion al cliente es excepcional, me ayudaron con cada detalle.'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ── Consejos de viaje ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    t('Consejos de viaje'),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: context.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _TipCard(
                      number: '1',
                      title: t('Planifica con anticipacion'),
                      description: t('Reserva tus tours con al menos dos semanas de anticipacion para asegurar disponibilidad y mejores precios.'),
                    ),
                    const SizedBox(height: 12),
                    _TipCard(
                      number: '2',
                      title: t('Empaca ligero'),
                      description: t('Lleva solo lo esencial. La mayoria de nuestros tours incluyen transporte y alimentacion.'),
                    ),
                    const SizedBox(height: 12),
                    _TipCard(
                      number: '3',
                      title: t('Revisa el clima'),
                      description: t('Consulta el pronostico del tiempo antes de tu viaje para elegir la mejor fecha y preparar tu equipaje.'),
                    ),
                    const SizedBox(height: 12),
                    _TipCard(
                      number: '4',
                      title: t('Lee las opiniones'),
                      description: t('Revisa los comentarios de otros viajeros para elegir el tour que mejor se adapte a ti.'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ── Footer / Contacto ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                color: context.primary,
                child: Column(
                  children: [
                    Text(
                      t('LifeTours'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t('Tu puerta al mundo'),
                      style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email, color: Theme.of(context).colorScheme.onPrimary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          t('contacto@lifetours.com'),
                          style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone, color: Theme.of(context).colorScheme.onPrimary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          t('+52 55 1234 5678'),
                          style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      t('© 2026 LifeTours. Todos los derechos reservados.'),
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: context.primary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: context.primary, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.accent,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String name;
  final String location;
  final String text;
  const _TestimonialCard({
    required this.name,
    required this.location,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.primary.withAlpha(30),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: context.primary.withAlpha(60),
                child: Text(
                  name[0],
                  style: TextStyle(
                    color: context.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.primary,
                    ),
                  ),
                  Text(
                    location,
                    style: TextStyle(fontSize: 12, color: context.accent),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"$text"',
            style: TextStyle(
              fontSize: 14,
              color: context.accent,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  const _TipCard({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greenAccent.withAlpha(80)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.accent,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String label;
  final String imageUrl;

  const _CategoryCard({required this.label, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/catalog'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        alignment: Alignment.center,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: context.primary.withAlpha(100),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
