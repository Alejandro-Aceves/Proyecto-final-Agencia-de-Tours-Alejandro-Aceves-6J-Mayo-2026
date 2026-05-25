class AppTranslations {
  AppTranslations._();

  static String t(String text, String lang) {
    if (lang == 'es') return text;
    return _en[text] ?? text;
  }

  static const Map<String, String> _en = {
    // ── Landing ──
    'Life Tours': 'Life Tours',
    'Descubre experiencias\ndiseñadas para ti': 'Discover experiences\ndesigned for you',
    'Crear Cuenta': 'Create Account',
    'Iniciar Sesion': 'Sign In',

    // ── Login ──
    'Completa todos los campos': 'Complete all fields',
    'Hola de nuevo': 'Hello again',
    'Inicia Sesion de Nuevo': 'Sign In Again',
    'Correo Electronico': 'Email',
    'Contrasena': 'Password',

    // ── Register ──
    'La contraseña debe tener al menos 6 caracteres':
        'Password must be at least 6 characters',
    'Bienvenido': 'Welcome',
    'Listo para crear tu cuenta': 'Ready to create your account',
    'Nombre': 'Name',

    // ── Discover ──
    '¿Estas Aburrido?': 'Are you bored?',
    'Encuentra esto y mas': 'Find this and more',
    'Cultura': 'Culture',
    'Agua': 'Water',
    'Al aire libre': 'Outdoors',
    'Comida': 'Food',
    'Comprueba nuestra variedad de actividades':
        'Check out our variety of activities',
    'Ver mas': 'See more',
    'Destinos': 'Destinations',
    'No hay destinos disponibles': 'No destinations available',
    'Por que elegirnos': 'Why choose us',
    'Viajes verificados': 'Verified trips',
    'Todos nuestros tours son revisados y aprobados por nuestro equipo de expertos locales.':
        'All our tours are reviewed and approved by our team of local experts.',
    'Soporte 24/7': '24/7 Support',
    'Estamos disponibles en todo momento para ayudarte durante tu viaje.':
        'We are available at all times to help you during your trip.',
    'Mejor precio garantizado': 'Best price guaranteed',
    'Te ofrecemos los mejores precios del mercado con cancelacion flexible.':
        'We offer the best prices on the market with flexible cancellation.',
    'Testimonios': 'Testimonials',
    'Maria G.': 'Maria G.',
    'España': 'Spain',
    'Una experiencia inolvidable. El tour por Barcelona supero todas mis expectativas. Guias muy capacitados y atentos.':
        'An unforgettable experience. The Barcelona tour exceeded all my expectations. Very skilled and attentive guides.',
    'Carlos R.': 'Carlos R.',
    'Mexico': 'Mexico',
    'Viaje a Paris con mi familia y todo estuvo perfectamente organizado. Sin duda repetire con LifeTours.':
        'I traveled to Paris with my family and everything was perfectly organized. I will definitely repeat with LifeTours.',
    'Ana L.': 'Ana L.',
    'Argentina': 'Argentina',
    'Los mejores destinos y precios. La atencion al cliente es excepcional, me ayudaron con cada detalle.':
        'The best destinations and prices. The customer service is exceptional, they helped me with every detail.',
    'Consejos de viaje': 'Travel tips',
    'Planifica con anticipacion': 'Plan ahead',
    'Reserva tus tours con al menos dos semanas de anticipacion para asegurar disponibilidad y mejores precios.':
        'Book your tours at least two weeks in advance to ensure availability and best prices.',
    'Empaca ligero': 'Pack light',
    'Lleva solo lo esencial. La mayoria de nuestros tours incluyen transporte y alimentacion.':
        'Bring only the essentials. Most of our tours include transportation and meals.',
    'Revisa el clima': 'Check the weather',
    'Consulta el pronostico del tiempo antes de tu viaje para elegir la mejor fecha y preparar tu equipaje.':
        'Check the weather forecast before your trip to choose the best date and pack accordingly.',
    'Lee las opiniones': 'Read reviews',
    'Revisa los comentarios de otros viajeros para elegir el tour que mejor se adapte a ti.':
        'Check other travelers comments to choose the tour that best suits you.',
    'Tu puerta al mundo': 'Your gateway to the world',
    'contacto@lifetours.com': 'contacto@lifetours.com',
    '+52 55 1234 5678': '+52 55 1234 5678',
    '© 2026 LifeTours. Todos los derechos reservados.':
        '© 2026 LifeTours. All rights reserved.',

    // ── Catalog ──
    'Tours': 'Tours',
    'Reserva cosas que hacer\naprobadas por nosotros':
        'Book things to do\napproved by us',
    'Busca por destino': 'Search by destination',
    'Filtrar por precio': 'Filter by price',
    'Vista carrusel': 'Carousel view',
    'Vista cuadrícula': 'Grid view',
    'Podria interesarte': 'You might like',
    'No hay tours disponibles': 'No tours available',
    'Recomendado para ti': 'Recommended for you',

    // ── Destination Detail ──
    'Destino no encontrado': 'Destination not found',
    'Detalles': 'Details',
    'Actividades': 'Activities',
    'Tours disponibles': 'Available tours',
    'día(s)': 'day(s)',
    'lugares': 'spots',

    // ── Booking ──
    'Selecciona una fecha para el tour': 'Select a date for the tour',
    'agregado al carrito': 'added to cart',
    'Reservar': 'Book',
    'Tour no encontrado': 'Tour not found',
    'Personas': 'People',
    'Precio por persona': 'Price per person',
    'Total': 'Total',
    'Seleccionar fecha del tour': 'Select tour date',
    'Fecha:': 'Date:',
    'Agregar al carrito': 'Add to cart',

    // ── Cart ──
    'Editar personas': 'Edit people',
    'Editar reservación': 'Edit reservation',
    'Seleccionar fecha': 'Select date',
    'Cancelar': 'Cancel',
    'Guardar': 'Save',
    'Carrito': 'Cart',
    'Tu carrito está vacío': 'Your cart is empty',
    'Pagar todo': 'Pay all',
    'Editar': 'Edit',
    'Pagar': 'Pay',

    // ── Payment ──
    'Debes iniciar sesión para pagar': 'You must sign in to pay',
    'Pago exitoso: ': 'Payment successful: ',
    'Pago exitoso': 'Payment successful',
    'Pago': 'Payment',
    'Metodo de pago': 'Payment method',
    'Tarjeta de credito o debito': 'Credit or debit card',
    'Tarjeta': 'Card',
    'Titular de la tarjeta': 'Cardholder',
    'Nombre completo': 'Full name',
    'Ingrese el nombre del titular': 'Enter cardholder name',
    'Numero de tarjeta': 'Card number',
    '1234 5678 9012 3456': '1234 5678 9012 3456',
    'Ingrese el numero de tarjeta': 'Enter card number',
    'Numero invalido': 'Invalid number',
    'Vencimiento': 'Expiry',
    'MM/AA': 'MM/YY',
    'Requerido': 'Required',
    'Fecha invalida': 'Invalid date',
    'CVV': 'CVV',
    '123': '123',
    'CVV invalido': 'Invalid CVV',

    // ── Review ──
    'Escribe un comentario': 'Write a comment',
    'Debes iniciar sesión': 'You must sign in',
    'Opinión publicada': 'Review published',
    'Escribir opinion': 'Write review',
    'Calificación': 'Rating',
    'Tu opinión': 'Your opinion',
    'Comparte tu experiencia...': 'Share your experience...',
    'Publicar': 'Post',
    'Escribir una opinion': 'Write a review',
    'Comentanos': 'Tell us',
    'Queremos que escribas una opinion sobre nosotros':
        'We want you to write a review about us',

    // ── Profile ──
    'Configuración': 'Settings',
    'Modo oscuro': 'Dark mode',
    'Idioma': 'Language',
    'Español': 'Spanish',
    'Inglés': 'English',
    'Cuenta': 'Account',
    'Reservaciones': 'Reservations',
    'Perfil': 'Profile',
    'Informacion': 'Info',
    'Favoritos': 'Favorites',
    'Cerrar Sesion': 'Sign Out',
    'Inicia sesión para ver tu perfil': 'Sign in to view your profile',
    'Accede al panel de administracion': 'Access the admin panel',
    'Ver panel': 'View panel',
    'Ayuda': 'Help',

    // ── Profile Detail ──
    'Correo': 'Email',
    'Telefono': 'Phone',
    'No registrado': 'Not registered',
    'Miembro desde': 'Member since',
    'Mi Perfil': 'My Profile',

    // ── My Reservations ──
    'Próximos': 'Upcoming',
    'Hoy': 'Today',
    'Ayer': 'Yesterday',
    'Última semana': 'Last week',
    'Último mes': 'Last month',
    'Más antiguo': 'Older',
    'Mis Reservas': 'My Reservations',
    'No tienes reservas': 'You have no reservations',
    'persona(s)': 'person(s)',

    // ── Favorites ──
    'No tienes favoritos': 'You have no favorites',

    // ── Info ──
    'Sobre Life Tours': 'About Life Tours',
    'Life Tours es una plataforma de reserva de viajes y experiencias diseñada para ayudarte a descubrir los mejores destinos alrededor del mundo.':
        'Life Tours is a travel and experience booking platform designed to help you discover the best destinations around the world.',
    'Version 1.0.0': 'Version 1.0.0',
    'Contacto': 'Contact',
    'Correo: soporte@lifetours.com': 'Email: soporte@lifetours.com',
    'Telefono: +52 55 9876 5432': 'Phone: +52 55 9876 5432',

    // ── Admin Panel ──
    'Acceso restringido': 'Restricted access',
    'Volver': 'Go back',
    'Bienvenido administrador': 'Welcome admin',
    'Tablas': 'Tables',
    'Usuarios': 'Users',
    'Reservas': 'Reservations',
    'Resenas': 'Reviews',
    'Ver': 'View',

    // ── Table Management ──
    'Error al cargar datos.': 'Error loading data.',
    'Confirmar eliminacion': 'Confirm deletion',
    '¿Estas seguro de eliminar este registro?':
        'Are you sure you want to delete this record?',
    'Eliminar': 'Delete',
    'Registro eliminado correctamente': 'Record deleted successfully',
    'Error al eliminar: ': 'Error deleting: ',
    'No hay datos': 'No data',
    'Agregar': 'Add',
    'Admin': 'Admin',
    'Usuario': 'User',
    'Registro actualizado correctamente': 'Record updated successfully',
    'Registro agregado correctamente': 'Record added successfully',
    'Destino': 'Destination',
    'Tour': 'Tour',
    'Reserva': 'Reservation',
    'Resena': 'Review',
    'Seleccionar...': 'Select...',
    'No hay datos disponibles': 'No data available',
    'Ciudad': 'City',
    'Pais': 'Country',
    'Descripcion': 'Description',
    'URL de imagen': 'Image URL',
    'Activo': 'Active',
    'Titulo': 'Title',
    'Precio': 'Price',
    'Duracion (dias)': 'Duration (days)',
    'Capacidad': 'Capacity',
    'Lugares disponibles': 'Available spots',
    'Categorias': 'Categories',
    'Participantes': 'Participants',
    'Precio total': 'Total price',
    'Fecha de viaje': 'Travel date',
    'Estado': 'Status',
    'Notas': 'Notes',
    'Calificacion': 'Rating',
    'Comentario': 'Comment',
    'Administrador': 'Administrator',
    'Correo electronico': 'Email',
  };
}
