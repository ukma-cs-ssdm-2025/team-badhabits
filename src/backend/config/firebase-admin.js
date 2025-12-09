const admin = require('../../firebase-admin-key.json');

// Service account key is already in project root: firebase-admin-key.json
const serviceAccount = require('../../firebase-admin-key.json');

// Initialize Firebase Admin (only once)
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: 'https://wellity-default-rtdb.firebaseio.com',
  });
}

const firestore = admin.firestore();
const realtimeDb = admin.database();

module.exports = { admin, firestore, realtimeDb };
