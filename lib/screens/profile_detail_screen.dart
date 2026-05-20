import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lifetours/theme.dart';
import 'package:lifetours/providers/providers.dart';

class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Perfil'),
      ),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            final user = auth.userModel;
            if (user == null) {
              return const Center(child: Text('Inicia sesión para ver tu perfil'));
            }
            String memberSince;
            try {
              memberSince = DateFormat('MMMM yyyy', 'es').format(user.createdAt);
            } catch (_) {
              memberSince = '${user.createdAt.month}/${user.createdAt.year}';
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Mi Perfil',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: AppColors.background,
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _InfoRow(label: 'Nombre', value: user.name),
                  const Divider(),
                  _InfoRow(label: 'Correo', value: user.email),
                  const Divider(),
                  _InfoRow(label: 'Telefono', value: user.phone ?? 'No registrado'),
                  const Divider(),
                  _InfoRow(label: 'Miembro desde', value: memberSince),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: AppColors.accent),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
