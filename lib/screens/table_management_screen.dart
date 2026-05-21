import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
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
        case 'reviews':
          final data = await _firestoreService.getReviews();
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
      case 'reviews':
        return 'Resenas';
      default:
        return 'Usuarios';
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _AddRecordForm(collection: widget.collection, onSaved: () {
        _loadItems();
      }),
    );
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.background),
        label: const Text('Agregar', style: TextStyle(color: AppColors.background)),
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
    } else if (item is ReviewModel) {
      title = '${List.filled(item.rating, '★').join()} ${item.tourTitle}';
      subtitle = '${item.userName} · ${item.comment.length > 60 ? '${item.comment.substring(0, 60)}...' : item.comment}';
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

class _AddRecordForm extends StatefulWidget {
  final String collection;
  final VoidCallback onSaved;

  const _AddRecordForm({required this.collection, required this.onSaved});

  @override
  State<_AddRecordForm> createState() => _AddRecordFormState();
}

class _AddRecordFormState extends State<_AddRecordForm> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();
  final _firestoreService = FirestoreService();
  bool _saving = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _destinationIdController = TextEditingController();
  final _destinationNameController = TextEditingController();
  final _durationDaysController = TextEditingController();
  final _capacityController = TextEditingController();
  final _availableSpotsController = TextEditingController();
  final _userIdController = TextEditingController();
  final _userNameController = TextEditingController();
  final _tourIdController = TextEditingController();
  final _tourTitleController = TextEditingController();
  final _tourImageUrlController = TextEditingController();
  final _pricePerPersonController = TextEditingController();
  final _participantsController = TextEditingController();
  final _totalPriceController = TextEditingController();
  final _notesController = TextEditingController();
  final _commentController = TextEditingController();

  bool _loadingRefs = false;
  List<UserModel> _users = [];
  List<DestinationModel> _destinations = [];
  List<TourModel> _tours = [];

  bool _isAdmin = false;
  bool _isActive = true;
  int _rating = 5;
  ReservationStatus _status = ReservationStatus.confirmed;
  DateTime _travelDate = DateTime.now();
  final List<String> _selectedCategories = [];

  static const _allCategories = [
    'cultura', 'agua', 'aireLibre', 'comida',
    'templos', 'museos', 'historia', 'restaurantes',
  ];

  @override
  void initState() {
    super.initState();
    _loadReferences();
  }

  Future<void> _loadReferences() async {
    _loadingRefs = true;
    try {
      final results = await Future.wait([
        _firestoreService.getAllUsers(),
        _firestoreService.getDestinations(),
        _firestoreService.getTours(),
      ]);
      if (mounted) {
        setState(() {
          _users = results[0] as List<UserModel>;
          _destinations = results[1] as List<DestinationModel>;
          _tours = results[2] as List<TourModel>;
          _loadingRefs = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingRefs = false);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nameController, _emailController, _cityController,
      _countryController, _descriptionController, _imageUrlController,
      _titleController, _priceController, _destinationIdController,
      _destinationNameController, _durationDaysController,
      _capacityController, _availableSpotsController, _userIdController,
      _userNameController, _tourIdController, _tourTitleController,
      _tourImageUrlController, _pricePerPersonController,
      _participantsController, _totalPriceController, _notesController,
      _commentController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      switch (widget.collection) {
        case 'destinations':
          await _firestoreService.addDestination(DestinationModel(
            id: _uuid.v4(),
            name: _nameController.text.trim(),
            country: _countryController.text.trim(),
            city: _cityController.text.trim(),
            description: _descriptionController.text.trim(),
            imageUrl: _imageUrlController.text.trim(),
            activities: const [],
            isActive: _isActive,
            createdAt: DateTime.now(),
          ));
          break;
        case 'tours':
          await _firestoreService.addTour(TourModel(
            id: _uuid.v4(),
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            price: double.parse(_priceController.text.trim()),
            imageUrl: _imageUrlController.text.trim(),
            destinationId: _destinationIdController.text.trim(),
            destinationName: _destinationNameController.text.trim(),
            categories: _selectedCategories
                .map((c) => TourCategoryExtension.fromString(c))
                .toList(),
            durationDays: int.parse(_durationDaysController.text.trim()),
            capacity: int.parse(_capacityController.text.trim()),
            availableSpots: int.parse(_availableSpotsController.text.trim()),
            averageRating: 0,
            reviewCount: 0,
            isActive: _isActive,
            createdAt: DateTime.now(),
          ));
          break;
        case 'reservations':
          await _firestoreService.addReservation(ReservationModel(
            id: _uuid.v4(),
            userId: _userIdController.text.trim(),
            userName: _userNameController.text.trim(),
            tourId: _tourIdController.text.trim(),
            tourTitle: _tourTitleController.text.trim(),
            tourImageUrl: _tourImageUrlController.text.trim(),
            destinationName: _destinationNameController.text.trim(),
            pricePerPerson: double.parse(_pricePerPersonController.text.trim()),
            participants: int.parse(_participantsController.text.trim()),
            totalPrice: double.parse(_totalPriceController.text.trim()),
            travelDate: _travelDate,
            status: _status,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
            createdAt: DateTime.now(),
          ));
          break;
        case 'reviews':
          await _firestoreService.addReview(ReviewModel(
            id: _uuid.v4(),
            userId: _userIdController.text.trim(),
            userName: _userNameController.text.trim(),
            tourId: _tourIdController.text.trim(),
            tourTitle: _tourTitleController.text.trim(),
            rating: _rating,
            comment: _commentController.text.trim(),
            createdAt: DateTime.now(),
          ));
          break;
        default:
          await _firestoreService.addUser(UserModel(
            uid: _uuid.v4(),
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            role: _isAdmin ? UserRole.admin : UserRole.user,
            createdAt: DateTime.now(),
          ));
      }

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro agregado correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Agregar ${_titleFor(widget.collection)}'),
          actions: [
            TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildFields(),
            ),
          ),
        ),
      ),
    );
  }

  String _titleFor(String collection) {
    switch (collection) {
      case 'destinations': return 'Destino';
      case 'tours': return 'Tour';
      case 'reservations': return 'Reserva';
      case 'reviews': return 'Resena';
      default: return 'Usuario';
    }
  }

  List<Widget> _buildFields() {
    switch (widget.collection) {
      case 'destinations': return _destinationFields();
      case 'tours': return _tourFields();
      case 'reservations': return _reservationFields();
      case 'reviews': return _reviewFields();
      default: return _userFields();
    }
  }

  Widget _refPicker({
    required String label,
    required String? value,
    required List<dynamic> items,
    required String Function(dynamic) itemLabel,
    required String Function(dynamic) itemSubtitle,
    required void Function(dynamic) onSelected,
  }) {
    final displayText = value ?? 'Seleccionar...';
    return InkWell(
      onTap: _loadingRefs ? null : () async {
        final result = await showDialog<dynamic>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(label),
            content: SizedBox(
              width: double.maxFinite,
              child: items.isEmpty
                  ? const Text('No hay datos disponibles')
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final item = items[i];
                        return ListTile(
                          title: Text(itemLabel(item)),
                          subtitle: Text(itemSubtitle(item)),
                          onTap: () => Navigator.of(ctx).pop(item),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        );
        if (result != null) onSelected(result);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Row(
          children: [
            Expanded(child: Text(displayText)),
            if (_loadingRefs)
              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ),
      ),
    );
  }

  // ── Users ──

  List<Widget> _userFields() {
    return [
      _field('Nombre', _nameController, validator: (v) => v?.isEmpty == true ? 'Requerido' : null),
      const SizedBox(height: 16),
      _field('Correo electronico', _emailController,
        keyboardType: TextInputType.emailAddress,
        validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
      ),
      const SizedBox(height: 16),
      SwitchListTile(
        title: const Text('Administrador'),
        value: _isAdmin,
        onChanged: (v) => setState(() => _isAdmin = v),
        contentPadding: EdgeInsets.zero,
      ),
    ];
  }

  // ── Destinations ──

  List<Widget> _destinationFields() {
    return [
      _field('Nombre', _nameController, validator: (v) => v?.isEmpty == true ? 'Requerido' : null),
      const SizedBox(height: 16),
      _field('Ciudad', _cityController, validator: (v) => v?.isEmpty == true ? 'Requerido' : null),
      const SizedBox(height: 16),
      _field('Pais', _countryController, validator: (v) => v?.isEmpty == true ? 'Requerido' : null),
      const SizedBox(height: 16),
      _field('Descripcion', _descriptionController, maxLines: 3,
        validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
      ),
      const SizedBox(height: 16),
      _field('URL de imagen', _imageUrlController,
        validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
      ),
      const SizedBox(height: 16),
      SwitchListTile(
        title: const Text('Activo'),
        value: _isActive,
        onChanged: (v) => setState(() => _isActive = v),
        contentPadding: EdgeInsets.zero,
      ),
    ];
  }

  // ── Tours ──

  List<Widget> _tourFields() {
    return [
      _field('Titulo', _titleController, validator: (v) => v?.isEmpty == true ? 'Requerido' : null),
      const SizedBox(height: 16),
      _field('Descripcion', _descriptionController, maxLines: 3,
        validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
      ),
      const SizedBox(height: 16),
      _field('Precio', _priceController, keyboardType: TextInputType.numberWithOptions(decimal: true),
        validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
      ),
      const SizedBox(height: 16),
      _field('URL de imagen', _imageUrlController,
        validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
      ),
      _refPicker(
        label: 'Destino',
        value: _destinationNameController.text.isEmpty ? null : _destinationNameController.text,
        items: _destinations,
        itemLabel: (d) => (d as DestinationModel).name,
        itemSubtitle: (d) => '${(d as DestinationModel).city}, ${d.country}',
        onSelected: (d) {
          setState(() {
            final dest = d as DestinationModel;
            _destinationIdController.text = dest.id;
            _destinationNameController.text = dest.name;
          });
        },
      ),
      const SizedBox(height: 16),
      _field('Duracion (dias)', _durationDaysController,
        keyboardType: TextInputType.number,
        validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
      ),
      const SizedBox(height: 16),
      _field('Capacidad', _capacityController,
        keyboardType: TextInputType.number,
        validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
      ),
      const SizedBox(height: 16),
      _field('Lugares disponibles', _availableSpotsController,
        keyboardType: TextInputType.number,
        validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
      ),
      const SizedBox(height: 16),
      const Text('Categorias', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: _allCategories.map((c) {
          final selected = _selectedCategories.contains(c);
          return FilterChip(
            label: Text(TourCategoryExtension.fromString(c).label),
            selected: selected,
            onSelected: (v) {
              setState(() {
                if (v) {
                  _selectedCategories.add(c);
                } else {
                  _selectedCategories.remove(c);
                }
              });
            },
          );
        }).toList(),
      ),
      const SizedBox(height: 16),
      SwitchListTile(
        title: const Text('Activo'),
        value: _isActive,
        onChanged: (v) => setState(() => _isActive = v),
        contentPadding: EdgeInsets.zero,
      ),
    ];
  }

  // ── Reservations ──

  List<Widget> _reservationFields() {
    return [
      _refPicker(
        label: 'Usuario',
        value: _userNameController.text.isEmpty ? null : _userNameController.text,
        items: _users,
        itemLabel: (u) => (u as UserModel).name,
        itemSubtitle: (u) => (u as UserModel).email,
        onSelected: (u) {
          setState(() {
            final user = u as UserModel;
            _userIdController.text = user.uid;
            _userNameController.text = user.name;
          });
        },
      ),
      const SizedBox(height: 16),
      _refPicker(
        label: 'Tour',
        value: _tourTitleController.text.isEmpty ? null : _tourTitleController.text,
        items: _tours,
        itemLabel: (t) => (t as TourModel).title,
        itemSubtitle: (t) => '\$${(t as TourModel).price.toStringAsFixed(0)} · ${t.destinationName}',
        onSelected: (t) {
          setState(() {
            final tour = t as TourModel;
            _tourIdController.text = tour.id;
            _tourTitleController.text = tour.title;
            _tourImageUrlController.text = tour.imageUrl;
            _destinationNameController.text = tour.destinationName;
            _pricePerPersonController.text = tour.price.toStringAsFixed(2);
          });
        },
      ),
      const SizedBox(height: 16),
      _field('Participantes', _participantsController,
        keyboardType: TextInputType.number,
        validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
      ),
      const SizedBox(height: 16),
      _field('Precio total', _totalPriceController,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
      ),
      const SizedBox(height: 16),
      InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _travelDate,
            firstDate: DateTime(2020),
            lastDate: DateTime(2035),
          );
          if (date != null) setState(() => _travelDate = date);
        },
        child: InputDecorator(
          decoration: const InputDecoration(labelText: 'Fecha de viaje'),
          child: Text(
            '${_travelDate.day}/${_travelDate.month}/${_travelDate.year}',
          ),
        ),
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<ReservationStatus>(
        initialValue: _status,
        decoration: const InputDecoration(labelText: 'Estado'),
        items: ReservationStatus.values.map((s) => DropdownMenuItem(
          value: s,
          child: Text(s.label),
        )).toList(),
        onChanged: (v) {
          if (v != null) setState(() => _status = v);
        },
      ),
      const SizedBox(height: 16),
      _field('Notas', _notesController, maxLines: 2),
    ];
  }

  // ── Reviews ──

  List<Widget> _reviewFields() {
    return [
      _refPicker(
        label: 'Usuario',
        value: _userNameController.text.isEmpty ? null : _userNameController.text,
        items: _users,
        itemLabel: (u) => (u as UserModel).name,
        itemSubtitle: (u) => (u as UserModel).email,
        onSelected: (u) {
          setState(() {
            final user = u as UserModel;
            _userIdController.text = user.uid;
            _userNameController.text = user.name;
          });
        },
      ),
      const SizedBox(height: 16),
      _refPicker(
        label: 'Tour',
        value: _tourTitleController.text.isEmpty ? null : _tourTitleController.text,
        items: _tours,
        itemLabel: (t) => (t as TourModel).title,
        itemSubtitle: (t) => '\$${(t as TourModel).price.toStringAsFixed(0)} · ${t.destinationName}',
        onSelected: (t) {
          setState(() {
            final tour = t as TourModel;
            _tourIdController.text = tour.id;
            _tourTitleController.text = tour.title;
          });
        },
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<int>(
        initialValue: _rating,
        decoration: const InputDecoration(labelText: 'Calificacion'),
        items: [1, 2, 3, 4, 5].map((r) => DropdownMenuItem(
          value: r,
          child: Text('${List.filled(r, '★').join()} ($r/5)'),
        )).toList(),
        onChanged: (v) {
          if (v != null) setState(() => _rating = v);
        },
      ),
      const SizedBox(height: 16),
      _field('Comentario', _commentController, maxLines: 3,
        validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
      ),
    ];
  }

  Widget _field(String label, TextEditingController controller, {
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      validator: validator,
    );
  }
}
