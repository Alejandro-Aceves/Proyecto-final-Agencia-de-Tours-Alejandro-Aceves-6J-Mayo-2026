const https = require('https');
const crypto = require('crypto');

const PROJECT = 'lifetours-452a8';
const API_KEY = 'AIzaSyBSYwJYwOswrZkBiEP7OVufVYfPiGw_daw';
const BASE = `https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)/documents`;

function request(method, url, body) {
  return new Promise((resolve, reject) => {
    const u = new URL(url);
    u.searchParams.set('key', API_KEY);
    const data = body ? JSON.stringify(body) : null;
    const req = https.request(u.toString(), {
      method,
      headers: data ? { 'Content-Type': 'application/json' } : undefined,
    }, (res) => {
      let chunks = [];
      res.on('data', c => chunks.push(c));
      res.on('end', () => {
        const txt = Buffer.concat(chunks).toString();
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve(txt ? JSON.parse(txt) : null);
        } else {
          reject(new Error(`${res.statusCode}: ${txt}`));
        }
      });
    });
    req.on('error', reject);
    if (data) req.write(data);
    req.end();
  });
}

function docId(name) {
  return name.toLowerCase()
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]/g, '_');
}

function ts(dateStr) {
  return new Date(dateStr + 'T00:00:00Z').toISOString();
}

function fields(obj) {
  const f = {};
  for (const [k, v] of Object.entries(obj)) {
    if (v === null || v === undefined) continue;
    if (v instanceof Date || (typeof v === 'string' && /^\d{4}-\d{2}-\d{2}T/.test(v))) {
      f[k] = { timestampValue: v instanceof Date ? v.toISOString() : v };
    } else if (typeof v === 'string') {
      f[k] = { stringValue: v };
    } else if (typeof v === 'boolean') {
      f[k] = { booleanValue: v };
    } else if (typeof v === 'number') {
      f[k] = Number.isInteger(v) ? { integerValue: v } : { doubleValue: v };
    } else if (Array.isArray(v)) {
      f[k] = { arrayValue: { values: v.map(e => {
        if (typeof e === 'string') return { stringValue: e };
        if (typeof e === 'number') return { doubleValue: e };
        return {};
      }) } };
    }
  }
  return f;
}

function makeDoc(collection, id, data) {
  const path = `${BASE}/${collection}/${id}`;
  return request('PATCH', path, { fields: fields(data) });
}

// ── Destinations ──────────────────────────────────────────────────────

const destinations = [
  {
    name: 'París',
    country: 'Francia',
    city: 'París',
    description: 'La ciudad del amor y la luz. Descubre la Torre Eiffel, el Louvre y la magia de sus calles empedradas. Un destino imperdible para los amantes del arte, la gastronomía y la cultura.',
    imageUrl: 'https://picsum.photos/seed/paris/800/400',
    activities: ['Museos', 'Gastronomía', 'Historia', 'Compras'],
    isActive: true, createdAt: ts('2024-01-15'),
  },
  {
    name: 'Tokio',
    country: 'Japón',
    city: 'Tokio',
    description: 'Una metrópolis donde lo tradicional y lo futurista se encuentran. Explora templos antiguos, barrios electrónicos y la mejor gastronomía del mundo.',
    imageUrl: 'https://picsum.photos/seed/tokyo/800/400',
    activities: ['Templos', 'Tecnología', 'Gastronomía', 'Historia'],
    isActive: true, createdAt: ts('2024-01-20'),
  },
  {
    name: 'Nueva York',
    country: 'Estados Unidos',
    city: 'Nueva York',
    description: 'La ciudad que nunca duerme. Times Square, Central Park, la Estatua de la Libertad y una energía única te esperan en la Gran Manzana.',
    imageUrl: 'https://picsum.photos/seed/newyork/800/400',
    activities: ['Museos', 'Compras', 'Espectáculos', 'Gastronomía'],
    isActive: true, createdAt: ts('2024-02-01'),
  },
  {
    name: 'Roma',
    country: 'Italia',
    city: 'Roma',
    description: 'La Ciudad Eterna. Desde el Coliseo hasta el Vaticano, cada rincón de Roma respira historia, arte y la dolce vita italiana.',
    imageUrl: 'https://picsum.photos/seed/roma/800/400',
    activities: ['Historia', 'Museos', 'Gastronomía', 'Templos'],
    isActive: true, createdAt: ts('2024-02-10'),
  },
  {
    name: 'Londres',
    country: 'Reino Unido',
    city: 'Londres',
    description: 'Una ciudad global llena de historia, cultura y modernidad. El Big Ben, el London Eye y sus emblemáticos museos te esperan.',
    imageUrl: 'https://picsum.photos/seed/london/800/400',
    activities: ['Museos', 'Historia', 'Espectáculos', 'Compras'],
    isActive: true, createdAt: ts('2024-02-15'),
  },
  {
    name: 'Sídney',
    country: 'Australia',
    city: 'Sídney',
    description: 'La perla de Australia. Playas doradas, la Ópera de Sídney y una vibrante vida urbana en un entorno natural incomparable.',
    imageUrl: 'https://picsum.photos/seed/sydney/800/400',
    activities: ['Agua', 'Naturaleza', 'Gastronomía', 'Historia'],
    isActive: true, createdAt: ts('2024-03-01'),
  },
  {
    name: 'Cancún',
    country: 'México',
    city: 'Cancún',
    description: 'Paraíso caribeño con playas de arena blanca y aguas cristalinas. Zonas arqueológicas mayas y una vida nocturna inigualable.',
    imageUrl: 'https://picsum.photos/seed/cancun/800/400',
    activities: ['Agua', 'Naturaleza', 'Historia', 'Gastronomía'],
    isActive: true, createdAt: ts('2024-03-10'),
  },
  {
    name: 'Bangkok',
    country: 'Tailandia',
    city: 'Bangkok',
    description: 'La capital tailandesa donde los templos dorados conviven con mercados flotantes y una gastronomía callejera de clase mundial.',
    imageUrl: 'https://picsum.photos/seed/bangkok/800/400',
    activities: ['Templos', 'Gastronomía', 'Historia', 'Compras'],
    isActive: true, createdAt: ts('2024-03-15'),
  },
  {
    name: 'Barcelona',
    country: 'España',
    city: 'Barcelona',
    description: 'Arte, playa y tapas. Las obras de Gaudí, Las Ramblas y el Mediterráneo hacen de Barcelona un destino único.',
    imageUrl: 'https://picsum.photos/seed/barcelona/800/400',
    activities: ['Cultura', 'Gastronomía', 'Historia', 'Agua'],
    isActive: true, createdAt: ts('2024-03-20'),
  },
  {
    name: 'Dubái',
    country: 'Emiratos Árabes',
    city: 'Dubái',
    description: 'Lujo y modernidad en el desierto. Rascacielos imponentes, centros comerciales gigantescos y experiencias únicas en el corazón de Oriente.',
    imageUrl: 'https://picsum.photos/seed/dubai/800/400',
    activities: ['Compras', 'Gastronomía', 'Cultura', 'Historia'],
    isActive: true, createdAt: ts('2024-04-01'),
  },
  {
    name: 'Cusco',
    country: 'Perú',
    city: 'Cusco',
    description: 'La puerta de entrada a Machu Picchu. Calles incaicas, plazas coloniales y una energía espiritual que te conecta con la historia.',
    imageUrl: 'https://picsum.photos/seed/cusco/800/400',
    activities: ['Historia', 'Cultura', 'Naturaleza', 'Gastronomía'],
    isActive: true, createdAt: ts('2024-04-10'),
  },
  {
    name: 'Marrakech',
    country: 'Marruecos',
    city: 'Marrakech',
    description: 'La ciudad roja de Marruecos. Zocos llenos de color, palacios ornamentados y el desierto del Sahara a tus pies.',
    imageUrl: 'https://picsum.photos/seed/marrakech/800/400',
    activities: ['Cultura', 'Gastronomía', 'Historia', 'Compras'],
    isActive: true, createdAt: ts('2024-04-20'),
  },
];

// ── Tours ──────────────────────────────────────────────────────────────

const tours = [
  // París (paris)
  { title: 'Tour por el Louvre', description: 'Visita guiada por el museo más famoso del mundo. Acceso prioritario a la Mona Lisa y las obras maestras.', price: 89.99, imageUrl: 'https://picsum.photos/seed/louvre/400/300', destinationId: 'paris', destinationName: 'París', categories: ['museos', 'historia'], durationDays: 1, capacity: 25, availableSpots: 15, averageRating: 4.8, reviewCount: 234, isActive: true, createdAt: ts('2024-01-16') },
  { title: 'Cena en la Torre Eiffel', description: 'Cena romántica con vista panorámica de París en el restaurante Jules Verne. Menú degustación de 5 tiempos.', price: 199.99, imageUrl: 'https://picsum.photos/seed/eiffel/400/300', destinationId: 'paris', destinationName: 'París', categories: ['cultura', 'comida'], durationDays: 1, capacity: 15, availableSpots: 8, averageRating: 4.9, reviewCount: 189, isActive: true, createdAt: ts('2024-01-17') },
  { title: 'Crucero por el Sena', description: 'Navega por el río Sena al atardecer. Descubre los monumentos más emblemáticos de París desde otra perspectiva.', price: 49.99, imageUrl: 'https://picsum.photos/seed/sena/400/300', destinationId: 'paris', destinationName: 'París', categories: ['cultura', 'agua'], durationDays: 1, capacity: 40, availableSpots: 22, averageRating: 4.6, reviewCount: 312, isActive: true, createdAt: ts('2024-01-18') },

  // Tokio (tokio)
  { title: 'Tour de Sushi en Tsukiji', description: 'Recorrido por el mercado de pescado más grande del mundo con degustación de sushi fresco preparado por chefs locales.', price: 129.99, imageUrl: 'https://picsum.photos/seed/tsukiji/400/300', destinationId: 'tokio', destinationName: 'Tokio', categories: ['comida'], durationDays: 1, capacity: 12, availableSpots: 6, averageRating: 4.7, reviewCount: 156, isActive: true, createdAt: ts('2024-01-21') },
  { title: 'Visita a templos antiguos', description: 'Recorrido por los templos más emblemáticos de Tokio: Senso-ji, Meiji y el templo de la Roca que Escucha.', price: 69.99, imageUrl: 'https://picsum.photos/seed/templos/400/300', destinationId: 'tokio', destinationName: 'Tokio', categories: ['templos', 'historia'], durationDays: 1, capacity: 20, availableSpots: 14, averageRating: 4.5, reviewCount: 198, isActive: true, createdAt: ts('2024-01-22') },
  { title: 'Experiencia en Akihabara', description: 'Sumérgete en el distrito electrónico de Akihabara. Visita tiendas de anime, videojuegos y tecnología de punta.', price: 59.99, imageUrl: 'https://picsum.photos/seed/akihabara/400/300', destinationId: 'tokio', destinationName: 'Tokio', categories: ['cultura'], durationDays: 1, capacity: 15, availableSpots: 10, averageRating: 4.4, reviewCount: 134, isActive: true, createdAt: ts('2024-01-23') },

  // Nueva York (nueva_york)
  { title: 'Tour por Manhattan', description: 'Recorrido completo por Manhattan: Times Square, Central Park, Rockefeller Center y el distrito financiero.', price: 79.99, imageUrl: 'https://picsum.photos/seed/manhattan/400/300', destinationId: 'nueva_york', destinationName: 'Nueva York', categories: ['cultura', 'historia'], durationDays: 1, capacity: 30, availableSpots: 18, averageRating: 4.6, reviewCount: 276, isActive: true, createdAt: ts('2024-02-02') },
  { title: 'Espectáculo en Broadway', description: 'Disfruta de un musical de clase mundial en Broadway con entradas incluidas y visita detrás de escena.', price: 149.99, imageUrl: 'https://picsum.photos/seed/broadway/400/300', destinationId: 'nueva_york', destinationName: 'Nueva York', categories: ['cultura'], durationDays: 1, capacity: 20, availableSpots: 12, averageRating: 4.8, reviewCount: 215, isActive: true, createdAt: ts('2024-02-03') },
  { title: 'Estación Central y High Line', description: 'Descubre la arquitectura de Grand Central Terminal y camina por el High Line, el parque elevado más famoso de NYC.', price: 45.99, imageUrl: 'https://picsum.photos/seed/highline/400/300', destinationId: 'nueva_york', destinationName: 'Nueva York', categories: ['cultura', 'historia'], durationDays: 1, capacity: 25, availableSpots: 20, averageRating: 4.5, reviewCount: 167, isActive: true, createdAt: ts('2024-02-04') },

  // Londres (londres)
  { title: 'Tour por el Big Ben y Westminster', description: 'Visita guiada por el Parlamento, el Big Ben y la Abadía de Westminster. Historia viva de Londres.', price: 69.99, imageUrl: 'https://picsum.photos/seed/bigben/400/300', destinationId: 'londres', destinationName: 'Londres', categories: ['historia', 'museos'], durationDays: 1, capacity: 30, availableSpots: 21, averageRating: 4.5, reviewCount: 245, isActive: true, createdAt: ts('2024-02-16') },
  { title: 'London Eye y River Thames', description: 'Disfruta de una vista panorámica de Londres desde el London Eye y un paseo en barco por el Támesis.', price: 89.99, imageUrl: 'https://picsum.photos/seed/londoneye/400/300', destinationId: 'londres', destinationName: 'Londres', categories: ['cultura', 'agua'], durationDays: 1, capacity: 35, availableSpots: 25, averageRating: 4.6, reviewCount: 198, isActive: true, createdAt: ts('2024-02-17') },
  { title: 'Museo Británico', description: 'Recorrido por las colecciones más importantes del Museo Británico con guía especializado. La piedra de Rosetta incluida.', price: 39.99, imageUrl: 'https://picsum.photos/seed/museobritanico/400/300', destinationId: 'londres', destinationName: 'Londres', categories: ['museos', 'historia'], durationDays: 1, capacity: 20, availableSpots: 16, averageRating: 4.4, reviewCount: 276, isActive: true, createdAt: ts('2024-02-18') },

  // Sídney (sidney)
  { title: 'Tour por la Ópera de Sídney', description: 'Visita guiada detrás de escena de la icónica Ópera de Sídney. Incluye acceso a salas de concierto exclusivas.', price: 109.99, imageUrl: 'https://picsum.photos/seed/opera/400/300', destinationId: 'sidney', destinationName: 'Sídney', categories: ['cultura', 'historia'], durationDays: 1, capacity: 20, availableSpots: 14, averageRating: 4.7, reviewCount: 167, isActive: true, createdAt: ts('2024-03-02') },
  { title: 'Surf en Bondi Beach', description: 'Clase de surf en la famosa Bondi Beach. Equipo incluido y instructores certificados para todos los niveles.', price: 79.99, imageUrl: 'https://picsum.photos/seed/bondi/400/300', destinationId: 'sidney', destinationName: 'Sídney', categories: ['agua', 'aireLibre'], durationDays: 1, capacity: 12, availableSpots: 8, averageRating: 4.6, reviewCount: 145, isActive: true, createdAt: ts('2024-03-03') },
  { title: 'Excursión a las Montañas Azules', description: 'Escapa de la ciudad y descubre las Montañas Azules con sus formaciones rocosas, cascadas y koalas.', price: 139.99, imageUrl: 'https://picsum.photos/seed/bluemountains/400/300', destinationId: 'sidney', destinationName: 'Sídney', categories: ['naturaleza', 'aireLibre'], durationDays: 1, capacity: 18, availableSpots: 12, averageRating: 4.8, reviewCount: 198, isActive: true, createdAt: ts('2024-03-04') },

  // Cancún (cancun)
  { title: 'Tour a Chichén Itzá', description: 'Visita a la maravilla del mundo maya. Guía bilingüe, transporte y comida incluidos.', price: 129.99, imageUrl: 'https://picsum.photos/seed/chichen/400/300', destinationId: 'cancun', destinationName: 'Cancún', categories: ['historia', 'cultura'], durationDays: 1, capacity: 30, availableSpots: 20, averageRating: 4.7, reviewCount: 456, isActive: true, createdAt: ts('2024-03-11') },
  { title: 'Snorkel en el arrecife', description: 'Explora el segundo arrecife de coral más grande del mundo. Equipo de snorkel y guía incluidos.', price: 69.99, imageUrl: 'https://picsum.photos/seed/snorkel/400/300', destinationId: 'cancun', destinationName: 'Cancún', categories: ['agua', 'naturaleza'], durationDays: 1, capacity: 20, availableSpots: 15, averageRating: 4.5, reviewCount: 234, isActive: true, createdAt: ts('2024-03-12') },
  { title: 'Cenote y selva maya', description: 'Nada en cenotes cristalinos y camina por la selva maya. Incluye transporte y comida típica.', price: 99.99, imageUrl: 'https://picsum.photos/seed/cenote/400/300', destinationId: 'cancun', destinationName: 'Cancún', categories: ['agua', 'naturaleza', 'aireLibre'], durationDays: 1, capacity: 15, availableSpots: 10, averageRating: 4.9, reviewCount: 312, isActive: true, createdAt: ts('2024-03-13') },

  // Bangkok (bangkok)
  { title: 'Tour de templos y palacios', description: 'Recorrido por el Gran Palacio, Wat Pho y Wat Arun. Descubre la espiritualidad tailandesa.', price: 59.99, imageUrl: 'https://picsum.photos/seed/watpho/400/300', destinationId: 'bangkok', destinationName: 'Bangkok', categories: ['templos', 'historia', 'cultura'], durationDays: 1, capacity: 25, availableSpots: 17, averageRating: 4.6, reviewCount: 189, isActive: true, createdAt: ts('2024-03-16') },
  { title: 'Mercado flotante Damnoen', description: 'Visita al mercado flotante más famoso de Tailandia. Paseo en barca y degustación de frutas exóticas.', price: 49.99, imageUrl: 'https://picsum.photos/seed/flotante/400/300', destinationId: 'bangkok', destinationName: 'Bangkok', categories: ['comida', 'cultura', 'agua'], durationDays: 1, capacity: 20, availableSpots: 14, averageRating: 4.4, reviewCount: 167, isActive: true, createdAt: ts('2024-03-17') },
  { title: 'Street food tour', description: 'Recorrido gastronómico por las calles de Bangkok. Prueba pad thai, mango sticky rice y más.', price: 39.99, imageUrl: 'https://picsum.photos/seed/thaifood/400/300', destinationId: 'bangkok', destinationName: 'Bangkok', categories: ['comida', 'cultura'], durationDays: 1, capacity: 10, availableSpots: 6, averageRating: 4.8, reviewCount: 278, isActive: true, createdAt: ts('2024-03-18') },

  // Barcelona (barcelona)
  { title: 'Sagrada Familia y Gaudí', description: 'Tour guiado por la Sagrada Familia, el Parque Güell y otras obras maestras de Gaudí con entrada preferencial.', price: 89.99, imageUrl: 'https://picsum.photos/seed/sagrada/400/300', destinationId: 'barcelona', destinationName: 'Barcelona', categories: ['cultura', 'historia'], durationDays: 1, capacity: 25, availableSpots: 16, averageRating: 4.7, reviewCount: 312, isActive: true, createdAt: ts('2024-03-21') },
  { title: 'Tapas y vino en El Born', description: 'Recorrido por las mejores bodegas y bares de tapas del barrio de El Born. Incluye 5 paradas gastronómicas.', price: 74.99, imageUrl: 'https://picsum.photos/seed/tapas/400/300', destinationId: 'barcelona', destinationName: 'Barcelona', categories: ['comida', 'cultura'], durationDays: 1, capacity: 12, availableSpots: 8, averageRating: 4.8, reviewCount: 234, isActive: true, createdAt: ts('2024-03-22') },
  { title: 'Catamaran por la costa', description: 'Navega por la costa barcelonesa en catamarán. Baño en calas escondidas, bebidas y música a bordo.', price: 59.99, imageUrl: 'https://picsum.photos/seed/catamaran/400/300', destinationId: 'barcelona', destinationName: 'Barcelona', categories: ['agua', 'aireLibre'], durationDays: 1, capacity: 20, availableSpots: 14, averageRating: 4.5, reviewCount: 178, isActive: true, createdAt: ts('2024-03-23') },

  // Dubái (dubai)
  { title: 'Burj Khalifa y Dubai Mall', description: 'Sube al mirador del edificio más alto del mundo y explora el Dubai Mall con sus atracciones únicas.', price: 159.99, imageUrl: 'https://picsum.photos/seed/burj/400/300', destinationId: 'dubai', destinationName: 'Dubái', categories: ['cultura', 'compras'], durationDays: 1, capacity: 30, availableSpots: 22, averageRating: 4.6, reviewCount: 289, isActive: true, createdAt: ts('2024-04-02') },
  { title: 'Safari en el desierto', description: 'Aventura en el desierto de Dubái con paseo en 4x4, cena beduina y espectáculo de danza del vientre.', price: 119.99, imageUrl: 'https://picsum.photos/seed/desert/400/300', destinationId: 'dubai', destinationName: 'Dubái', categories: ['naturaleza', 'cultura', 'aireLibre'], durationDays: 1, capacity: 20, availableSpots: 15, averageRating: 4.7, reviewCount: 345, isActive: true, createdAt: ts('2024-04-03') },
  { title: 'Tour de compras en Dubái', description: 'Recorrido por los mejores centros comerciales y zocos tradicionales de Dubái. Transporte privado incluido.', price: 49.99, imageUrl: 'https://picsum.photos/seed/dubaimall/400/300', destinationId: 'dubai', destinationName: 'Dubái', categories: ['compras', 'cultura'], durationDays: 1, capacity: 15, availableSpots: 10, averageRating: 4.3, reviewCount: 156, isActive: true, createdAt: ts('2024-04-04') },

  // Cusco (cusco)
  { title: 'Machu Picchu clásico', description: 'Tour completo a Machu Picchu. Tren panorámico, guía bilingüe y entrada a la ciudadela inca incluidos.', price: 249.99, imageUrl: 'https://picsum.photos/seed/machupicchu/400/300', destinationId: 'cusco', destinationName: 'Cusco', categories: ['historia', 'naturaleza', 'aireLibre'], durationDays: 2, capacity: 20, availableSpots: 10, averageRating: 4.9, reviewCount: 567, isActive: true, createdAt: ts('2024-04-11') },
  { title: 'Valle Sagrado', description: 'Recorrido por el Valle Sagrado de los Incas: Pisac, Ollantaytambo y Chinchero. Mercado artesanal incluido.', price: 89.99, imageUrl: 'https://picsum.photos/seed/vallesagrado/400/300', destinationId: 'cusco', destinationName: 'Cusco', categories: ['historia', 'cultura', 'naturaleza'], durationDays: 1, capacity: 25, availableSpots: 18, averageRating: 4.6, reviewCount: 234, isActive: true, createdAt: ts('2024-04-12') },
  { title: 'Montaña de 7 colores', description: 'Trekking a la impresionante Montaña Arcoíris. Aclimatación, guía y alimentación incluidos.', price: 79.99, imageUrl: 'https://picsum.photos/seed/arcoiris/400/300', destinationId: 'cusco', destinationName: 'Cusco', categories: ['naturaleza', 'aireLibre'], durationDays: 1, capacity: 15, availableSpots: 9, averageRating: 4.7, reviewCount: 198, isActive: true, createdAt: ts('2024-04-13') },

  // Marrakech (marrakech)
  { title: 'Tour por los zocos', description: 'Recorrido por los laberínticos zocos de Marrakech. Descubre artesanía, especias y tesoros escondidos.', price: 39.99, imageUrl: 'https://picsum.photos/seed/zocos/400/300', destinationId: 'marrakech', destinationName: 'Marrakech', categories: ['compras', 'cultura'], durationDays: 1, capacity: 15, availableSpots: 11, averageRating: 4.4, reviewCount: 167, isActive: true, createdAt: ts('2024-04-21') },
  { title: 'Palacios y jardines', description: 'Visita al Palacio de la Bahía, las Tumbas Saadíes y los Jardines Majorelle. Historia y belleza en cada rincón.', price: 54.99, imageUrl: 'https://picsum.photos/seed/majorelle/400/300', destinationId: 'marrakech', destinationName: 'Marrakech', categories: ['historia', 'cultura'], durationDays: 1, capacity: 20, availableSpots: 15, averageRating: 4.5, reviewCount: 145, isActive: true, createdAt: ts('2024-04-22') },
  { title: 'Excursión al desierto', description: 'Escapa al desierto del Sahara. Noche en jaima, paseo en camello y cena bajo las estrellas.', price: 189.99, imageUrl: 'https://picsum.photos/seed/sahara/400/300', destinationId: 'marrakech', destinationName: 'Marrakech', categories: ['naturaleza', 'cultura', 'aireLibre'], durationDays: 2, capacity: 18, availableSpots: 12, averageRating: 4.8, reviewCount: 234, isActive: true, createdAt: ts('2024-04-23') },
];

async function main() {
  console.log('Seeding destinations...');
  for (const d of destinations) {
    const id = docId(d.name);
    try {
      await makeDoc('destinations', id, d);
      console.log(`  ✓ ${d.name}`);
    } catch (e) {
      console.error(`  ✗ ${d.name}: ${e.message}`);
    }
  }

  console.log('\nSeeding tours...');
  let i = 1;
  for (const t of tours) {
    const id = `tour_${String(i++).padStart(3, '0')}`;
    try {
      await makeDoc('tours', id, t);
      console.log(`  ✓ ${t.title}`);
    } catch (e) {
      console.error(`  ✗ ${t.title}: ${e.message}`);
    }
  }

  console.log('\nDone!');
}

main().catch(console.error);
