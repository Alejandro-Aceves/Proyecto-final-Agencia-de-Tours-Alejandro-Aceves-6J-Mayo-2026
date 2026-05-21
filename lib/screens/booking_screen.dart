import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/models/models.dart';
import 'package:lifetours/services/services.dart';
import 'package:lifetours/providers/providers.dart';
import 'package:lifetours/widgets/bottom_nav_bar.dart';

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
    if (_tour == null) return;
    if (_travelDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una fecha para el tour'),
          backgroundColor: AppColors.primary,
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
        content: Text('${_tour!.title} agregado al carrito'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.push('/cart');
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = _tour != null ? _tour!.price * _participants : 0.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Reservar',
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _tour == null
                ? const Center(child: Text('Tour no encontrado'))
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
                                      color: AppColors.primary,
                                      child: Center(
                                        child: Icon(Icons.image_outlined, size: 48, color: AppColors.background),
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      width: double.infinity,
                                      height: 200,
                                      color: AppColors.primary,
                                      child: Center(
                                        child: Icon(Icons.image_outlined, size: 48, color: AppColors.background),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  _tour!.title,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _tour!.destinationName,
                                  style: const TextStyle(fontSize: 16, color: AppColors.accent),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  _tour!.description,
                                  style: const TextStyle(fontSize: 14, color: AppColors.accent, height: 1.5),
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.primary),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Personas',
                                            style: TextStyle(fontSize: 18, color: AppColors.primary),
                                          ),
                                          Text(
                                            '$_participants',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Precio por persona',
                                            style: TextStyle(fontSize: 16, color: AppColors.primary),
                                          ),
                                          Text(
                                            '\$${_tour!.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: AppColors.accent,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 24),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Total',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          Text(
                                            '\$${totalPrice.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.accent,
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
                                          ? AppColors.accent
                                          : AppColors.primary,
                                    ),
                                    label: Text(
                                      _travelDate != null
                                          ? 'Fecha: ${_travelDate!.day}/${_travelDate!.month}/${_travelDate!.year}'
                                          : 'Seleccionar fecha del tour',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: _travelDate != null
                                            ? AppColors.accent
                                            : AppColors.primary,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      side: BorderSide(
                                        color: _travelDate != null
                                            ? AppColors.accent
                                            : AppColors.primary,
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
                                        border: Border.all(color: AppColors.primary),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$_participants',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: AppColors.primary,
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
                              label: const Text('Agregar al carrito', style: TextStyle(fontSize: 16)),
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
        color: onPressed != null ? AppColors.primary : AppColors.accent.withAlpha(100),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.background, size: 22),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      ),
    );
  }
}
