import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/models/models.dart';
import 'package:lifetours/providers/providers.dart';
import 'package:lifetours/i18n/translations.dart';

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
    final lang = context.read<SettingsProvider>().locale.languageCode;
    if (!auth.isAuthenticated || auth.userModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTranslations.t('Debes iniciar sesión para pagar', lang))),
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
              ? '${AppTranslations.t('Pago exitoso: ', lang)}${widget.cartItem!.tourTitle}'
              : AppTranslations.t('Pago exitoso', lang),
        ),
        backgroundColor: context.primary,
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
    final lang = context.watch<SettingsProvider>().locale.languageCode;
    final label = widget.cartItem != null
        ? '${AppTranslations.t('Pagar', lang)} ${widget.cartItem!.tourTitle}'
        : AppTranslations.t('Pagar', lang);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(AppTranslations.t('Pago', lang)),
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
                Text(
                  AppTranslations.t('Metodo de pago', lang),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: context.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppTranslations.t('Tarjeta de credito o debito', lang),
                  style: TextStyle(fontSize: 16, color: context.accent),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(color: context.primary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.credit_card, size: 48, color: context.primary),
                      const SizedBox(height: 4),
                      Text(
                        AppTranslations.t('Tarjeta', lang),
                          style: TextStyle(
                            fontSize: 14,
                            color: context.accent,
                            fontWeight: FontWeight.w500,
                          ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: AppTranslations.t('Titular de la tarjeta', lang),
                    hintText: AppTranslations.t('Nombre completo', lang),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? AppTranslations.t('Ingrese el nombre del titular', lang) : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cardNumberController,
                  decoration: InputDecoration(
                    labelText: AppTranslations.t('Numero de tarjeta', lang),
                    hintText: AppTranslations.t('1234 5678 9012 3456', lang),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 19,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return AppTranslations.t('Ingrese el numero de tarjeta', lang);
                    final digits = v.replaceAll(' ', '');
                    if (digits.length < 16) return AppTranslations.t('Numero invalido', lang);
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryController,
                        decoration: InputDecoration(
                          labelText: AppTranslations.t('Vencimiento', lang),
                          hintText: AppTranslations.t('MM/AA', lang),
                        ),
                        keyboardType: TextInputType.datetime,
                        maxLength: 5,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return AppTranslations.t('Requerido', lang);
                          if (v.length < 5) return AppTranslations.t('Fecha invalida', lang);
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        decoration: InputDecoration(
                          labelText: AppTranslations.t('CVV', lang),
                          hintText: AppTranslations.t('123', lang),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return AppTranslations.t('Requerido', lang);
                          if (v.length < 3) return AppTranslations.t('CVV invalido', lang);
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
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
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
