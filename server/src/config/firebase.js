// src/config/firebase.js
import admin from "firebase-admin";
import { createRequire } from "module";

const require = createRequire(import.meta.url);

// load JSON safely
const serviceAccount = require("./firebase-service-account.json");

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

export default admin;