import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/models/models.dart';
import 'package:lifetours/services/services.dart';
import 'package:lifetours/widgets/bottom_nav_bar.dart';

class TableManagementScreen extends StatefulWidget {
  final String collection;
  const TableManagementScreen({super.key, this.collection = 'users'});

  @override
  State<TableManagementScreen> createState() => _TableManagementScreenState();
}

class _TableManagementScreenState extends State<TableManagementScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<dynamic> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    _loading = true;
    _error = null;
    try {
      switch (widget.collection) {
        case 'destinations':
          final data = await _firestoreService.getDestinations();
          _items = data;
          break;
        case 'tours':
          final data = await _firestoreService.getTours();
          _items = data;
          break;
        case 'reservations':
          final data = await _firestoreService.getUserReservations('');
          _items = data;
          break;
        default:
          final data = await _firestoreService.getAllUsers();
          _items = data;
      }
    } catch (e) {
      _error = 'Error al cargar datos.';
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  String get _title {
    switch (widget.collection) {
      case 'destinations':
        return 'Destinos';
      case 'tours':
        return 'Tours';
      case 'reservations':
        return 'Reservas';
      default:
        return 'Usuarios';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(_title),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  )
                : _items.isEmpty
                    ? const Center(child: Text('No hay datos'))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              _title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ...List.generate(_items.length, (i) {
                              final item = _items[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildItemCard(item),
                              );
                            }),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildItemCard(dynamic item) {
    String title;
    String subtitle;

    if (item is UserModel) {
      title = item.name;
      subtitle = '${item.email} · ${item.isAdmin ? "Admin" : "Usuario"}';
    } else if (item is DestinationModel) {
      title = item.name;
      subtitle = '${item.city}, ${item.country}';
    } else if (item is TourModel) {
      title = item.title;
      subtitle = '\$${item.price} · ${item.destinationName}';
    } else if (item is ReservationModel) {
      title = item.tourTitle;
      subtitle = '${item.userName} · ${item.status.label}';
    } else {
      title = 'Item';
      subtitle = '';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
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
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: AppColors.accent),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Editar',
                  style: TextStyle(color: AppColors.background, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: AppColors.primary, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
