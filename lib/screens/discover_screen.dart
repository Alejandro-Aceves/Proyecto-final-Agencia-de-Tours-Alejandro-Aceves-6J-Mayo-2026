import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/providers/providers.dart';
import 'package:lifetours/widgets/bottom_nav_bar.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                '¿Estas Aburrido?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Encuentra esto y mas',
                style: TextStyle(fontSize: 16, color: AppColors.accent),
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
                    _CategoryCard(label: 'Cultura', imageUrl: 'https://picsum.photos/seed/cultura/400/300'),
                    _CategoryCard(label: 'Agua', imageUrl: 'https://picsum.photos/seed/agua/400/300'),
                    _CategoryCard(label: 'Al aire libre', imageUrl: 'https://picsum.photos/seed/airelibre/400/300'),
                    _CategoryCard(label: 'Comida', imageUrl: 'https://picsum.photos/seed/comida/400/300'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Comprueba nuestra variedad de actividades',
                style: TextStyle(fontSize: 14, color: AppColors.accent),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => context.go('/catalog'),
                  child: const Text('Ver mas', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 40),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Destinos',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
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
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'No hay destinos disponibles',
                        style: TextStyle(color: AppColors.accent),
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
                                  color: AppColors.primary.withAlpha(180),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      dest.name,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.background,
                                      ),
                                    ),
                                    Text(
                                      '${dest.city}, ${dest.country}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.background,
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Por que elegirnos',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
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
                      title: 'Viajes verificados',
                      description:
                          'Todos nuestros tours son revisados y aprobados por nuestro equipo de expertos locales.',
                    ),
                    const SizedBox(height: 12),
                    _BenefitCard(
                      icon: Icons.support_agent,
                      title: 'Soporte 24/7',
                      description:
                          'Estamos disponibles en todo momento para ayudarte durante tu viaje.',
                    ),
                    const SizedBox(height: 12),
                    _BenefitCard(
                      icon: Icons.monetization_on,
                      title: 'Mejor precio garantizado',
                      description:
                          'Te ofrecemos los mejores precios del mercado con cancelacion flexible.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ── Testimonios ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                color: AppColors.primary.withAlpha(20),
                child: Column(
                  children: [
                    const Text(
                      'Testimonios',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _TestimonialCard(
                      name: 'Maria G.',
                      location: 'España',
                      text:
                          'Una experiencia inolvidable. El tour por Barcelona supero todas mis expectativas. Guias muy capacitados y atentos.',
                    ),
                    const SizedBox(height: 16),
                    _TestimonialCard(
                      name: 'Carlos R.',
                      location: 'Mexico',
                      text:
                          'Viaje a Paris con mi familia y todo estuvo perfectamente organizado. Sin duda repetire con LifeTours.',
                    ),
                    const SizedBox(height: 16),
                    _TestimonialCard(
                      name: 'Ana L.',
                      location: 'Argentina',
                      text:
                          'Los mejores destinos y precios. La atencion al cliente es excepcional, me ayudaron con cada detalle.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ── Consejos de viaje ──
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Consejos de viaje',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
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
                      title: 'Planifica con anticipacion',
                      description:
                          'Reserva tus tours con al menos dos semanas de anticipacion para asegurar disponibilidad y mejores precios.',
                    ),
                    const SizedBox(height: 12),
                    _TipCard(
                      number: '2',
                      title: 'Empaca ligero',
                      description:
                          'Lleva solo lo esencial. La mayoria de nuestros tours incluyen transporte y alimentacion.',
                    ),
                    const SizedBox(height: 12),
                    _TipCard(
                      number: '3',
                      title: 'Revisa el clima',
                      description:
                          'Consulta el pronostico del tiempo antes de tu viaje para elegir la mejor fecha y preparar tu equipaje.',
                    ),
                    const SizedBox(height: 12),
                    _TipCard(
                      number: '4',
                      title: 'Lee las opiniones',
                      description:
                          'Revisa los comentarios de otros viajeros para elegir el tour que mejor se adapte a ti.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ── Footer / Contacto ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                color: AppColors.primary,
                child: const Column(
                  children: [
                    Text(
                      'LifeTours',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.background,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tu puerta al mundo',
                      style: TextStyle(fontSize: 14, color: AppColors.background),
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email, color: AppColors.background, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'contacto@lifetours.com',
                          style: TextStyle(fontSize: 14, color: AppColors.background),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone, color: AppColors.background, size: 20),
                        SizedBox(width: 8),
                        Text(
                          '+52 55 1234 5678',
                          style: TextStyle(fontSize: 14, color: AppColors.background),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Text(
                      '© 2026 LifeTours. Todos los derechos reservados.',
                      style: TextStyle(fontSize: 12, color: AppColors.background),
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
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.accent,
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
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(30),
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
                backgroundColor: AppColors.primary.withAlpha(60),
                child: Text(
                  name[0],
                  style: const TextStyle(
                    color: AppColors.primary,
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    location,
                    style: const TextStyle(fontSize: 12, color: AppColors.accent),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"$text"',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.accent,
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
        border: Border.all(color: AppColors.accent.withAlpha(80)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                color: AppColors.background,
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
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.accent,
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
            color: AppColors.primary.withAlpha(100),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.background,
            ),
          ),
        ),
      ),
    );
  }
}
