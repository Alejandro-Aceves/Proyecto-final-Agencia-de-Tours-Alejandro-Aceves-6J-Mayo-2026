import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
  late final SettingsProvider _settingsProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _settingsProvider = SettingsProvider(_authProvider);
    _router = _createRouter(_authProvider);
  }

  @override
  void dispose() {
    _authProvider.dispose();
    _settingsProvider.dispose();
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
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _settingsProvider),
        ChangeNotifierProvider(create: (_) => DestinationProvider()),
        ChangeNotifierProvider(create: (_) => TourProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp.router(
            title: 'Life Tours',
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: settings.themeMode,
            locale: settings.locale,
            supportedLocales: const [Locale('es'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
