import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lifetours/theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Row(
                  children: [
                    Expanded(child: Divider(thickness: 1)),
                    SizedBox(width: 12),
                    Text(
                      'Life Tours',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(child: Divider(thickness: 1)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Descubre experiencias\ndiseñadas para ti',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.accent,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 64),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/register'),
                    child:
                        const Text('Crear Cuenta', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.push('/login'),
                    child: const Text('Iniciar Sesion',
                        style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
