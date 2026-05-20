# LifeTours — Esquema Firestore

> Documentación de las colecciones de Cloud Firestore para el proyecto LifeTours.

---

## Colecciones

### `users/{uid}`
Creado automáticamente al registrar un usuario con Firebase Auth.

| Campo       | Tipo       | Descripción                        |
|-------------|------------|------------------------------------|
| `name`      | `String`   | Nombre completo                    |
| `email`     | `String`   | Correo electrónico                 |
| `role`      | `String`   | `"user"` o `"admin"`               |
| `photoUrl`  | `String?`  | URL de foto de perfil              |
| `phone`     | `String?`  | Teléfono opcional                  |
| `createdAt` | `Timestamp`| Fecha de registro                  |

#### Subcolección: `users/{uid}/favorites/{tourId}`
| Campo             | Tipo        | Descripción                     |
|-------------------|-------------|---------------------------------|
| `tourId`          | `String`    | ID del tour (= ID del documento)|
| `tourTitle`       | `String`    | Título (desnormalizado)         |
| `tourImageUrl`    | `String`    | Imagen (desnormalizado)         |
| `destinationName` | `String`    | Destino (desnormalizado)        |
| `price`           | `double`    | Precio (desnormalizado)         |
| `savedAt`         | `Timestamp` | Fecha en que se guardó          |

---

### `destinations/{destinationId}`

| Campo         | Tipo           | Descripción                              |
|---------------|----------------|------------------------------------------|
| `name`        | `String`       | Nombre (ej. "Barcelona")                 |
| `country`     | `String`       | País (ej. "España")                      |
| `city`        | `String`       | Ciudad                                   |
| `description` | `String`       | Descripción larga                        |
| `imageUrl`    | `String`       | URL de imagen principal                  |
| `activities`  | `List<String>` | Tags de actividades (ej. ["Museos"])     |
| `isActive`    | `bool`         | Visible en la app                        |
| `createdAt`   | `Timestamp`    | Fecha de creación                        |

---

### `tours/{tourId}`

| Campo             | Tipo           | Descripción                                  |
|-------------------|----------------|----------------------------------------------|
| `title`           | `String`       | Nombre del tour                              |
| `description`     | `String`       | Descripción completa                         |
| `price`           | `double`       | Precio por persona (MXN)                     |
| `imageUrl`        | `String`       | URL de imagen principal                      |
| `destinationId`   | `String`       | Ref. a `destinations/{id}`                   |
| `destinationName` | `String`       | Nombre destino (desnormalizado)              |
| `categories`      | `List<String>` | Categorías del enum `TourCategory`           |
| `durationDays`    | `int`          | Duración en días                             |
| `capacity`        | `int`          | Cupos totales                                |
| `availableSpots`  | `int`          | Cupos disponibles                            |
| `averageRating`   | `double`       | Promedio calculado (0.0–5.0)                 |
| `reviewCount`     | `int`          | Número total de reseñas                      |
| `isActive`        | `bool`         | Visible en la app                            |
| `createdAt`       | `Timestamp`    | Fecha de creación                            |

---

### `reservations/{reservationId}`

| Campo             | Tipo        | Descripción                                   |
|-------------------|-------------|-----------------------------------------------|
| `userId`          | `String`    | Ref. a `users/{uid}`                          |
| `userName`        | `String`    | Nombre usuario (desnormalizado)               |
| `tourId`          | `String`    | Ref. a `tours/{id}`                           |
| `tourTitle`       | `String`    | Título tour (desnormalizado)                  |
| `tourImageUrl`    | `String`    | Imagen tour (desnormalizado)                  |
| `destinationName` | `String`    | Destino (desnormalizado)                      |
| `pricePerPerson`  | `double`    | Precio por persona al momento de reservar     |
| `participants`    | `int`       | Número de participantes                       |
| `totalPrice`      | `double`    | `pricePerPerson × participants`               |
| `travelDate`      | `Timestamp` | Fecha de viaje deseada                        |
| `status`          | `String`    | `pending` / `confirmed` / `cancelled` / `completed` |
| `notes`           | `String?`   | Notas adicionales del usuario                 |
| `createdAt`       | `Timestamp` | Fecha de creación de la reserva               |

---

### `reviews/{reviewId}`

| Campo          | Tipo        | Descripción                               |
|----------------|-------------|-------------------------------------------|
| `userId`       | `String`    | Ref. a `users/{uid}`                      |
| `userName`     | `String`    | Nombre (desnormalizado)                   |
| `userPhotoUrl` | `String?`   | Foto perfil (desnormalizado)              |
| `tourId`       | `String`    | Ref. a `tours/{id}`                       |
| `tourTitle`    | `String`    | Título tour (desnormalizado)              |
| `rating`       | `int`       | Calificación del 1 al 5                   |
| `comment`      | `String`    | Texto de la opinión                       |
| `createdAt`    | `Timestamp` | Fecha de publicación                      |

> ⚠️ Al crear/eliminar una reseña, actualizar `tours/{tourId}.averageRating`
> y `reviewCount` con una **Cloud Function** o **transacción Firestore**.

---

## Reglas de Seguridad sugeridas (Firestore Rules)

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helpers
    function isAuth()  { return request.auth != null; }
    function isAdmin() { return isAuth() && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin'; }
    function isOwner(uid) { return isAuth() && request.auth.uid == uid; }

    // Users
    match /users/{uid} {
      allow read:   if isOwner(uid) || isAdmin();
      allow create: if isOwner(uid);
      allow update: if isOwner(uid) || isAdmin();
      allow delete: if isAdmin();

      match /favorites/{tourId} {
        allow read, write: if isOwner(uid);
      }
    }

    // Destinations — solo admins modifican
    match /destinations/{id} {
      allow read:  if isAuth();
      allow write: if isAdmin();
    }

    // Tours — solo admins modifican
    match /tours/{id} {
      allow read:  if isAuth();
      allow write: if isAdmin();
    }

    // Reservations — usuario crea las suyas, admin gestiona todas
    match /reservations/{id} {
      allow read:   if isAuth() && (resource.data.userId == request.auth.uid || isAdmin());
      allow create: if isAuth() && request.resource.data.userId == request.auth.uid;
      allow update: if isAdmin();
      allow delete: if isAdmin();
    }

    // Reviews — usuario crea/edita las suyas, todos pueden leer
    match /reviews/{id} {
      allow read:   if isAuth();
      allow create: if isAuth() && request.resource.data.userId == request.auth.uid;
      allow update: if isAuth() && resource.data.userId == request.auth.uid;
      allow delete: if isAdmin();
    }
  }
}
```

---

## Diagrama de relaciones

```
users ──────────────────────────────────────────────────────────────────
  │                                                                      │
  ├── /favorites/{tourId}  ──────────────────────────────► tours         │
  │                                                          │           │
  └──────────────────────────────────────────────────────── │           │
                                                             │           │
reservations ────────────────────────────── userId ─────────┤           │
     │                                                       │           │
     └──────────── tourId ──────────────────────────────────┘           │
                                                                         │
reviews ─────────────────────────────────── userId ────────────────────┘
     │
     └──────────── tourId ──────────────────────────────────► tours

destinations ◄─────────────────────────────────────────────── tours
                                             destinationId
```
