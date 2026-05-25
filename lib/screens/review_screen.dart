import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/providers/providers.dart';
import 'package:lifetours/widgets/bottom_nav_bar.dart';
import 'package:lifetours/i18n/translations.dart';

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _MiniStatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaticReviewCard extends StatelessWidget {
  final String name;
  final String avatar;
  final int rating;
  final String date;
  final String text;
  const _StaticReviewCard({
    required this.name,
    required this.avatar,
    required this.rating,
    required this.date,
    required this.text,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: Text(
                  avatar,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: context.primary,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 11,
                        color: context.accent,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: AppColors.greenAccent,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: context.accent,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.primary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.primary,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.greenAccent,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Text(
                widget.answer,
                style: TextStyle(
                  fontSize: 13,
                  color: context.accent,
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  final String label;
  final double fraction;
  final int count;
  final int total;
  const _RatingBar({
    required this.label,
    required this.fraction,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 48,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: context.primary,
                ),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 12,
                  backgroundColor: AppColors.greenAccent.withAlpha(50),
                  valueColor: const AlwaysStoppedAnimation(AppColors.greenAccent),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 44,
              child: Text(
                '$count/$total',
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 12,
                  color: context.accent,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ReviewScreen extends StatefulWidget {
  final String? tourId;
  const ReviewScreen({super.key, this.tourId});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _commentController = TextEditingController();
  int _rating = 5;
  bool _showForm = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() {
    final lang = context.read<SettingsProvider>().locale.languageCode;
    final auth = context.read<AuthProvider>();
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTranslations.t('Escribe un comentario', lang))),
      );
      return;
    }
    if (auth.userModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTranslations.t('Debes iniciar sesión', lang))),
      );
      return;
    }
    context.read<ReviewProvider>().addReview(
          userId: auth.userModel!.uid,
          userName: auth.userModel!.name,
          userPhotoUrl: auth.userModel!.photoUrl,
          tourId: widget.tourId ?? '',
          tourTitle: 'Experiencia',
          rating: _rating,
          comment: comment,
        );
    _commentController.clear();
    setState(() => _showForm = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTranslations.t('Opinión publicada', lang))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().locale.languageCode;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppTranslations.t('Escribir opinion', lang),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: context.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_showForm)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTranslations.t('Calificación', lang),
                        style: TextStyle(fontSize: 16, color: context.primary),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (i) {
                          final star = i + 1;
                          return IconButton(
                            icon: Icon(
                              star <= _rating ? Icons.star : Icons.star_border,
                              color: AppColors.greenAccent,
                              size: 32,
                            ),
                            onPressed: () => setState(() => _rating = star),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _commentController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: AppTranslations.t('Tu opinión', lang),
                          hintText: AppTranslations.t('Comparte tu experiencia...', lang),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitReview,
                          child: Text(AppTranslations.t('Publicar', lang), style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _showForm = true),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(AppTranslations.t('Escribir una opinion', lang)),
                    ),
                  ),
                ),
              const SizedBox(height: 40),
              Consumer<ReviewProvider>(
                builder: (context, provider, _) {
                  if (provider.loading) {
                    return const CircularProgressIndicator();
                  }
                  if (provider.reviews.isEmpty) {
                    return Column(
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 80, color: AppColors.greenAccent),
                        const SizedBox(height: 24),
                        Text(
                          AppTranslations.t('Comentanos', lang),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: context.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            AppTranslations.t('Queremos que escribas una opinion sobre nosotros', lang),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: context.accent, height: 1.5),
                          ),
                        ),
                      ],
                    );
                  }

                  final totalReviews = provider.reviews.length;
                  final avgRating = totalReviews > 0
                      ? provider.reviews.map((r) => r.rating).reduce((a, b) => a + b) / totalReviews
                      : 0.0;
                  final highRated = provider.reviews.where((r) => r.rating >= 4).length;

                  return Column(
                    children: [
                      // ── Rating summary ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(color: context.primary),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              // Average number + stars
                              Column(
                                children: [
                                  Text(
                                    avgRating.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: context.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: List.generate(5, (i) {
                                      final filled = i < avgRating.round();
                                      return Icon(
                                        filled ? Icons.star : Icons.star_border,
                                        size: 18,
                                        color: AppColors.greenAccent,
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${AppTranslations.t('Calificación', lang)} · $totalReviews ${totalReviews == 1 ? 'opinión' : 'opiniones'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.accent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 28),
                              // Bar chart
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _RatingBar(
                                      label: '4-5 ★',
                                      fraction: totalReviews > 0 ? highRated / totalReviews : 0,
                                      count: highRated,
                                      total: totalReviews,
                                    ),
                                    const SizedBox(height: 10),
                                    _RatingBar(
                                      label: 'Total',
                                      fraction: 1.0,
                                      count: totalReviews,
                                      total: totalReviews,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // ── Review list ──
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: provider.reviews.length,
                        itemBuilder: (context, index) {
                          final review = provider.reviews[index];
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: context.primary),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        review.userName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: context.primary,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: List.generate(5, (i) {
                                        return Icon(
                                          i < review.rating ? Icons.star : Icons.star_border,
                                          size: 16,
                                          color: AppColors.greenAccent,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  review.comment,
                                  style: TextStyle(fontSize: 14, color: context.accent),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  review.tourTitle,
                                  style: TextStyle(fontSize: 12, color: context.accent),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // ── Estadísticas de reseñas ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reseñas destacadas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: context.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniStatCard(
                            icon: Icons.star_half,
                            value: '4.8',
                            label: 'Promedio',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MiniStatCard(
                            icon: Icons.rate_review_outlined,
                            value: '2.3K',
                            label: 'Reseñas',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MiniStatCard(
                            icon: Icons.thumb_up_alt_outlined,
                            value: '98%',
                            label: 'Recomiendan',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Reseñas de ejemplo (estáticas) ──
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  'Opiniones recientes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _StaticReviewCard(
                      name: 'María Fernanda',
                      avatar: 'M',
                      rating: 5,
                      date: '12 may 2026',
                      text: 'El tour por Barcelona fue sencillamente espectacular. La guía conocía cada rincón y nos llevó a lugares que nunca hubiera encontrado por mi cuenta. Recomendadísimo.',
                    ),
                    const SizedBox(height: 12),
                    _StaticReviewCard(
                      name: 'Pedro Infante',
                      avatar: 'P',
                      rating: 4,
                      date: '8 may 2026',
                      text: 'Muy buena experiencia. El hotel era cómodo y las actividades estaban bien organizadas. Solo faltó un poco más de tiempo libre para explorar por nuestra cuenta.',
                    ),
                    const SizedBox(height: 12),
                    _StaticReviewCard(
                      name: 'Lucía Ramírez',
                      avatar: 'L',
                      rating: 5,
                      date: '2 may 2026',
                      text: 'Viajé con mi familia y fue maravilloso. Los niños disfrutaron muchísimo las actividades. Todo el equipo fue muy atento y profesional. Sin duda repetiremos.',
                    ),
                    const SizedBox(height: 12),
                    _StaticReviewCard(
                      name: 'Jorge Castillo',
                      avatar: 'J',
                      rating: 5,
                      date: '28 abr 2026',
                      text: 'Increíble relación calidad-precio. Cada detalle estaba cuidado al máximo. La comida, el transporte, las excursiones… todo perfecto. Gracias por unas vacaciones inolvidables.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Preguntas frecuentes ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preguntas frecuentes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: context.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FaqTile(
                      question: '¿Cómo puedo dejar una reseña?',
                      answer: 'Haz clic en el botón "Escribir una opinión", selecciona tu calificación con estrellas, escribe tu comentario y pulsa "Publicar".',
                    ),
                    const SizedBox(height: 8),
                    _FaqTile(
                      question: '¿Puedo editar mi reseña después de publicarla?',
                      answer: 'Por el momento no es posible editar reseñas. Puedes eliminar la existente y escribir una nueva si lo deseas.',
                    ),
                    const SizedBox(height: 8),
                    _FaqTile(
                      question: '¿Mis reseñas son visibles para todos?',
                      answer: 'Sí, todas las reseñas publicadas son visibles para los demás usuarios y ayudan a la comunidad a elegir mejores experiencias.',
                    ),
                    const SizedBox(height: 8),
                    _FaqTile(
                      question: '¿Puedo reseñar un tour que no he tomado?',
                      answer: 'Solo puedes reseñar tours que hayas reservado y completado. Esto garantiza que las opiniones sean auténticas y útiles.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }
}
