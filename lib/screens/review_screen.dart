import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/providers/providers.dart';
import 'package:lifetours/widgets/bottom_nav_bar.dart';

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
    final auth = context.read<AuthProvider>();
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un comentario')),
      );
      return;
    }
    if (auth.userModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión')),
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
      const SnackBar(content: Text('Opinión publicada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Padding(
                padding: EdgeInsets.only(left: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Escribir opinion',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
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
                      const Text(
                        'Calificación',
                        style: TextStyle(fontSize: 16, color: AppColors.primary),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (i) {
                          final star = i + 1;
                          return IconButton(
                            icon: Icon(
                              star <= _rating ? Icons.star : Icons.star_border,
                              color: AppColors.accent,
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
                        decoration: const InputDecoration(
                          labelText: 'Tu opinión',
                          hintText: 'Comparte tu experiencia...',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitReview,
                          child: const Text('Publicar', style: TextStyle(fontSize: 16)),
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
                      label: const Text('Escribir una opinion'),
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
                    return const Column(
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 80, color: AppColors.accent),
                        SizedBox(height: 24),
                        Text(
                          'Comentanos',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 12),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Queremos que escribas una opinion sobre nosotros',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: AppColors.accent, height: 1.5),
                          ),
                        ),
                      ],
                    );
                  }
                  return ListView.builder(
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
                          border: Border.all(color: AppColors.primary),
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: List.generate(5, (i) {
                                    return Icon(
                                      i < review.rating ? Icons.star : Icons.star_border,
                                      size: 16,
                                      color: AppColors.accent,
                                    );
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              review.comment,
                              style: const TextStyle(fontSize: 14, color: AppColors.accent),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              review.tourTitle,
                              style: const TextStyle(fontSize: 12, color: AppColors.accent),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }
}
