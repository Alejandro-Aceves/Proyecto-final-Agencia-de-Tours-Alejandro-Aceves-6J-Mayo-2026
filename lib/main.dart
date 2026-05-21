import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:lifetours/theme.dart';
import 'package:lifetours/firebase_options.dart';
import 'package:lifetours/screens/screens.dart';
import 'package:lifetours/providers/providers.dart';
import 'package:lifetours/models/models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    if (options != null) {
      await Firebase.initializeApp(options: options);
    }
  } catch (_) {}
  try {
    await initializeDateFormatting('es');
  } catch (_) {}
  runApp(const LifeToursApp());
}

class LifeToursApp extends StatefulWidget {
  const LifeToursApp({super.key});

  @override
  State<LifeToursApp> createState() => _LifeToursAppState();
}

class _LifeToursAppState extends State<LifeToursApp> {
  late final AuthProvider _authProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _router = _createRouter(_authProvider);
  }

  @override
  void dispose() {
    _authProvider.dispose();
    super.dispose();
  }

  GoRouter _createRouter(AuthProvider authProvider) {
    return GoRouter(
      refreshListenable: authProvider,
      initialLocation: '/',
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final status = authProvider.status;
        final location = state.matchedLocation;

        if (status == AuthStatus.uninitialized || status == AuthStatus.loading) {
          return null;
        }

        final isAuthRoute = location == '/' ||
            location == '/login' ||
            location == '/register';

        if (isAuthenticated && isAuthRoute) {
          return '/discover';
        }

        if (!isAuthenticated && !isAuthRoute) {
          return '/login';
        }

        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (_, __) => const LandingScreen()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(path: '/discover', builder: (_, __) => const DiscoverScreen()),
        GoRoute(path: '/catalog', builder: (_, __) => const CatalogScreen()),
        GoRoute(
          path: '/destination-detail',
          builder: (_, state) => DestinationDetailScreen(
            destinationId: state.extra as String?,
          ),
        ),
        GoRoute(
          path: '/review',
          builder: (_, state) => ReviewScreen(tourId: state.extra as String?),
        ),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        GoRoute(path: '/admin', builder: (_, __) => const AdminPanelScreen()),
        GoRoute(
          path: '/admin/users',
          builder: (_, state) => TableManagementScreen(
            collection: state.extra as String? ?? 'users',
          ),
        ),
        GoRoute(
          path: '/booking',
          builder: (_, state) => BookingScreen(tourId: state.extra as String?),
        ),
        GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
        GoRoute(
          path: '/my-reservations',
          builder: (_, __) => const MyReservationsScreen(),
        ),
        GoRoute(
          path: '/favorites-detail',
          builder: (_, __) => const FavoritesDetailScreen(),
        ),
        GoRoute(
          path: '/payment',
          builder: (_, state) => PaymentScreen(cartItem: state.extra as CartItemModel?),
        ),
        GoRoute(
          path: '/profile-detail',
          builder: (_, __) => const ProfileDetailScreen(),
        ),
        GoRoute(path: '/info', builder: (_, __) => const InfoScreen()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider(create: (_) => DestinationProvider()),
        ChangeNotifierProvider(create: (_) => TourProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp.router(
        title: 'Life Tours',
        theme: ThemeData(
          colorScheme: ColorScheme(
            brightness: Brightness.light,
            primary: AppColors.primary,
            onPrimary: AppColors.background,
            secondary: AppColors.accent,
            onSecondary: AppColors.background,
            surface: AppColors.background,
            onSurface: AppColors.primary,
            error: AppColors.primary,
            onError: AppColors.background,
          ),
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: AppColors.primary),
            titleTextStyle: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              elevation: 0,
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.background,
            labelStyle: const TextStyle(color: AppColors.accent),
            hintStyle: const TextStyle(color: AppColors.accent),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          dividerTheme: const DividerThemeData(
            color: AppColors.primary,
            thickness: 1,
          ),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
            headlineMedium: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            titleLarge: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              color: AppColors.primary,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              color: AppColors.accent,
              height: 1.5,
            ),
          ),
          useMaterial3: true,
        ),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
