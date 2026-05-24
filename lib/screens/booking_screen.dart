import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/models/models.dart';
import 'package:lifetours/services/services.dart';
import 'package:lifetours/providers/providers.dart';
import 'package:lifetours/widgets/bottom_nav_bar.dart';
import 'package:lifetours/i18n/translations.dart';

class BookingScreen extends StatefulWidget {
  final String? tourId;
  const BookingScreen({super.key, this.tourId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  TourModel? _tour;
  bool _loading = true;
  int _participants = 1;
  DateTime? _travelDate;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _travelDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _travelDate = picked);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTour();
  }

  void _loadTour() async {
    if (widget.tourId == null) return;
    final tour = await _firestoreService.getTour(widget.tourId!);
    if (mounted) {
      setState(() {
        _tour = tour;
        _loading = false;
      });
    }
  }

  void _addToCart() async {
    final lang = context.read<SettingsProvider>().locale.languageCode;
    if (_tour == null) return;
    if (_travelDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslations.t('Selecciona una fecha para el tour', lang)),
          backgroundColor: context.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final cart = context.read<CartProvider>();
    final uid = context.read<AuthProvider>().uid;
    if (uid != null) cart.init(uid);
    await cart.addItem(
      CartItemModel(
        tourId: _tour!.id,
        tourTitle: _tour!.title,
        destinationName: _tour!.destinationName,
        pricePerPerson: _tour!.price,
        participants: _participants,
        imageUrl: _tour!.imageUrl,
        travelDate: _travelDate,
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_tour!.title} ${AppTranslations.t('agregado al carrito', lang)}'),
        backgroundColor: context.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.push('/cart');
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().locale.languageCode;
    final totalPrice = _tour != null ? _tour!.price * _participants : 0.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppTranslations.t('Reservar', lang),
          style: TextStyle(color: context.primary, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _tour == null
                ? Center(child: Text(AppTranslations.t('Tour no encontrado', lang)))
                : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: _tour!.imageUrl,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      width: double.infinity,
                                      height: 200,
                                      color: context.primary,
                                      child: Center(
                                        child: Icon(Icons.image_outlined, size: 48, color: Colors.white),
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      width: double.infinity,
                                      height: 200,
                                      color: context.primary,
                                      child: Center(
                                        child: Icon(Icons.image_outlined, size: 48, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  _tour!.title,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                    color: context.primary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _tour!.destinationName,
                                  style: TextStyle(fontSize: 16, color: context.accent),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  _tour!.description,
                                  style: TextStyle(fontSize: 14, color: context.accent, height: 1.5),
                                ),
                                const SizedBox(height: 24),
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
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            AppTranslations.t('Personas', lang),
                                            style: TextStyle(fontSize: 18, color: context.primary),
                                          ),
                                          Text(
                                            '$_participants',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: context.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            AppTranslations.t('Precio por persona', lang),
                                            style: TextStyle(fontSize: 16, color: context.primary),
                                          ),
                                          Text(
                                            '\$${_tour!.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: AppColors.greenAccent,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 24),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            AppTranslations.t('Total', lang),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: context.primary,
                                            ),
                                          ),
                                          Text(
                                            '\$${totalPrice.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.greenAccent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: _pickDate,
                                    icon: Icon(
                                      Icons.calendar_today,
                                      color: _travelDate != null
                                          ? AppColors.greenAccent
                                            : context.primary,
                                    ),
                                    label: Text(
                                      _travelDate != null
                                          ? '${AppTranslations.t('Fecha:', lang)} ${_travelDate!.day}/${_travelDate!.month}/${_travelDate!.year}'
                                          : AppTranslations.t('Seleccionar fecha del tour', lang),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: _travelDate != null
                                            ? AppColors.greenAccent
                                            : context.primary,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      side: BorderSide(
                                        color: _travelDate != null
                                            ? AppColors.greenAccent
                                            : context.primary,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _CircleButton(
                                      icon: Icons.remove,
                                      onPressed: _participants > 1
                                          ? () => setState(() => _participants--)
                                          : null,
                                    ),
                                    const SizedBox(width: 24),
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: context.primary),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$_participants',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: context.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    _CircleButton(
                                      icon: Icons.add,
                                      onPressed: _participants < _tour!.capacity
                                          ? () => setState(() => _participants++)
                                          : null,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _addToCart,
                              icon: const Icon(Icons.shopping_cart),
                              label: Text(AppTranslations.t('Agregar al carrito', lang), style: const TextStyle(fontSize: 16)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
      ),
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _CircleButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: onPressed != null ? context.primary : AppColors.greenAccent.withAlpha(100),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Theme.of(context).colorScheme.onPrimary, size: 22),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      ),
    );
  }
}
