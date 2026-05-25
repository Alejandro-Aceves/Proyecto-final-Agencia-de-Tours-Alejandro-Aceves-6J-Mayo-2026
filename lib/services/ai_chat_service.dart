import 'dart:convert';
import 'dart:io';

import 'package:lifetours/models/models.dart';

class AiChatService {
  static const String _functionUrl =
      'https://us-central1-lifetours-452a8.cloudfunctions.net/chat';

  static Future<String> sendMessage(
    String message, {
    List<DestinationModel>? destinations,
    List<TourModel>? tours,
  }) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final request = await client.postUrl(Uri.parse(_functionUrl));
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode({'message': message}));
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body) as Map<String, dynamic>;
        return data['reply'] as String? ??
            data['response'] as String? ??
            data['message'] as String? ??
            _localReply(message, destinations, tours);
      }
    } catch (_) {}
    return _localReply(message, destinations, tours);
  }

  static String _localReply(
    String message,
    List<DestinationModel>? destinations,
    List<TourModel>? tours,
  ) {
    final msg = message.toLowerCase().trim();

    if (_isGreeting(msg)) return _greeting();
    if (_isThanks(msg)) return _thanks();

    final destReply = _tryDestinationReply(msg, destinations, tours);
    if (destReply != null) return destReply;

    final tourReply = _tryTourReply(msg, tours);
    if (tourReply != null) return tourReply;

    for (final entry in _generalDb) {
      if (entry.keywords.any((kw) => msg.contains(kw))) {
        return entry.response;
      }
    }

    return _defaultReply(destinations);
  }

  // ── Detección ─────────────────────────────────────────────────────────────────

  static bool _isGreeting(String msg) {
    return ['hola', 'buenas', 'buenos', 'hello', 'hey', 'saludos', 'que tal', 'qué tal']
        .any((w) => msg.contains(w));
  }

  static bool _isThanks(String msg) {
    return ['gracias', 'thanks', 'thank', 'muchas gracias']
        .any((w) => msg.contains(w));
  }

  static final Map<String, List<String>> _destAliases = {
    'paris': ['parís', 'paris', 'torre eiffel', 'louvre', 'sena'],
    'barcelona': ['barcelona', 'gaudi', 'sagrada familia', 'playa barcelona'],
    'roma': ['roma', 'roma', 'coliseo', 'vaticano', 'fontana di trevi'],
    'tokio': ['tokio', 'tokyo', 'japón', 'japon', 'shibuya', 'akihabara'],
    'nueva_york': ['nueva york', 'new york', 'nyc', 'manhattan', 'times square', 'central park'],
    'londres': ['londres', 'london', 'big ben', 'london eye'],
    'sidney': ['sídney', 'sidney', 'sydney', 'australia', 'opera sidney'],
    'cancun': ['cancún', 'cancun', 'mexico', 'caribe', 'chichen itza', 'chichén itzá'],
    'bangkok': ['bangkok', 'tailandia', 'templos tailandia'],
    'dubai': ['dubái', 'dubai', 'emiratos', 'burj khalifa'],
    'cusco': ['cusco', 'cuzco', 'machu picchu', 'perú', 'peru', 'valle sagrado', 'montaña 7 colores'],
    'marrakech': ['marrakech', 'marrakesh', 'marruecos', 'sahara'],
  };

  // ── Destinos ──────────────────────────────────────────────────────────────────

  static String? _tryDestinationReply(
    String msg,
    List<DestinationModel>? destinations,
    List<TourModel>? tours,
  ) {
    String? matchedDestId;
    for (final entry in _destAliases.entries) {
      if (entry.value.any((alias) => msg.contains(alias))) {
        matchedDestId = entry.key;
        break;
      }
    }
    if (matchedDestId == null) return null;

    final dest = destinations?.where((d) => d.id == matchedDestId).firstOrNull;

    if (dest == null) {
      return _enrichmentFallback(matchedDestId);
    }

    final destTours = tours
            ?.where((t) => t.destinationId == matchedDestId && t.isActive)
            .toList() ??
        [];

    return _buildDestReply(dest, destTours);
  }

  static String _buildDestReply(DestinationModel dest, List<TourModel> tours) {
    final enrich = _enrichment[dest.id];
    final buf = StringBuffer()
      ..writeln('**${dest.name}**, ${dest.country}')
      ..writeln()
      ..writeln(dest.description)
      ..writeln();

    if (dest.activities.isNotEmpty) {
      buf.writeln('*Actividades destacadas:* ${dest.activities.join(", ")}');
    }

    if (enrich != null) {
      buf.writeln();
      if (enrich.bestTime != null) buf.writeln('📅 *Mejor época:* ${enrich.bestTime}');
      if (enrich.cuisine != null) buf.writeln('🍽️ *Gastronomía:* ${enrich.cuisine}');
      if (enrich.tip != null) buf.writeln('💡 *Tip:* ${enrich.tip}');
      if (enrich.funFact != null) buf.writeln('✨ *Dato curioso:* ${enrich.funFact}');
    }

    if (tours.isNotEmpty) {
      buf.writeln();
      buf.writeln('*Tours disponibles:*');
      for (final t in tours) {
        final stars = '⭐' * t.averageRating.round();
        buf.writeln('  • *${t.title}* — \$${t.price.toStringAsFixed(0)} $stars (${t.averageRating})');
        buf.writeln('    ${t.description}');
      }
    }

    buf.writeln();
    buf.writeln('¿Te gustaría saber más sobre algún tour en específico o te ayudo con la reserva?');
    return buf.toString();
  }

  static String _enrichmentFallback(String destId) {
    final name = _destAliases[destId]?.first ??
        destId.replaceAll('_', ' ').split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
    return 'Actualmente **$name** no está disponible en nuestro catálogo, pero estamos trabajando para incluir nuevos destinos pronto. Mientras tanto, ¿te gustaría explorar nuestros destinos disponibles desde la sección "Catálogo"? Puedo ayudarte con información sobre los que ya tenemos.';
  }

  // ── Tours ─────────────────────────────────────────────────────────────────────

  static String? _tryTourReply(String msg, List<TourModel>? tours) {
    if (tours == null || tours.isEmpty) return null;
    final tourNames = tours.map((t) => t.title.toLowerCase()).toSet();
    final matched = tourNames.where((n) => msg.contains(n)).firstOrNull;
    if (matched == null) return null;
    final tour = tours.firstWhere((t) => t.title.toLowerCase() == matched);
    final stars = '⭐' * tour.averageRating.round();
    return '**${tour.title}**\n\n'
        '${tour.description}\n\n'
        '📍 *Destino:* ${tour.destinationName}\n'
        '💰 *Precio:* \$${tour.price.toStringAsFixed(0)} por persona\n'
        '📅 *Duración:* ${tour.durationDays} día${tour.durationDays > 1 ? 's' : ''}\n'
        '⭐ *Calificación:* ${tour.averageRating} $stars (${tour.reviewCount} reseñas)\n'
        '🎫 *Cupos disponibles:* ${tour.availableSpots}\n\n'
        '¿Te gustaría reservar este tour? Puedo guiarte en el proceso.';
  }

  // ── Respuestas generales ──────────────────────────────────────────────────────

  static final List<_MockEntry> _generalDb = [
    _MockEntry(
      keywords: [
        'como reservar', 'cómo reservar', 'como reservo', 'cómo reservo',
        'reservar un tour', 'reservar tour', 'hacer una reserva',
        'como apartar', 'cómo apartar', 'reserva', 'booking', 'agendar',
      ],
      response:
          'Para **reservar un tour** sigue estos pasos:\n\n'
          '1. Ve a la pantalla **"Descubrir"** o **"Catálogo"** desde el menú inferior.\n'
          '2. Explora los destinos o usa el buscador para encontrar el tour que te interese.\n'
          '3. Toca la tarjeta del tour para ver los detalles completos.\n'
          '4. Presiona el botón **"Reservar"**.\n'
          '5. Selecciona la **fecha** y la **cantidad de personas**.\n'
          '6. Revisa el resumen y presiona **"Ir a pagar"**.\n'
          '7. Elige tu método de pago y completa la transacción.\n\n'
          'Recibirás una confirmación por correo electrónico y la reserva aparecerá en **"Mis Reservaciones"** dentro de tu perfil. ¿Tienes alguna otra duda?',
    ),
    _MockEntry(
      keywords: [
        'como pagar', 'cómo pagar', 'como pago', 'cómo pago',
        'metodo de pago', 'método de pago', 'formas de pago',
        'pago', 'tarjeta', 'tarjeta de credito', 'pagar', 'factura',
        'como facturar', 'cómo facturar',
      ],
      response:
          'Para **realizar el pago** de un tour:\n\n'
          '1. Después de seleccionar fecha y personas en la pantalla de reserva, presiona **"Ir a pagar"**.\n'
          '2. Se abrirá la pantalla de pago con el resumen de tu compra.\n'
          '3. Selecciona tu método de pago:\n'
          '   • **Tarjeta de crédito o débito** (Visa, MasterCard, American Express)\n'
          '   • **PayPal**\n'
          '4. Ingresa los datos solicitados y presiona **"Pagar"**.\n'
          '5. ¡Listo! Recibirás un comprobante digital y un correo de confirmación.\n\n'
          'Todos los pagos se procesan de forma segura. Si necesitas una **factura fiscal**, puedes solicitarla desde la sección **"Perfil"** > **"Mis Reservaciones"** seleccionando la reserva y presionando "Facturar". ¿Necesitas ayuda con algo más?',
    ),
    _MockEntry(
      keywords: [
        'cancelar reserva', 'cancelar', 'cancelación', 'cancelacion',
        'reembolso', 'como cancelar', 'cómo cancelar', 'cancelar viaje',
      ],
      response:
          'Para **cancelar una reserva**:\n\n'
          '1. Ve a tu **Perfil** desde el menú inferior (ícono de persona).\n'
          '2. Presiona **"Reservaciones"** en la lista de opciones.\n'
          '3. Busca la reserva que deseas cancelar y tócala.\n'
          '4. Presiona el botón **"Cancelar reserva"**.\n\n'
          '*Política de cancelación:*\n'
          '• **Más de 48 horas** antes del tour → Reembolso completo.\n'
          '• **Entre 24 y 48 horas** → Cargo del 50%.\n'
          '• **Menos de 24 horas** → No aplica reembolso.\n\n'
          'El reembolso se procesará al mismo método de pago en un plazo de 5 a 10 días hábiles. ¿Necesitas ayuda con algo más?',
    ),
    _MockEntry(
      keywords: [
        'crear cuenta', 'registrarme', 'registro', 'registrar',
        'como registrarse', 'cómo registrarse', 'crear perfil',
        'cuenta nueva', 'darme de alta',
      ],
      response:
          'Para **crear una cuenta nueva**:\n\n'
          '1. En la pantalla de inicio, presiona **"Crear Cuenta"**.\n'
          '2. Completa el formulario con tu **nombre**, **correo electrónico** y una **contraseña segura** (mínimo 6 caracteres).\n'
          '3. Presiona **"Registrarse"**.\n'
          '4. Recibirás un correo de verificación. Ábrelo y confirma tu dirección.\n'
          '5. ¡Listo! Ya puedes explorar destinos, guardar favoritos y reservar tours.\n\n'
          'Si ya tienes cuenta, solo presiona **"Iniciar Sesión"** en la pantalla de inicio. ¿Necesitas ayuda con algo?',
    ),
    _MockEntry(
      keywords: [
        'iniciar sesion', 'iniciar sesión', 'login', 'loguearme',
        'como iniciar sesion', 'cómo iniciar sesión', 'acceder',
        'iniciar secion',
      ],
      response:
          'Para **iniciar sesión**:\n\n'
          '1. En la pantalla de inicio, presiona **"Iniciar Sesión"**.\n'
          '2. Ingresa tu **correo electrónico** y **contraseña**.\n'
          '3. Presiona **"Iniciar Sesión"**.\n\n'
          'Si olvidaste tu contraseña, presiona **"¿Olvidaste tu contraseña?"** en la pantalla de inicio de sesión y sigue las instrucciones para restablecerla.\n\n'
          '¿No tienes cuenta aún? Puedes crear una desde la pantalla de inicio presionando "Crear Cuenta".',
    ),
    _MockEntry(
      keywords: [
        'cerrar sesion', 'cerrar sesión', 'logout', 'salir',
        'como cerrar sesion', 'cómo cerrar sesión',
      ],
      response:
          'Para **cerrar sesión**:\n\n'
          '1. Ve a tu **Perfil** desde el menú inferior (ícono de persona).\n'
          '2. Desplázate hacia abajo.\n'
          '3. Presiona el botón rojo **"Cerrar Sesión"**.\n\n'
          'Se te redirigirá a la pantalla de inicio. Puedes volver a iniciar sesión cuando quieras.',
    ),
    _MockEntry(
      keywords: [
        'escribir reseña', 'escribir opinion', 'reseña', 'resena',
        'review', 'opinión', 'opinion', 'como opinar', 'cómo opinar',
        'dejar reseña', 'calificar', 'como reseñar', 'cómo reseñar',
      ],
      response:
          'Para **escribir una reseña** sobre un tour:\n\n'
          '1. Ve a la pantalla de reseñas desde el menú inferior (tercer ícono).\n'
          '2. Presiona el botón **"Escribir una opinión"**.\n'
          '3. Selecciona tu **calificación** de 1 a 5 estrellas.\n'
          '4. Escribe tu **comentario** contando tu experiencia.\n'
          '5. Presiona **"Publicar"**.\n\n'
          'Tu opinión será visible para otros viajeros y ayudará a la comunidad a elegir los mejores tours. ¡Gracias por compartir tu experiencia!',
    ),
    _MockEntry(
      keywords: [
        'favoritos', 'favorite', 'guardar', 'como guardar', 'cómo guardar',
        'agregar a favoritos', 'marcar', 'destino favorito',
        'ver favoritos', 'mis favoritos',
      ],
      response:
          'Para **agregar un destino o tour a favoritos**:\n\n'
          '1. Abre el **destino o tour** que te guste desde el Catálogo.\n'
          '2. Presiona el ícono de **corazón** ♡ para guardarlo.\n\n'
          'Para **ver tus favoritos**:\n'
          '1. Ve a tu **Perfil** desde el menú inferior.\n'
          '2. Presiona **"Favoritos"** en la lista.\n\n'
          'Los favoritos se guardan en tu cuenta y puedes acceder a ellos desde cualquier dispositivo.',
    ),
    _MockEntry(
      keywords: [
        'buscar', 'busqueda', 'búsqueda', 'encontrar', 'explorar',
        'como buscar', 'cómo buscar', 'encontrar tour',
      ],
      response:
          'Para **buscar destinos y tours**:\n\n'
          '**Desde "Descubrir":**\n'
          '• Usa el campo de búsqueda en la parte superior para filtrar por nombre.\n'
          '• También puedes explorar por categorías (Playas, Cultura, Aventura, etc.).\n\n'
          '**Desde "Catálogo":**\n'
          '• Usa el buscador dentro del banner verde.\n'
          '• Filtra por **precio** usando el control deslizante.\n'
          '• Cambia entre **vista cuadrícula** y **vista carrusel** con el botón junto al filtro.\n\n'
          '¿Te gustaría que te recomiende algún destino en particular?',
    ),
    _MockEntry(
      keywords: [
        'carrito', 'cart', 'bolsa', 'compras',
        'ver carrito', 'mi carrito',
      ],
      response:
          'Para **ver tu carrito de compras**:\n\n'
          '1. Ve a tu **Perfil** desde el menú inferior.\n'
          '2. Presiona **"Carrito"** en la lista de opciones.\n'
          '3. Aquí verás todos los tours que has agregado para reservar.\n'
          '4. Presiona **"Pagar"** para completar la compra.\n\n'
          '¿Necesitas ayuda con el proceso de pago?',
    ),
    _MockEntry(
      keywords: [
        'idioma', 'lenguaje', 'language', 'español', 'ingles', 'inglés',
        'cambiar idioma', 'como cambiar idioma', 'cómo cambiar idioma',
      ],
      response:
          'Para **cambiar el idioma** de la aplicación:\n\n'
          '1. Ve a tu **Perfil** desde el menú inferior.\n'
          '2. Presiona **"Configuración"** en la lista.\n'
          '3. Busca la opción **"Idioma"** y selecciona entre Español o English.\n'
          '4. El cambio se aplica automáticamente.\n\n'
          'Actualmente disponibles: **Español** e **Inglés**.',
    ),
    _MockEntry(
      keywords: [
        'tema oscuro', 'tema claro', 'modo oscuro', 'modo claro',
        'dark mode', 'light mode', 'tema', 'apariencia',
        'cambiar tema', 'como cambiar tema', 'cómo cambiar tema',
      ],
      response:
          'Para **cambiar entre tema claro y oscuro**:\n\n'
          '1. Ve a tu **Perfil** desde el menú inferior.\n'
          '2. Presiona **"Configuración"** en la lista.\n'
          '3. Busca la opción **"Tema"** y selecciona entre Claro, Oscuro o Seguir el sistema.\n'
          '4. El cambio se aplica al instante.',
    ),
    _MockEntry(
      keywords: [
        'perfil', 'editar perfil', 'mi perfil', 'ver perfil',
        'cambiar nombre', 'cambiar foto', 'actualizar datos',
        'como editar perfil', 'cómo editar perfil',
      ],
      response:
          'Para **ver o editar tu perfil**:\n\n'
          '1. Ve a **"Perfil"** desde el menú inferior.\n'
          '2. Presiona **"Perfil"** en la lista de opciones.\n'
          '3. Aquí puedes ver tu nombre, correo y foto.\n'
          '4. Presiona **"Editar"** para modificar tus datos personales.\n\n'
          '¿Necesitas ayuda con algo más de tu cuenta?',
    ),
    _MockEntry(
      keywords: [
        'mis reservaciones', 'mis reservas', 'mis viajes',
        'ver reservaciones', 'ver reservas', 'historial',
        'donde veo mis reservas', 'como ver mis reservas',
      ],
      response:
          'Para **ver tus reservaciones**:\n\n'
          '1. Ve a tu **Perfil** desde el menú inferior.\n'
          '2. Presiona **"Reservaciones"** en la lista.\n'
          '3. Aquí verás todas tus reservas activas y pasadas.\n'
          '4. Toca una reserva para ver los detalles completos (fecha, tour, precio, estado).\n\n'
          'Desde aquí también puedes **cancelar** una reserva si es necesario.',
    ),
    _MockEntry(
      keywords: [
        'contacto', 'soporte', 'atencion', 'atención',
        'whatsapp', 'telefono', 'correo', 'contactar',
        'como contactar', 'cómo contactar', 'hablar con alguien',
        'soporte técnico', 'ayuda',
      ],
      response:
          'Puedes **contactarnos** a través de los siguientes canales:\n\n'
          '📧 **Correo electrónico:** soporte@lifetours.com\n'
          '💬 **WhatsApp:** +52 55 1234 5678\n'
          '🤖 **Este asistente:** disponible 24/7 para dudas generales\n\n'
          '*Horario de atención:* Lunes a sábado de 9:00 a 20:00 hrs.\n\n'
          'Si tu consulta es urgente, te recomendamos enviar un WhatsApp y te responderemos a la brevedad. ¿En qué más puedo ayudarte?',
    ),
    _MockEntry(
      keywords: [
        'seguro', 'seguro de viaje', 'proteccion', 'protección',
        'cobertura', 'asistencia', 'viajar seguro',
      ],
      response:
          'Todos nuestros tours incluyen un **seguro básico de viaje** que cubre:\n'
          '• Asistencia médica básica\n'
          '• Cancelación por emergencia\n'
          '• Pérdida de equipaje\n\n'
          'Si deseas **contratar cobertura adicional**, puedes hacerlo durante el proceso de reserva:\n'
          '1. Al llegar a la pantalla de pago, verás la opción **"Agregar seguro completo"**.\n'
          '2. Activa la casilla para incluir cobertura ampliada.\n'
          '3. El costo adicional se agregará automáticamente al total.\n\n'
          'Recomendamos contratar el seguro completo para viajar con total tranquilidad.',
    ),
    _MockEntry(
      keywords: [
        'equipaje', 'maleta', 'llevar', 'ropa', 'clima',
        'que llevar', 'qué llevar', 'que empacar', 'qué empacar',
        'recomendaciones viaje', 'consejos viaje',
      ],
      response:
          '**Recomendaciones para tu viaje:**\n\n'
          '🧳 **Equipaje:** Una maleta de mano + mochila es suficiente para la mayoría de los tours.\n'
          '👟 **Calzado:** Lleva zapatos cómodos para caminar, especialmente en tours de ciudad o naturaleza.\n'
          '🌤️ **Clima:** Revisa el pronóstico del destino antes de empacar. Capas ligeras funcionan para la mayoría de los destinos.\n'
          '🧴 **No olvides:** Protector solar, repelente de insectos, cargador portátil y adaptador de corriente si viajas al extranjero.\n'
          '📸 **Cámara:** Captura cada momento, pero también disfruta el presente.\n\n'
          'Después de reservar, te enviaremos una **lista detallada** según tu destino y tour seleccionado.',
    ),
  ];

  static String _greeting() {
    return '¡Hola! Soy el asistente de LifeTours. Puedes preguntarme sobre destinos, tours, reservas, pagos o cualquier duda que tengas. Por ejemplo, dime "¿Qué tours hay en Barcelona?" o "¿Cómo reservo un viaje?" y te ayudaré al instante.';
  }

  static String _thanks() {
    return '¡De nada! Me alegra poder ayudarte. Si tienes más preguntas sobre tus viajes, destinos o reservas, aquí estoy para lo que necesites. ¡Buen viaje! 🌍';
  }

  static String _defaultReply(List<DestinationModel>? destinations) {
    final names = destinations?.where((d) => d.isActive).map((d) => d.name).take(5).join(', ') ?? '';
    final list = names.isNotEmpty ? ' Disponibles: $names y más.' : '';
    return 'Gracias por tu mensaje. Puedo ayudarte con información sobre destinos, tours, reservas, pagos y más.$list ¿Por qué no me preguntas por algún destino en específico o qué te gustaría saber?';
  }

  // ── Enriquecimiento estático ──────────────────────────────────────────────────

  static const Map<String, _DestinationEnrichment> _enrichment = {
    'paris': _DestinationEnrichment(
      bestTime: 'Primavera (mar-may) y otoño (sep-nov) para clima templado y menos turistas.',
      cuisine: 'Croissants, baguettes, quesos, vino, escargots y crème brûlée.',
      tip: 'Compra entradas para el Louvre y la Torre Eiffel con anticipación para evitar filas.',
      funFact: 'La Torre Eiffel fue construida para la Exposición Universal de 1889 y originalmente sería desmontada después de 20 años.',
    ),
    'barcelona': _DestinationEnrichment(
      bestTime: 'Primavera (abr-jun) y principios de otoño (sep-oct).',
      cuisine: 'Tapas, paella, jamón ibérico, crema catalana y vino cava.',
      tip: 'Reserva la Sagrada Familia con semanas de antelación, las entradas se agotan rápido.',
      funFact: 'La Sagrada Familia lleva en construcción desde 1882 y se estima que estará terminada en 2026.',
    ),
    'roma': _DestinationEnrichment(
      bestTime: 'Primavera (abr-jun) y otoño (sep-oct).',
      cuisine: 'Pasta carbonara, pizza romana, gelato, tiramisú y espresso.',
      tip: 'Usa el Roma Pass para acceso prioritario a museos y transporte público ilimitado.',
      funFact: 'Roma tiene más de 900 iglesias y una fuente por cada habitante de la antigua Roma.',
    ),
    'tokio': _DestinationEnrichment(
      bestTime: 'Primavera (mar-may) para los cerezos en flor y otoño (oct-nov).',
      cuisine: 'Sushi, ramen, tempura, takoyaki y matcha.',
      tip: 'Compra una tarjeta Suica para moverte fácilmente en metro y tren.',
      funFact: 'Tokio tiene 13 millones de habitantes, pero es una de las ciudades más seguras del mundo.',
    ),
    'nueva_york': _DestinationEnrichment(
      bestTime: 'Primavera (abr-jun) y otoño (sep-nov).',
      cuisine: 'Bagels, pizza neoyorquina, hot dogs, cheesecake y pastrami.',
      tip: 'Compra el New York Pass para ahorrar en más de 100 atracciones turísticas.',
      funFact: 'Central Park es más grande que el principado de Mónaco.',
    ),
    'londres': _DestinationEnrichment(
      bestTime: 'Primavera (mar-may) y verano (jun-ago).',
      cuisine: 'Fish and chips, Sunday roast, afternoon tea y bangers and mash.',
      tip: 'Usa la tarjeta Oyster para transporte público más económico.',
      funFact: 'El Big Ben no es el nombre de la torre, sino de la campana de 13 toneladas que alberga.',
    ),
    'sidney': _DestinationEnrichment(
      bestTime: 'Verano austral (dic-feb) y otoño (mar-may).',
      cuisine: 'Mariscos, meat pie, Vegemite, pavlova y flat white.',
      tip: 'Lleva protector solar aunque esté nublado, la radiación UV es muy alta.',
      funFact: 'La Ópera de Sídney tiene más de un millón de tejas en su techo.',
    ),
    'cancun': _DestinationEnrichment(
      bestTime: 'Noviembre a abril para evitar la temporada de huracanes.',
      cuisine: 'Cochinita pibil, tacos al pastor, ceviche, chiles rellenos y margaritas.',
      tip: 'Visita Chichén Itzá temprano para evitar el calor y las multitudes.',
      funFact: 'Chichén Itzá fue nombrada una de las 7 Maravillas del Mundo Moderno en 2007.',
    ),
    'bangkok': _DestinationEnrichment(
      bestTime: 'Noviembre a febrero, temporada fresca y seca.',
      cuisine: 'Pad thai, tom yum goong, mango sticky rice, curry verde.',
      tip: 'Respeta los templos: cubre hombros y rodillas, y quita los zapatos al entrar.',
      funFact: 'Bangkok tiene el nombre ceremonial más largo del mundo: 168 caracteres.',
    ),
    'dubai': _DestinationEnrichment(
      bestTime: 'Noviembre a marzo para clima agradable.',
      cuisine: 'Shawarma, hummus, falafel, kebab y dátiles rellenos.',
      tip: 'Viste con respeto la cultura local en zonas tradicionales.',
      funFact: 'El Burj Khalifa tiene 163 pisos y su mirador está a 555 metros de altura.',
    ),
    'cusco': _DestinationEnrichment(
      bestTime: 'Mayo a septiembre (temporada seca).',
      cuisine: 'Ceviche, lomo saltado, cuy chactado, pachamanca y chicha morada.',
      tip: 'Aclimátate un día antes de hacer trekking para evitar el mal de altura.',
      funFact: 'Machu Picchu fue declarada Santuario Histórico del Perú en 1981.',
    ),
    'marrakech': _DestinationEnrichment(
      bestTime: 'Primavera (mar-may) y otoño (sep-nov).',
      cuisine: 'Cuscús, tagine, pastela, té de menta y harira.',
      tip: 'Regatea en los zocos: el precio inicial suele ser el doble del real.',
      funFact: 'La Plaza Jemaa el-Fna es Patrimonio Cultural Inmaterial de la UNESCO.',
    ),
  };
}

class _MockEntry {
  final List<String> keywords;
  final String response;
  const _MockEntry({required this.keywords, required this.response});
}

class _DestinationEnrichment {
  final String? bestTime;
  final String? cuisine;
  final String? tip;
  final String? funFact;
  const _DestinationEnrichment({this.bestTime, this.cuisine, this.tip, this.funFact});
}
