# Documentación de LifeTours

Aplicación móvil para agencia de tours desarrollada con **Flutter** y **Firebase**.

---

## Índice

1. [Descripción General](#1-descripción-general)
2. [Tecnologías y Dependencias](#2-tecnologías-y-dependencias)
3. [Arquitectura](#3-arquitectura)
4. [Estructura del Proyecto](#4-estructura-del-proyecto)
5. [Modelos de Datos](#5-modelos-de-datos)
6. [Firestore — Esquema y Colecciones](#6-firestore--esquema-y-colecciones)
7. [Ruteo (GoRouter)](#7-ruteo-gorouter)
8. [Autenticación](#8-autenticación)
9. [Proveedores (State Management)](#9-proveedores-state-management)
10. [Servicios](#10-servicios)
11. [Pantallas](#11-pantallas)
12. [Internacionalización (i18n)](#12-internacionalización-i18n)
13. [Tema y Estilos](#13-tema-y-estilos)
14. [Flujo de Pago y Reserva](#14-flujo-de-pago-y-reserva)
15. [Chat Asistente IA](#15-chat-asistente-ia)
16. [Panel de Administración](#16-panel-de-administración)
17. [Comandos Útiles](#17-comandos-útiles)
18. [Credenciales de Prueba](#18-credenciales-de-prueba)
19. [Despliegue Web](#19-despliegue-web)

---

## 1. Descripción General

LifeTours es una aplicación que permite a los usuarios explorar destinos turísticos, reservar tours, escribir reseñas, gestionar favoritos y chatear con un asistente virtual. Incluye un panel de administración para gestionar usuarios, destinos, tours, reservas y reseñas.

**Versión**: 1.0.0+1  
**Package name**: `lifetours`  
**Android / iOS ID**: `com.life.tours`  
**Firebase project**: `lifetours-452a8`

---

## 2. Tecnologías y Dependencias

### Lenguaje y SDK

| Tecnología | Versión |
|---|---|
| Flutter | 3.x |
| Dart SDK | >=3.2.0 <4.0.0 |
| Material 3 | incluido |

### Dependencias principales

| Paquete | Versión | Propósito |
|---|---|---|
| `firebase_core` | ^3.3.0 | Inicialización de Firebase |
| `firebase_auth` | ^5.1.4 | Autenticación de usuarios |
| `cloud_firestore` | ^5.2.1 | Base de datos Firestore |
| `firebase_storage` | ^12.1.3 | Almacenamiento de archivos (declarada, no usada aún) |
| `provider` | ^6.1.2 | Manejo de estado (ChangeNotifier) |
| `go_router` | ^14.2.7 | Navegación declarativa |
| `cached_network_image` | ^3.3.1 | Carga y caché de imágenes |
| `flutter_svg` | ^2.0.10+1 | Renderizado SVG (declarada) |
| `image_picker` | ^1.1.2 | Selección de imágenes (declarada) |
| `shimmer` | ^3.0.0 | Efecto shimmer de carga (declarada) |
| `intl` | ^0.20.2 | Formateo de fechas / i18n |
| `equatable` | ^2.0.5 | Igualdad por valor en modelos |
| `uuid` | ^4.4.2 | Generación de UUIDs |
| `logger` | ^2.4.0 | Logging (declarada, no usada) |
| `shared_preferences` | ^2.3.2 | Almacenamiento local |
| `google_fonts` | ^6.2.1 | Tipografía Poppins |
| `flutter_launcher_icons` | ^0.13.1 | Iconos de lanzador |
| `cupertino_icons` | ^1.0.8 | Iconos iOS |

### Dependencias de desarrollo

| Paquete | Propósito |
|---|---|
| `flutter_test` | Testing unitario y de widgets |
| `flutter_lints` | Reglas de linting (`package:flutter_lints/flutter.yaml`) |

---

## 3. Arquitectura

La aplicación sigue el patrón **Provider + ChangeNotifier** con una arquitectura de capas:

```
Firestore
   ↓ (streams en tiempo real)
Servicios (FirestoreService, AuthService, AiChatService)
   ↓
Proveedores (ChangeNotifier)
   ↓ (notifyListeners)
Widgets / Screens (Consumer / context.watch)
```

**Flujo de autenticación**:
```
FirebaseAuth.authStateChanges()
  → AuthProvider._onAuthStateChanged()
    → fetch UserModel desde Firestore
      → set estado (authenticated / unauthenticated)
        → notifyListeners → GoRouter redirect → navegación
```

**Flujo de datos en tiempo real**:
```
Firestore colección
  → .snapshots() stream
    → Provider escucha en constructor
      → notifyListeners en cada cambio
        → UI se reconstruye automáticamente
```

---

## 4. Estructura del Proyecto

```
lib/
  main.dart                        # Punto de entrada, GoRouter, MultiProvider
  theme.dart                       # AppColors, temas claro/oscuro, GoogleFonts
  firebase_options.dart            # Configuración de Firebase por plataforma

  models/
    models.dart                    # Barrel export
    firestore_constants.dart       # Constantes de colecciones y campos
    destination_model.dart         # DestinationModel
    tour_model.dart                # TourModel + TourCategory enum
    user_model.dart                # UserModel + UserRole enum
    reservation_model.dart         # ReservationModel + ReservationStatus enum
    review_model.dart              # ReviewModel
    favorite_model.dart            # FavoriteModel
    cart_item_model.dart           # CartItemModel

  screens/
    screens.dart                   # Barrel export
    landing_screen.dart            # Pantalla de bienvenida
    login_screen.dart              # Inicio de sesión
    register_screen.dart           # Registro de usuario
    discover_screen.dart           # Descubrimiento principal
    catalog_screen.dart            # Catálogo de tours
    destination_detail_screen.dart # Detalle de destino
    booking_screen.dart            # Reserva de tour
    cart_screen.dart               # Carrito de compras
    payment_screen.dart            # Pago con tarjeta
    my_reservations_screen.dart    # Mis reservas
    favorites_detail_screen.dart   # Favoritos
    review_screen.dart             # Reseñas
    profile_screen.dart            # Perfil / menú de cuenta
    profile_detail_screen.dart     # Datos del perfil
    admin_panel_screen.dart        # Panel de administración
    table_management_screen.dart   # CRUD de colecciones
    info_screen.dart               # Información / contacto
    settings_screen.dart           # Configuración (tema, idioma)
    chat_screen.dart               # Asistente de chat IA

  providers/
    providers.dart                 # Barrel export
    auth_provider.dart             # AuthProvider
    settings_provider.dart         # SettingsProvider
    destination_provider.dart      # DestinationProvider
    tour_provider.dart             # TourProvider
    review_provider.dart           # ReviewProvider
    reservation_provider.dart      # ReservationProvider
    favorite_provider.dart         # FavoriteProvider
    cart_provider.dart             # CartProvider
    chat_provider.dart             # ChatProvider

  services/
    services.dart                  # Barrel export
    firestore_service.dart         # FirestoreService (CRUD completo)
    auth_service.dart              # AuthService (FirebaseAuth + Firestore)
    ai_chat_service.dart           # AiChatService (Cloud Function + fallback local)

  widgets/
    bottom_nav_bar.dart            # BottomNavigationBar compartido

  i18n/
    translations.dart              # Traducciones ES/EN (mapa clave → valor)

  utils/                           # Directorio vacío

test/
  widget_test.dart                 # Test de humo: verifica que LandingScreen renderiza
```

---

## 5. Modelos de Datos

Todos los modelos extienden `Equatable` e incluyen: `fromMap()`, `fromDocumentSnapshot()`, `toMap()`, `copyWith()`, `props`, `toString()`.

### 5.1 DestinationModel

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | `String` | Identificador único |
| `name` | `String` | Nombre del destino |
| `country` | `String` | País |
| `city` | `String` | Ciudad |
| `description` | `String` | Descripción |
| `imageUrl` | `String` | URL de imagen |
| `activities` | `List<String>` | Lista de actividades |
| `isActive` | `bool` | Soft delete (default: true) |
| `createdAt` | `DateTime` | Fecha de creación |

### 5.2 TourModel

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | `String` | Identificador único |
| `title` | `String` | Título del tour |
| `description` | `String` | Descripción |
| `price` | `double` | Precio por persona |
| `imageUrl` | `String` | URL de imagen |
| `destinationId` | `String` | Referencia al destino |
| `destinationName` | `String` | Nombre del destino (denormalizado) |
| `categories` | `List<TourCategory>` | Categorías del tour |
| `durationDays` | `int` | Duración en días |
| `capacity` | `int` | Capacidad total |
| `availableSpots` | `int` | Lugares disponibles |
| `averageRating` | `double` | Calificación promedio |
| `reviewCount` | `int` | Cantidad de reseñas |
| `isActive` | `bool` | Soft delete |
| `createdAt` | `DateTime` | Fecha de creación |

**TourCategory enum**: `cultura`, `agua`, `aireLibre`, `comida`, `templos`, `museos`, `historia`, `restaurantes`.  
Tiene método `fromString()` y getter `.label`.

### 5.3 UserModel

| Campo | Tipo | Descripción |
|---|---|---|
| `uid` | `String` | UID de Firebase Auth |
| `name` | `String` | Nombre completo |
| `email` | `String` | Correo electrónico |
| `role` | `UserRole` | `user` o `admin` |
| `photoUrl` | `String?` | URL de foto de perfil |
| `phone` | `String?` | Teléfono |
| `darkMode` | `bool` | Preferencia de tema oscuro |
| `language` | `String` | Idioma preferido (`'es'` o `'en'`) |
| `createdAt` | `DateTime` | Fecha de registro |

**UserRole enum**: `user`, `admin`. Getter `isAdmin` en `UserModel`.

### 5.4 ReservationModel

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | `String` | Identificador único |
| `userId` | `String` | UID del usuario |
| `userName` | `String` | Nombre del usuario (denormalizado) |
| `tourId` | `String` | ID del tour |
| `tourTitle` | `String` | Título del tour (denormalizado) |
| `tourImageUrl` | `String` | Imagen del tour (denormalizado) |
| `destinationName` | `String` | Destino (denormalizado) |
| `pricePerPerson` | `double` | Precio por persona |
| `participants` | `int` | Cantidad de participantes |
| `totalPrice` | `double` | Precio total calculado |
| `travelDate` | `DateTime` | Fecha del viaje |
| `status` | `ReservationStatus` | `pending`, `confirmed`, `cancelled`, `completed` |
| `notes` | `String?` | Notas adicionales |
| `createdAt` | `DateTime` | Fecha de creación |

**ReservationStatus enum**: `pending`, `confirmed`, `cancelled`, `completed`. Getter `isCancellable`.

### 5.5 ReviewModel

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | `String` | Identificador único |
| `userId` | `String` | UID del usuario |
| `userName` | `String` | Nombre (denormalizado) |
| `userPhotoUrl` | `String?` | Foto (denormalizado) |
| `tourId` | `String` | ID del tour reseñado |
| `tourTitle` | `String` | Título del tour (denormalizado) |
| `rating` | `int` | Calificación (1-5, con assert) |
| `comment` | `String` | Comentario |
| `createdAt` | `DateTime` | Fecha de creación |

### 5.6 FavoriteModel

| Campo | Tipo | Descripción |
|---|---|---|
| `tourId` | `String` | ID del tour |
| `tourTitle` | `String` | Título (denormalizado) |
| `tourImageUrl` | `String` | Imagen (denormalizado) |
| `destinationName` | `String` | Destino (denormalizado) |
| `price` | `double` | Precio (denormalizado) |
| `savedAt` | `DateTime` | Fecha de guardado |

### 5.7 CartItemModel

| Campo | Tipo | Descripción |
|---|---|---|
| `tourId` | `String` | ID del tour (usa el ID como doc ID en la subcolección) |
| `tourTitle` | `String` | Título (denormalizado) |
| `destinationName` | `String` | Destino (denormalizado) |
| `pricePerPerson` | `double` | Precio por persona |
| `participants` | `int` | Cantidad de participantes |
| `imageUrl` | `String` | URL de imagen |
| `travelDate` | `DateTime?` | Fecha de viaje seleccionada |

Getter: `double get totalPrice => pricePerPerson * participants`

---

## 6. Firestore — Esquema y Colecciones

### Colecciones

| Colección | Path | Tipo |
|---|---|---|
| `users` | `users/{uid}` | Principal |
| `destinations` | `destinations/{destinationId}` | Principal |
| `tours` | `tours/{tourId}` | Principal |
| `reservations` | `reservations/{reservationId}` | Principal |
| `reviews` | `reviews/{reviewId}` | Principal |
| `favorites` | `users/{uid}/favorites/{tourId}` | Subcolección |
| `cart` | `users/{uid}/cart/{tourId}` | Subcolección |

### Convenciones

- Los nombres de colección y campos están definidos como constantes en `lib/models/firestore_constants.dart`.
- `favorites` y `cart` son subcolecciones bajo `users/{uid}`.
- Campos denormalizados (como `userName`, `tourTitle`, `destinationName`) se almacenan en los documentos para eficiencia de lectura.
- Los tours y destinos usan **soft delete** (campo `isActive = false`).
- Las reservas usan el campo `status` para seguimiento del ciclo de vida.

### Reglas de Seguridad (Firestore Security Rules)

Definidas en `FIRESTORE_SCHEMA.md` con 9 reglas que cubren:
- Solo admins pueden escribir en `destinations` y `tours`
- Usuarios autenticados pueden leer su propio documento en `users`, destinos y tours activos
- Usuarios solo pueden escribir/modificar sus propias reservas, reseñas y favoritos
- Validación de datos en escritura para cada colección

---

## 7. Ruteo (GoRouter)

El router está definido en `main.dart` mediante `_createRouter()`. Usa `refreshListenable: authProvider` para reaccionar a cambios de autenticación.

### Lógica de Redirect

1. Si `AuthStatus` es `uninitialized` o `loading` → esperar (return null)
2. Si está autenticado y está en ruta de auth (`/`, `/login`, `/register`) → redirigir a `/discover`
3. Si **no** está autenticado y está en ruta protegida → redirigir a `/` (LandingScreen)

### Tabla de Rutas

| Ruta | Pantalla | Parámetros |
|---|---|---|
| `/` | `LandingScreen` | — |
| `/login` | `LoginScreen` | — |
| `/register` | `RegisterScreen` | — |
| `/discover` | `DiscoverScreen` | — |
| `/catalog` | `CatalogScreen` | — |
| `/destination-detail` | `DestinationDetailScreen` | `destinationId` (String?) |
| `/review` | `ReviewScreen` | `tourId` (String?) |
| `/profile` | `ProfileScreen` | — |
| `/admin` | `AdminPanelScreen` | — |
| `/admin/:collection` | `TableManagementScreen` | `collection` (String) |
| `/booking` | `BookingScreen` | `tourId` (String?) |
| `/cart` | `CartScreen` | — |
| `/my-reservations` | `MyReservationsScreen` | — |
| `/favorites-detail` | `FavoritesDetailScreen` | — |
| `/payment` | `PaymentScreen` | `cartItem` (CartItemModel?) |
| `/profile-detail` | `ProfileDetailScreen` | — |
| `/info` | `InfoScreen` | — |
| `/settings` | `SettingsScreen` | — |
| `/chat` | `ChatScreen` | — |

---

## 8. Autenticación

### AuthProvider

- Escucha `FirebaseAuth.instance.authStateChanges()` desde el constructor.
- Estados: `uninitialized` → `authenticated` / `unauthenticated` / `loading`
- En cada cambio de auth, busca el documento del usuario en Firestore (`users/{uid}`).
- Almacena el `UserModel` completo y expone getters: `isAuthenticated`, `isAdmin`, `uid`.
- Maneja errores de Firebase Auth con mensajes en español.

### Flujo de registro

1. `signUp(name, email, password)` crea el usuario en Firebase Auth.
2. Crea un documento `users/{uid}` con `UserModel`.
3. El `authStateChanges` detecta el nuevo usuario autenticado.
4. El redirect de GoRouter lo envía a `/discover`.

### Flujo de inicio de sesión

1. `signIn(email, password)` llama a `signInWithEmailAndPassword`.
2. Mapea errores `FirebaseAuthException` (user-disabled, wrong-password, user-not-found, etc.) a mensajes en español.
3. El redirect lo lleva a `/discover`.

### Flujo de cierre de sesión

1. `signOut()` llama a `FirebaseAuth.signOut()`.
2. El listener de auth cambia a `unauthenticated`.
3. El redirect lo lleva a `/` (LandingScreen).

---

## 9. Proveedores (State Management)

### MultiProvider (en `main.dart`)

```dart
MultiProvider(
  providers: [
    Provider<AuthProvider>(value: authProvider),
    ChangeNotifierProvider<SettingsProvider>(value: settingsProvider),
    ChangeNotifierProvider<DestinationProvider>(create: (_) => DestinationProvider()),
    ChangeNotifierProvider<TourProvider>(create: (_) => TourProvider()),
    ChangeNotifierProvider<ReviewProvider>(create: (_) => ReviewProvider()),
    ChangeNotifierProvider<ReservationProvider>(create: (_) => ReservationProvider()),
    ChangeNotifierProvider<FavoriteProvider>(create: (_) => FavoriteProvider()),
    ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
    ChangeNotifierProvider<ChatProvider>(create: (_) => ChatProvider()),
  ],
  child: MaterialApp.router(...)
)
```

### Resumen de cada proveedor

| Proveedor | Escucha Firestore | Métodos clave |
|---|---|---|
| `AuthProvider` | Sí (`authStateChanges`) | `signIn()`, `signUp()`, `signOut()` |
| `SettingsProvider` | No (SharedPreferences + Firestore) | `toggleDarkMode()`, `toggleLanguage()` |
| `DestinationProvider` | Sí (`destinationsStream`) | `loadDestinations()`, `selectDestination()` |
| `TourProvider` | Sí (`toursStream`, `toursByDestinationStream`) | `loadToursByDestination()`, `selectTour()` |
| `ReviewProvider` | Sí (`reviewsStream`) | `addReview()`, `clearError()` |
| `ReservationProvider` | Sí (`userReservationsStream`) | `init(userId)`, `createReservation()`, `cancelReservation()` |
| `FavoriteProvider` | Sí (`userFavoritesStream`) | `init(userId)`, `toggleFavorite()`, `isFavorite()` |
| `CartProvider` | Sí (`userCartStream`) | `init(userId)`, `addItem()`, `removeItem()`, `updateParticipants()`, `clear()` |
| `ChatProvider` | No | `sendMessage(text, {destinations, tours})` |

Los providers de datos (`Destination`, `Tour`, `Review`, `Reservation`, `Favorite`, `Cart`) se suscriben a streams de Firestore en su constructor o mediante `init()`, y notifican cambios automáticamente cuando los datos cambian en la base de datos.

---

## 10. Servicios

### 10.1 FirestoreService (`lib/services/firestore_service.dart`)

381 líneas. CRUD completo para todas las colecciones.

**Métodos disponibles**:

| Categoría | Métodos |
|---|---|
| Destinos | `destinationsStream()`, `getDestinations()`, `getDestination(id)`, `destinationStream(id)`, `addDestination()`, `updateDestination()`, `deleteDestination()` (soft) |
| Tours | `toursStream()`, `toursByDestinationStream(id)`, `getTours()`, `getTour(id)`, `tourStream(id)`, `getToursByDestination(id)`, `addTour()`, `updateTour()`, `deleteTour()` (soft) |
| Reservas | `userReservationsStream(uid)`, `allReservationsStream()`, `getAllReservations()`, `getUserReservations()`, `addReservation()`, `updateReservation()`, `updateReservationStatus()` |
| Reseñas | `reviewsStream()`, `reviewsByTourStream(id)`, `getReviews()`, `getReviewsByTour(id)`, `addReview()`, `updateReview()` |
| Favoritos | `userFavoritesStream(uid)`, `getUserFavorites(uid)`, `isFavorite(uid, tourId)`, `addFavorite()`, `removeFavorite()` |
| Carrito | `userCartStream(uid)`, `getUserCart(uid)`, `addCartItem()`, `updateCartItemParticipants()`, `updateCartItem()`, `removeCartItem()`, `clearCart()` |
| Admin | `hardDelete(collection, docId)` (eliminación permanente) |
| Usuarios | `allUsersStream()`, `getAllUsers()`, `addUser()`, `updateUser()` |

### 10.2 AuthService (`lib/services/auth_service.dart`)

41 líneas. Wrapper sobre `FirebaseAuth` + `FirebaseFirestore`.
- `authStateChanges()` → stream de auth
- `currentUser` → usuario actual
- `fetchUserModel(uid)` → obtiene documento de Firestore
- `fetchUserByEmail(email)` → consulta por email
- `userStream(uid)` → stream en tiempo real del usuario
- `signOut()` → cierra sesión

### 10.3 AiChatService (`lib/services/ai_chat_service.dart`)

537 líneas. Sistema de chat con IA con dos modos:

**Modo Cloud Function** (principal):
- Hace POST a `https://us-central1-lifetours-452a8.cloudfunctions.net/chat`
- Envía JSON `{'message': texto}`
- Lee respuesta de los campos `reply`, `response` o `message`

**Modo fallback local** (cuando la Cloud Function no responde):
- Detecta saludos → respuesta amigable
- Detecta agradecimientos → respuesta cordial
- Detecta nombres de destinos (12 destinos con sinónimos) → información enriquecida (mejor época, gastronomía, tip, dato curioso)
- Detecta títulos de tours → responde con info del tour específico
- Base de conocimiento general con 16 temas: reservas, pagos, cancelaciones, registro, login, logout, reseñas, favoritos, búsqueda, carrito, idioma, tema, perfil, reservaciones, contacto, seguro, equipaje

---

## 11. Pantallas

### 11.1 LandingScreen (`/`)

Pantalla de bienvenida. Muestra:
- Título "Life Tours" con divisores decorativos
- Subtítulo: "Descubre experiencias diseñadas para ti"
- Botón "Crear Cuenta" → `/register`
- Botón "Iniciar Sesión" → `/login`
- Sin bottom nav bar

### 11.2 LoginScreen (`/login`)

Formulario de inicio de sesión:
- Campos: email, contraseña (con toggle de visibilidad)
- Botón "Iniciar Sesión" con indicador de carga
- Muestra errores de Firebase Auth traducidos al español
- Sin bottom nav bar

### 11.3 RegisterScreen (`/register`)

Formulario de registro:
- Campos: nombre, email, contraseña (mín. 6 caracteres)
- Validación de campos no vacíos
- Crea usuario en Firebase Auth + Firestore
- Sin bottom nav bar

### 11.4 DiscoverScreen (`/discover`)

Pantalla principal de descubrimiento (aprox. 678 líneas). Secciones:
- **Hero**: imagen full-width con gradiente, título, subtítulo, botón "Ver más" → `/catalog`
- **Categorías**: grilla 2×2 (Cultura, Agua, Al aire libre, Comida) → `/catalog`
- **Destinos**: desde `DestinationProvider`, tarjetas con imagen, nombre, ciudad, país → `/destination-detail`
- **Por qué elegirnos**: 3 tarjetas de beneficios (Viajes verificados, Soporte 24/7, Mejor precio)
- **Testimonios**: 3 tarjetas estáticas (María G., Carlos R., Ana L.)
- **Consejos de viaje**: 4 tips numerados
- **Footer**: contenedor oscuro con datos de contacto
- Bottom nav en índice 0

### 11.5 CatalogScreen (`/catalog`)

Catálogo completo de tours (aprox. 916 líneas):
- **Búsqueda**: TextField con filtro por título/destino
- **Filtro de precio**: `RangeSlider`
- **Vista**: alternar entre grilla 2 columnas y carrusel horizontal
- **"Recomendado para ti"**: tour aleatorio destacado → `/booking`
- **"Podría interesarte"**: lista de tours con `CachedNetworkImage`, título, destino, precio, chips de categoría
- **Destinos**: scroll horizontal de tarjetas de destino
- **Estadísticas**: 150+ Destinos, 12K Viajeros, 4.8 Calificación
- **Testimonios**: scroll horizontal
- **Tips**: 4 filas de consejos
- Bottom nav en índice 1

### 11.6 DestinationDetailScreen (`/destination-detail`)

Detalle de un destino:
- `SliverAppBar` (240px expandido, pinned) con imagen hero, botón atrás, icono de favorito
- Nombre, ciudad/país, descripción
- Chips de actividades
- Tours disponibles con imagen, título, duración, cupos, precio, toggle de favorito
- Carga datos desde `FirestoreService` directamente
- Bottom nav en índice 1

### 11.7 BookingScreen (`/booking`)

Reserva de un tour:
- Carga datos del tour por `tourId`
- Muestra imagen, título, destino, descripción, precio
- **Selector de fecha**: `showDatePicker`
- **Selector de participantes**: botones +/−
- Precio total calculado dinámicamente
- Botón "Agregar al carrito" → `CartProvider.addItem()` → `/cart`
- Bottom nav

### 11.8 CartScreen (`/cart`)

Carrito de compras:
- Lista de items con imagen, título, destino, participantes, fecha, precio
- Botón **Editar**: diálogo con selector de participantes y fecha
- Botón **Pagar**: navega a `/payment` con el item
- Botón **Eliminar**: elimina del carrito
- Botón **"Pagar todo"**: navega a `/payment` sin item (procesa todo)
- Total general calculado
- Bottom nav

### 11.9 PaymentScreen (`/payment`)

Formulario de pago simulado:
- Campos: nombre del titular, número de tarjeta (máx. 19), expiry (MM/AA), CVV (3-4)
- Validación de todos los campos
- Al pagar: crea reserva(s) vía `ReservationProvider`, elimina item(s) del carrito
- Muestra snackbar "Pago exitoso" y navega a `/my-reservations`
- Bottom nav

### 11.10 MyReservationsScreen (`/my-reservations`)

Historial de reservas:
- Agrupadas por: Próximos, Hoy, Ayer, Última semana, Último mes, Más antiguo
- Cada tarjeta muestra: imagen, título, destino, participantes, fecha, precio, estado (verde = confirmado, rojo = cancelado)
- Bottom nav

### 11.11 FavoritesDetailScreen (`/favorites-detail`)

Lista de favoritos:
- Tarjetas con imagen, título, destino, precio
- Botón corazón rojo para eliminar
- Bottom nav

### 11.12 ReviewScreen (`/review`)

Reseñas de tours:
- **Formulario de escritura**: selector de 5 estrellas, campo de comentario multilínea, botón "Publicar"
- **Resumen de calificaciones**: promedio numérico grande, estrellas, total de opiniones, gráfico de barras (4-5★ vs total)
- **Lista de reseñas**: desde `ReviewProvider`, cada una con nombre, estrellas, comentario, título del tour
- **Reseñas destacadas estáticas**: 3 mini-tarjetas (Promedio 4.8, 2.3K Reseñas, 98% Recomiendan)
- **Opiniones recientes estáticas**: 4 tarjetas con datos hardcodeados
- **Preguntas frecuentes**: 4 acordeones expandibles
- Bottom nav en índice 2

### 11.13 ProfileScreen (`/profile`)

Menú de cuenta:
- Tarjeta de usuario (avatar inicial, nombre, email)
- 7 opciones: Reservaciones, Perfil, Carrito, Información, Ayuda, Favoritos, Configuración
- Sección admin (visible solo si `isAdmin`): botón "Ver panel" → `/admin`
- Botón "Cerrar Sesión" rojo
- Bottom nav en índice 3

### 11.14 ProfileDetailScreen (`/profile-detail`)

Datos del perfil (solo lectura):
- Avatar (primera letra del nombre), nombre, email
- Teléfono ("No registrado" si es null)
- "Miembro desde" con fecha formateada

### 11.15 AdminPanelScreen (`/admin`)

Panel de administración:
- Verifica si el usuario es admin; si no, muestra "Acceso restringido"
- Si es admin: "Bienvenido administrador", 5 tablas listadas:
  - Usuarios, Destinos, Tours, Reservas, Reseñas → todas a `/admin/:collection`
- Bottom nav en índice 3

### 11.16 TableManagementScreen (`/admin/:collection`)

CRUD genérico para cualquier colección:
- Carga datos según el nombre de colección
- Cada registro se muestra como tarjeta con título/subtítulo
- Botones **Editar** (abre formulario en modo edición) y **Eliminar** (confirmación → hard delete)
- **FAB** "Agregar" (abre formulario en modo creación)
- Formulario dinámico con campos según la colección, pickers de referencias, validación
- Bottom nav en índice 3

### 11.17 InfoScreen (`/info`)

Información de la aplicación:
- "Sobre Life Tours": descripción + versión 1.0.0
- "Contacto": email y teléfono

### 11.18 SettingsScreen (`/settings`)

Configuración:
- Toggle "Modo oscuro" → cambia entre tema claro/oscuro
- Toggle "Idioma" → alterna entre Español/English

### 11.19 ChatScreen (`/chat`)

Asistente virtual:
- AppBar con "Asistente LifeTours" y estado "En línea"
- Burbujas de chat: usuario a la derecha (fondo oscuro), bot a la izquierda (con avatar robot)
- Campo de texto con botón de envío
- Auto-scroll a la últimos mensajes
- Indicador de carga mientras el asistente responde
- El asistente tiene conocimiento de destinos, tours y funciones de la app

---

## 12. Internacionalización (i18n)

Archivo: `lib/i18n/translations.dart`

**AppTranslations** es una clase con un método estático:
```dart
static String t(String text, String lang)
```

- Si `lang == 'es'`, devuelve el texto original en español (patrón key-as-value).
- Si `lang == 'en'`, busca en un mapa `_en` con ~180 traducciones.
- Si no encuentra traducción, devuelve el texto español como fallback.

El `SettingsProvider` expone `locale` (Locale) que se usa en toda la app para pasar el código de idioma a `AppTranslations.t()`.

---

## 13. Tema y Estilos

### AppColors

Paleta de colores definida en `lib/theme.dart` con modo claro y oscuro:

| Color | Claro | Oscuro |
|---|---|---|
| `background` | `#E8EDF2` | `#121212` |
| `surface` | `#FFFFFF` | `#1E1E2E` |
| `primary` | `#2C3947` (navy) | `#FFFFFF` |
| `accent` | `#4B5563` (gris) | `#FFFFFF` |
| `greenAccent` | `#81C784` (verde) | `#A5D6A7` |

**ThemeAccent extension**: provee getters `primary`, `accent`, `surface`, `background` en `BuildContext` que retornan el color correspondiente según el brightness actual.

### Tipografía

`GoogleFonts.poppinsTextTheme()` con las siguientes variantes:

| Estilo | Tamaño | Peso |
|---|---|---|
| `headlineLarge` | 28px | w600 |
| `headlineMedium` | 22px | w600 |
| `headlineSmall` | 20px | w600 |
| `titleLarge` | 18px | w600 |
| `titleMedium` | 16px | w500 |
| `titleSmall` | 14px | w500 |
| `bodyLarge` | 16px | normal |
| `bodyMedium` | 14px | normal, height 1.5 |
| `bodySmall` | 12px | normal |
| `labelLarge` | 14px | w600 |
| `labelSmall` | 11px | w500 |

### Temas

- **buildLightTheme()**: `ThemeData` con Material 3, botones redondeados (12px), inputs con borde primario y foco verde.
- **buildDarkTheme()**: misma estructura con colores oscuros.

Seleccionados mediante `settings.themeMode` en `MaterialApp.router`.

---

## 14. Flujo de Pago y Reserva

```
BookingScreen
  → usuario selecciona fecha y participantes
    → "Agregar al carrito"
      → CartProvider.addItem() (guarda en subcolección `users/{uid}/cart/{tourId}`)
        → navega a CartScreen

CartScreen
  → usuario puede editar participantes/fecha, eliminar items
    → "Pagar" (item individual) o "Pagar todo"
      → navega a PaymentScreen

PaymentScreen
  → formulario de tarjeta de crédito (simulado, sin procesador real)
    → validación de campos
      → _pay():
        → crea ReservationModel en Firestore via ReservationProvider.createReservation()
        → elimina item(s) del carrito via CartProvider.removeItem() / clear()
        → snackbar "Pago exitoso"
        → navega a /my-reservations
```

---

## 15. Chat Asistente IA

### Cómo usarlo

1. Navegar a `/chat` desde el perfil (opción "Ayuda") o directamente.
2. Escribir un mensaje en el campo de texto.
3. El asistente responde con información sobre destinos, tours o funciones de la app.

### Capacidades del asistente local

- **Saludos**: "¡Hola! Soy el asistente de LifeTours..."
- **Destinos**: reconoce 12 destinos (París, Barcelona, Roma, Tokio, Nueva York, Londres, Sídney, Cancún, Bangkok, Dubái, Cusco, Marrakech) y proporciona: mejor época para visitar, gastronomía típica, tip de viaje, dato curioso.
- **Tours**: si mencionas un título de tour existente, responde con su información.
- **Conocimiento general**: sabe sobre funciones de la app (cómo reservar, pagar, cancelar, registrarse, iniciar sesión, escribir reseñas, favoritos, búsqueda, carrito, cambio de idioma/tema, perfil, contacto, seguro, equipaje).

### Cloud Function

Si está desplegada, hace una petición HTTP POST a `https://us-central1-lifetours-452a8.cloudfunctions.net/chat`. Si falla, usa el sistema de respuestas locales.

---

## 16. Panel de Administración

### Acceso

Solo usuarios con `role: 'admin'` en Firestore (`users/{uid}`).

**Credenciales de admin**:
- Email: `admin@lifetours.com`
- Contraseña: `Admin123!`

### Funcionalidades

1. **Usuarios**: ver, crear, editar y eliminar usuarios.
2. **Destinos**: gestionar destinos (activar/desactivar, editar información).
3. **Tours**: crear y modificar tours, asignar categorías y destinos.
4. **Reservas**: ver todas las reservas de todos los usuarios, cambiar estado.
5. **Reseñas**: gestionar reseñas de usuarios.

### CRUD genérico (`TableManagementScreen`)

El formulario de agregar/editar es dinámico según la colección:
- **Destinos**: nombre, país, ciudad, descripción, URL de imagen, actividades (separadas por comas)
- **Tours**: título, descripción, precio, imagen, destino (selector), categorías, duración, capacidad
- **Usuarios**: nombre, email, rol, teléfono, URL de foto
- **Reservas**: usuario (selector), tour (selector), fecha, participantes, estado
- **Reseñas**: usuario (selector), tour (selector), calificación (1-5), comentario

---

## 17. Comandos Útiles

```bash
# Ejecutar la app
flutter run

# Ejecutar en web
flutter run -d chrome

# Construir para web
flutter build web

# Ejecutar tests
flutter test

# Analizar código (linter)
flutter analyze

# Obtener dependencias
flutter pub get

# Limpiar build
flutter clean

# Desplegar a Firebase Hosting
firebase deploy --only hosting
```

---

## 18. Credenciales de Prueba

| Rol | Email | Contraseña | UID |
|---|---|---|---|
| Admin | `admin@lifetours.com` | `Admin123!` | `admin001` |
| Usuario | `maria@example.com` | `Test123!` | `user001` |

Ambos usuarios existen en Firebase Auth (email verificado) y Firestore.

---

## 19. Despliegue Web

### Requisitos

- Firebase CLI instalado y autenticado (`firebase login`)
- Proyecto asociado vía `.firebaserc` (ya configurado para `lifetours-452a8`)

### Pasos

```bash
# 1. Construir la app web
flutter build web

# 2. Desplegar a Firebase Hosting
firebase deploy --only hosting
```

### URL

La app web está disponible en:  
**https://lifetours-452a8.web.app**

### Configuración de Hosting (`firebase.json`)

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

El rewrite a `/index.html` es necesario para que GoRouter funcione correctamente en SPA, permitiendo que rutas como `/discover`, `/profile`, etc. sean manejadas por el router de Flutter en lugar de devolver 404.

---

## Notas Adicionales

- Las imágenes en la app usan URLs externas (Unsplash, Picsum) — los directorios `assets/images/` y `assets/icons/` están declarados pero vacíos.
- No hay sistema de pagos real — el flujo de pago es una simulación educativa.
- El chat usa una Cloud Function como respaldo; si no está disponible, usa respuestas predefinidas locales.
- Los datos de Firestore incluyen seed data: 5 destinos, 11 tours, 3 reservas, 3 reseñas, 2 favoritos.
