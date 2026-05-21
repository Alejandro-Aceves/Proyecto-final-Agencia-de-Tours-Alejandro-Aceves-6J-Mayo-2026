import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/models/models.dart';
import 'package:lifetours/providers/providers.dart';

class PaymentScreen extends StatefulWidget {
  final CartItemModel? cartItem;

  const PaymentScreen({super.key, this.cartItem});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  bool _processing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated || auth.userModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para pagar')),
      );
      return;
    }

    setState(() => _processing = true);

    final reservationProvider = context.read<ReservationProvider>();
    final cartProvider = context.read<CartProvider>();
    final uid = auth.uid!;
    final userName = auth.userModel!.name;

    if (widget.cartItem != null) {
      final item = widget.cartItem!;
      await reservationProvider.createReservation(
        userId: uid,
        userName: userName,
        tourId: item.tourId,
        tourTitle: item.tourTitle,
        tourImageUrl: item.imageUrl,
        destinationName: item.destinationName,
        pricePerPerson: item.pricePerPerson,
        participants: item.participants,
        totalPrice: item.totalPrice,
        travelDate: item.travelDate ?? DateTime.now(),
        notes: 'Comprado desde el carrito',
      );
      await cartProvider.removeItem(item.tourId);
    } else {
      for (final item in cartProvider.items) {
        await reservationProvider.createReservation(
          userId: uid,
          userName: userName,
          tourId: item.tourId,
          tourTitle: item.tourTitle,
          tourImageUrl: item.imageUrl,
          destinationName: item.destinationName,
          pricePerPerson: item.pricePerPerson,
          participants: item.participants,
          totalPrice: item.totalPrice,
          travelDate: item.travelDate ?? DateTime.now(),
          notes: 'Comprado desde el carrito',
        );
      }
      await cartProvider.clear();
    }

    if (!mounted) return;
    setState(() => _processing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.cartItem != null
              ? 'Pago exitoso: ${widget.cartItem!.tourTitle}'
              : 'Pago exitoso',
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        context.go('/my-reservations');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.cartItem != null
        ? 'Pagar ${widget.cartItem!.tourTitle}'
        : 'Pagar';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Pago'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Metodo de pago',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tarjeta de credito o debito',
                  style: TextStyle(fontSize: 16, color: AppColors.accent),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.credit_card, size: 48, color: AppColors.primary),
                      SizedBox(height: 4),
                      Text(
                        'Tarjeta',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Titular de la tarjeta',
                    hintText: 'Nombre completo',
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Ingrese el nombre del titular' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cardNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Numero de tarjeta',
                    hintText: '1234 5678 9012 3456',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 19,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Ingrese el numero de tarjeta';
                    final digits = v.replaceAll(' ', '');
                    if (digits.length < 16) return 'Numero invalido';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryController,
                        decoration: const InputDecoration(
                          labelText: 'Vencimiento',
                          hintText: 'MM/AA',
                        ),
                        keyboardType: TextInputType.datetime,
                        maxLength: 5,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Requerido';
                          if (v.length < 5) return 'Fecha invalida';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        decoration: const InputDecoration(
                          labelText: 'CVV',
                          hintText: '123',
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Requerido';
                          if (v.length < 3) return 'CVV invalido';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _processing ? null : _pay,
                    child: _processing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.background,
                            ),
                          )
                        : Text(label, style: const TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
