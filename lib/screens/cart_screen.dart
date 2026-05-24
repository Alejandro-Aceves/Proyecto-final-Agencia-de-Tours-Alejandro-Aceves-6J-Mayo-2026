import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/models/models.dart';
import 'package:lifetours/providers/providers.dart';
import 'package:lifetours/i18n/translations.dart';
import 'package:lifetours/widgets/bottom_nav_bar.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    _initCart();
  }

  void _initCart() {
    final cart = context.read<CartProvider>();
    if (cart.userId == null) {
      final uid = context.read<AuthProvider>().uid;
      if (uid != null) cart.init(uid);
    }
  }

  void _showEditDialog(CartItemModel item) {
    final lang = context.read<SettingsProvider>().locale.languageCode;
    int tempParticipants = item.participants;
    DateTime? tempDate = item.travelDate;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(AppTranslations.t('Editar reservación', lang)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.tourTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppTranslations.t('Personas', lang),
                    style: TextStyle(
                      fontSize: 14,
                      color: context.accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CircleButton(
                        icon: Icons.remove,
                        onPressed: tempParticipants > 1
                            ? () => setDialogState(() => tempParticipants--)
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
                          '$tempParticipants',
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
                        onPressed: () => setDialogState(() => tempParticipants++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: tempDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        locale: Locale(lang),
                      );
                      if (picked != null) {
                        setDialogState(() => tempDate = picked);
                      }
                    },
                    icon: Icon(
                      Icons.calendar_today,
                      color: tempDate != null
                          ? AppColors.greenAccent
                          : context.primary,
                    ),
                    label: Text(
                      tempDate != null
                          ? '${AppTranslations.t('Fecha:', lang)} ${tempDate!.day}/${tempDate!.month}/${tempDate!.year}'
                          : AppTranslations.t('Seleccionar fecha', lang),
                      style: TextStyle(
                        color: tempDate != null
                            ? AppColors.greenAccent
                            : context.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: tempDate != null
                            ? AppColors.greenAccent
                            : context.primary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(AppTranslations.t('Cancelar', lang)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context
                        .read<CartProvider>()
                        .updateCartItem(item.tourId, tempParticipants, tempDate);
                  },
                  child: Text(AppTranslations.t('Guardar', lang)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().locale.languageCode;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(AppTranslations.t('Carrito', lang)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.shopping_cart, color: context.primary),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<CartProvider>(
          builder: (context, cart, _) {
            if (cart.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (cart.items.isEmpty) {
              return Center(
                child: Text(
                  AppTranslations.t('Tu carrito está vacío', lang),
                  style: TextStyle(fontSize: 16, color: context.accent),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.separated(
                      itemCount: cart.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = cart.items[index];
                        return _CartCard(
                          item: item,
                          onEdit: () => _showEditDialog(item),
                          onPay: () => context.push('/payment', extra: item),
                          onDelete: () async {
                            await cart.removeItem(item.tourId);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppTranslations.t('Total', lang),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: context.primary,
                        ),
                      ),
                      Text(
                        '\$${cart.grandTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.greenAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/payment'),
                      child: Text(AppTranslations.t('Pagar todo', lang), style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }
}

class _CartCard extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback? onEdit;
  final VoidCallback? onPay;
  final VoidCallback? onDelete;

  const _CartCard({
    required this.item,
    this.onEdit,
    this.onPay,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().locale.languageCode;
    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 72,
                    height: 72,
                    color: AppColors.greenAccent.withAlpha(60),
                    child: Icon(Icons.image_outlined, color: AppColors.greenAccent),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 72,
                    height: 72,
                    color: AppColors.greenAccent.withAlpha(60),
                    child: Icon(Icons.image_outlined, color: AppColors.greenAccent),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.tourTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: context.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.destinationName,
                      style: TextStyle(fontSize: 14, color: context.accent),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${AppTranslations.t('Personas', lang)} ${item.participants}',
                      style: TextStyle(fontSize: 14, color: context.accent),
                    ),
                    if (item.travelDate != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${AppTranslations.t('Fecha:', lang)} ${item.travelDate!.day}/${item.travelDate!.month}/${item.travelDate!.year}',
                        style: TextStyle(fontSize: 14, color: context.accent),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      '\$${item.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: context.primary,
                    ),
                  ),
                ],
              ),
            ),
            if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline, color: context.primary),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (onEdit != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text(AppTranslations.t('Editar', lang), style: TextStyle(fontSize: 14)),
                  ),
                ),
              if (onEdit != null && onPay != null) const SizedBox(width: 12),
              if (onPay != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onPay,
                    icon: const Icon(Icons.payment, size: 18),
                    label: Text(AppTranslations.t('Pagar', lang), style: TextStyle(fontSize: 14)),
                  ),
                ),
            ],
          ),
        ],
      ),
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
