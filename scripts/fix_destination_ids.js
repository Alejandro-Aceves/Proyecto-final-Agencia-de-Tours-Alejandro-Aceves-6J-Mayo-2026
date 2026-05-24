const https = require('https');

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

// Map of WRONG destinationId -> CORRECT destinationId
const FIXES = {
  'tokyo': 'tokio',
  'new_york': 'nueva_york',
  'london': 'londres',
};

async function main() {
  // Get all tours from Firestore
  const res = await request('GET', `${BASE}/tours`);
  const docs = res.documents || [];

  for (const doc of docs) {
    const name = doc.name;
    const docId = name.split('/').pop();
    const fields = doc.fields || {};
    const currentDestId = fields.destinationId?.stringValue;

    if (currentDestId && FIXES[currentDestId]) {
      const correctId = FIXES[currentDestId];
      console.log(`  Fixing tour "${docId}": destinationId "${currentDestId}" → "${correctId}"`);
      await request('PATCH', `${BASE}/tours/${docId}?updateMask.fieldPaths=destinationId`, {
        fields: { destinationId: { stringValue: correctId } }
      });
      console.log(`    ✓ Updated`);
    }
  }

  console.log('\nDone! All tours updated.');
}

main().catch(console.error);
